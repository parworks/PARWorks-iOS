//
//  EPViewController.h
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

#import <UIKit/UIKit.h>
#import "GRCameraOverlayView.h"
#import "ARAugmentedView.h"
#import "AROverlayView.h"
#import "ARAugmentedPhotoSource.h"

@interface EPViewController : UIViewController <UIAlertViewDelegate, GRCameraOverlayViewDelegate, ARAugmentedViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    GRCameraOverlayView * __strong _cameraOverlayView;
    __weak IBOutlet ARAugmentedView * augmentedView;
    __weak IBOutlet UIButton        * cameraButton;

    NSObject<ARAugmentedPhotoSource>* _augmentedPhotoSource;
    ARAugmentedPhoto *_curAugmentedPhoto;
    BOOL _loaded;
}

- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)didReceiveMemoryWarning;
- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)shouldAutorotate;

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

#pragma mark - Presentation

- (void)showCameraPicker;
- (UIImagePickerController *)imagePicker;

#pragma mark - User Interaction

- (IBAction)handleCameraButtonTapped:(id)sender;

#pragma mark - Animations

- (void)augmentProcessStarted;
- (void)augmentProcessFinishedWithPhoto:(ARAugmentedPhoto *)photo;

#pragma mark - AROverlayViewAnimationDelegate

- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent;
- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent;

#pragma mark - ARAugmentedViewDelegate

- (AROverlayView *)overlayViewForOverlay:(AROverlay *)overlay;

#pragma mark - GRColorPickerDelegate

- (void)didPickColor:(UIColor *)color;

@end
