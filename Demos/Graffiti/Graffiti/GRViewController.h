//
//  GRViewController.h
//  Graffiti
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
#import "ARAugmentedView.h"
#import "AROverlayView.h"

@class ARSite;
@class GRBrushPickerFolderView;
@class GRColorPickerFolderView;
@class GRGraffitiLoadingView;
@class GRGraffitiCameraOverlayView;
@class GRGraffitiView;

@interface GRViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, ARAugmentedViewDelegate, AROverlayViewAnimationDelegate>
{
    GRGraffitiCameraOverlayView * __strong _cameraOverlayView;
    
    __weak IBOutlet UISlider *brushSizeSlider;
    __weak IBOutlet UIView *brushControls;
    __weak IBOutlet ARAugmentedView *augmentedView;
    __weak IBOutlet UIButton *colorPickerButton;
    __weak IBOutlet UIButton *brushPickerButton;
    __weak IBOutlet UIButton *cameraButton;

    UIControl *_folderDimView;
    GRColorPickerFolderView *_colorPicker;
    GRBrushPickerFolderView *_brushPicker;
    
    UIImagePickerController *_picker;
    UIImage *_image;

    __weak GRGraffitiView *_focusedGraffitiView;
    NSArray *_graffitiViews;
    GRGraffitiLoadingView *_loadingView;
    ARSite *_site;
    BOOL _firstLoad;
}

- (IBAction)handleColorPickerButtonTapped:(id)sender;
- (IBAction)handleBrushPickerButtonTapped:(id)sender;
- (IBAction)handleCameraButtonTapped:(id)sender;

- (void)enablePaintControlsWithGraffitiView:(GRGraffitiView *)view;
- (void)disablePaintControlsWithGraffitiView:(GRGraffitiView *)view;

@end
