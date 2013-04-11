//
//  EPViewController.m
//  EasyPAR
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


#import <MobileCoreServices/MobileCoreServices.h>
#import "EPViewController.h"
#import "EPAppDelegate.h"
#import "ARLoadingView.h"
#import "ASIHTTPRequest.h"
#import "AROverlayView+Animations.h"
#import "UIViewAdditions.h"
#import "UIImageView+AnimationAdditions.h"
#import "ARMultiSite.h"
#import "PARWorks.h"


#define WIDTH 20
#define HEIGHT 20

#define CAMERA_TRANSFORM_SCALE 1.25


@implementation EPViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.presentedViewController isKindOfClass:[UIImagePickerController class]] &&
        [_cameraOverlayView augmentedPhoto] && [[_cameraOverlayView augmentedPhoto] response] == BackendResponseFinished &&
        [[[_cameraOverlayView augmentedPhoto] overlays] count] > 0) {
        augmentedView.overlayImageView.image = nil;
        [augmentedView.outlineViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [augmentedView.overlayViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [augmentedView.overlayTitleViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        [augmentedView.loadingView startAnimating];
        _curAugmentedPhoto = [_cameraOverlayView augmentedPhoto];

        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (_curAugmentedPhoto.response == BackendResponseFinished) {
                augmentedView.augmentedPhoto = _curAugmentedPhoto;
                [self augmentProcessFinishedWithPhoto:_curAugmentedPhoto];
            }
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_loaded){
        _loaded = YES;
        cameraButton.layer.contentsScale = [UIScreen mainScreen].scale;
        cameraButton.layer.shadowColor = [UIColor blackColor].CGColor;
        cameraButton.layer.shadowOffset = CGSizeZero;
        cameraButton.layer.shadowRadius = 4.0;
        cameraButton.layer.shadowOpacity = 1.0;
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showCameraPicker];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return YES;
}


#pragma mark - Rotation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}


#pragma mark - Presentation
- (void)showCameraPicker
{
    _cameraOverlayView = [[GRCameraOverlayView alloc] initWithFrame:self.view.bounds];
    _augmentedPhotoSource = [[ARMultiSite alloc] initWithSiteIdentifiers: @[@"staples-printer2", @"staples-printer3", @"staples-printer9", @"staples-printer5", @"staples-printer6", @"staples-printer7"]];
    _cameraOverlayView.site = _augmentedPhotoSource;
    
    UIImagePickerController *picker = [self imagePicker];
    picker.delegate = _cameraOverlayView;
    _cameraOverlayView.imagePicker = picker;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        picker.cameraOverlayView = _cameraOverlayView;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (UIImagePickerController *)imagePicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = @[(NSString *) kUTTypeImage];
        picker.showsCameraControls = NO;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    return picker;
}


#pragma mark - User Interaction

- (IBAction)handleCameraButtonTapped:(id)sender
{
    [self showCameraPicker];
}


@end