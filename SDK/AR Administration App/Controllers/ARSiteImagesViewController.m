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
    
    // subscribe to updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:NOTIF_SITE_UPDATED object: _site];
    
    [_gridView reloadData];
    
    // create the upper right add button
    UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addPhoto:)];
    [self.navigationItem setRightBarButtonItem:add animated:YES];
    
    _infoView.siteStatus = _site.status;
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [self setGridView:nil];
    [self setCameraCaptureButton:nil];
    [self setCameraDoneButton:nil];
    [self setCameraOverlayView:nil];
    [super viewDidUnload];
}


#pragma mark - Rotation
- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



- (void)reloadData
{
    [_gridView reloadData];
}


#pragma mark - GridViewDelegate
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


#pragma mark - Photo Handling
- (void)addPhoto:(id)sender
{
    UIActionSheet * s = [[UIActionSheet alloc] initWithTitle:@"Image Type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add Site Image", @"Augment an Image", @"Augment a Saved Image", nil];
    [s showFromTabBar: self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex])
        return;
        
    _imageIsSiteImage = (buttonIndex == 0);
    
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

- (void)takePicture:(id)sender
{
    [_picker takePicture];
}

- (IBAction)doneTakingPictures:(id)sender
{
    [self dismissModalViewControllerAnimated: YES];
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


#pragma mark - InfoView Button Actions
- (IBAction)processImagesButtonTapped:(id)sender
{
    // Show an alert view to affirm the user actually wants to process.
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to process your base images?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [av show];
    
    // TODO: Show the processing screen;
}

- (IBAction)addOverlayButtonTapped:(id)sender
{
    
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];            
            break;
        case 1:
            [[ARManager shared] processSite:_site.identifier withCompletionBlock:^{
                NSLog(@"Site processing completed");
            }];

            break;
        default:
            break;
    }
}


@end
