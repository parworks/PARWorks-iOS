//
//  ARViewController.m
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


#import "ARPhotoViewController.h"
#import "AROverlayPoint.h"
#import "AROverlayUtil.h"
#import "ARAugmentedView.h"
#import "AROverlay.h"
#import "AROverlayView.h"
#import "AdOverlayView.h"

@implementation ARPhotoViewController

@synthesize photo = _photo;
@synthesize photoView = _photoView;


- (id)initWithAugmentedPhoto:(ARAugmentedPhoto*)p
{
    self = [super init];
    if (self){
        self.photo = p;
        self.overlayAnimation = [[AROverlayAnimation alloc] init];
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // start listening for changes to the augmented photo object
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoChanged:) name:NOTIF_AUGMENTED_PHOTO_UPDATED object: _photo];
    [_photoView setAugmentedPhoto: _photo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    [[self.navigationController navigationBar] setBarStyle: UIBarStyleBlackTranslucent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    [[self.navigationController navigationBar] setBarStyle: UIBarStyleDefault];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super viewDidUnload];
}

- (void)photoChanged:(NSNotificationCenter*)notif
{
    if ([_photo response] == BackendResponseFailed) {
        UIAlertView * v = [[UIAlertView alloc] initWithTitle:@"Processing Failed." message:@"The image could not be processed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [v show];
    }
    
    [_photoView setAugmentedPhoto: _photo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark - ARAugmentedViewDelegate
- (AROverlayView *)overlayViewForOverlay:(AROverlay *)overlay
{
    AdOverlayView *view;
    view = [[AdOverlayView alloc] initWithOverlay:overlay];
    view.attachmentStyle = AROverlayAttachmentStyle_Skew;
    view.backgroundColor = [UIColor colorWithRed:0 green:0.2 blue:1 alpha:0.5];
    return view;
}


@end
