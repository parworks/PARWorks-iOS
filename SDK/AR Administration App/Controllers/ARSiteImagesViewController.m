//
//  ARSiteImagesViewController.m
//  PARWorks iOS SDK
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


#import "ARSiteImagesViewController.h"
#import "ARPhotoViewController.h"
#import "HDAR.h"

@implementation ARSiteImagesViewController

@synthesize site = _site;
@synthesize gridView = _gridView;

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
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [self setGridView:nil];
    [super viewDidUnload];
}

- (void)reloadData
{
    [_gridView reloadData];
}

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
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)addPhoto:(id)sender
{
    UIActionSheet * s = [[UIActionSheet alloc] initWithTitle:@"Image Type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Site Image", @"Augmented Image", @"Augmented Image from Library", nil];
    [s showFromTabBar: self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex])
        return;
        
    _imageIsSiteImage = (buttonIndex == 0);
    
    _picker = [[UIImagePickerController alloc] init];
    [_picker setDelegate: self];

    if ((buttonIndex != 2) && ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]))
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentModalViewController: _picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * img = [info objectForKey: UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated: YES];

    if (_imageIsSiteImage) {
        [_site addImage: img];
    } else {
        [_site augmentImage: img];
    }
}

@end
