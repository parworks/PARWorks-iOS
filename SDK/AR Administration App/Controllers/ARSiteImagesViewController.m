//
//  ARSiteImagesViewController.m
//  PAR Works iOS SDK
//
//  Copyright 2012 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AROverlayCreatorViewController.h"
#import "ARSiteImagesInfoView.h"
#import "ARSiteImagesViewController.h"
#import "ARPhotoViewController.h"
#import "PARWorks.h"

@implementation ARSiteImagesViewController

@synthesize site = _site;
@synthesize gridView = _gridView;


#pragma mark - Lifecycle
- (id)initWithSite:(ARSite*)s
{
    self = [super init];
    if (self) {
        self.site = s;
        self.title = [s identifier];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString * path = [[NSBundle mainBundle] pathForResource:@"cow" ofType:@"ply"];
    _pointCloudView = [[PointCloudView alloc] initWithFrame: self.gridView.frame andPLYPath: path];
    [_pointCloudView setAlpha: 0];
    [self.view addSubview: _pointCloudView];

    [self update];

    // subscribe to updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NOTIF_SITE_UPDATED object: _site];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [self setGridView:nil];
    [self setCameraCaptureButton:nil];
    [self setCameraDoneButton:nil];
    [self setCameraOverlayView:nil];
    [self setPointCloudLabel:nil];
    [super viewDidUnload];
}

- (void)update
{
    [_gridView reloadData];
    [_infoView setSiteStatus: _site.status];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.3];

    if (_site.status == ARSiteStatusProcessing) {
        if ([_pointCloudView alpha] < 1)
            [_pointCloudView startAnimating];
        [_pointCloudView setAlpha: 1];
        [_pointCloudLabel setAlpha: 1];
        [_gridView setAlpha: 0];
        [_pointCloudLabel setText: @"Processing images into a 3D model. This may take 3-5 min."];
    } else if (_site.status == ARSiteStatusProcessingFailed) {
        if ([_pointCloudView alpha] < 1)
            [_pointCloudView startAnimating];
        [_pointCloudView setAlpha: 1];
        [_pointCloudLabel setAlpha: 1];
        [_gridView setAlpha: 0];
        [_pointCloudLabel setText: @"Image processing failed. Please visit the PARWorks website and try again."];
    } else {
        [_pointCloudView setAlpha: 0];
        [_pointCloudView stopAnimating];
        [_pointCloudLabel setAlpha: 0];
        [_gridView setAlpha: 1];
    }

    [UIView commitAnimations];
}


#pragma mark - Rotation

- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


#pragma mark - Grid of Images

- (BOOL)isLoadingForGridView:(GridView*)gv
{
    return [_site isFetchingImages];
}

- (NSArray*)objectCollectionForGridView:(GridView*)gv
{
    return [_site images];
}

- (void)object:(id)obj selectedInGridView:(GridView*)gv
{
    // Load the overlay creator if we're in the correct state.
    if (_site.status == ARSiteStatusProcessed) {
        ARSiteImage *img = (ARSiteImage *)obj;
        
        // Cheat and use the height since we always work in portrait ;)
        NSURL *url  = [img urlForSize:self.view.frame.size.height];
        AROverlayCreatorViewController *vc = [[AROverlayCreatorViewController alloc] initWithImagePath:[url absoluteString]];
        [self presentViewController:vc animated:YES completion:nil];
    }
}


#pragma mark - InfoView Button Actions


- (IBAction)addBasePhotos:(id)sender
{
    _imageIsSiteImage = YES;
    
    _picker = [[UIImagePickerController alloc] init];
    [_picker setDelegate: self];
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [_picker setCameraOverlayView: _cameraOverlayView];
        [_picker setShowsCameraControls: NO];
    } else
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentModalViewController: _picker animated:YES];
}

- (IBAction)augmentPhoto:(id)sender
{
    UIActionSheet * s = [[UIActionSheet alloc] initWithTitle:@"Image Type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Augment an Image", @"Augment a Saved Image", nil];
    [s showFromTabBar: self.tabBarController.tabBar];
}

- (IBAction)processImagesButtonTapped:(id)sender
{
    // Show an alert view to affirm the user actually wants to process.
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to process these base images? Once you begin processing, you cannot add more images to this site." delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [av show];
}

- (IBAction)addOverlayButtonTapped:(id)sender
{
    // TODO: Load the overlay creation view controller
}

#pragma mark - Managing the Camera

- (void)takePicture:(id)sender
{
    [_picker takePicture];
}

- (IBAction)doneTakingPictures:(id)sender
{
    [self dismissModalViewControllerAnimated: YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex])
        return;
    
    _imageIsSiteImage = NO;
    _picker = [[UIImagePickerController alloc] init];
    [_picker setDelegate: self];
    
    if ((buttonIndex != 2) && ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])) {
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [_picker setCameraOverlayView: _cameraOverlayView];
        [_picker setShowsCameraControls: NO];
    } else
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentModalViewController: _picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * img = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    if (_picker.sourceType != UIImagePickerControllerSourceTypeCamera)
        [_picker dismissModalViewControllerAnimated: YES];
    
    if (_imageIsSiteImage) {
        [_site addImage: img];
    } else {
        [_site augmentImage: img];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex])
        return;
    
    if (buttonIndex == 1)
        [_site processBaseImages];
}

- (IBAction)addOverlayButtonTapped:(id)sender
{
    
}

@end
