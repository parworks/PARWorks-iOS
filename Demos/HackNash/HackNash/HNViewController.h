//
//  HNViewController.h
//  HackNash
//
//  Created by Demetri Miller on 10/12/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARAugmentedView.h"

@class HNBrushPickerFolderView;
@class HNColorPickerFolderView;
@class HNGraffitiLoadingView;
@class HNGraffitiView;

@interface HNViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, ARAugmentedViewDelegate>
{
    IBOutlet UIView *_cameraOverlayView;
    __weak IBOutlet UISlider *brushSizeSlider;
    __weak IBOutlet UIView *brushControls;
    __weak IBOutlet ARAugmentedView *augmentedView;
    __weak IBOutlet UIButton *colorPickerButton;
    __weak IBOutlet UIButton *brushPickerButton;
    __weak IBOutlet UIButton *cameraButton;

    UIControl *_folderDimView;
    HNColorPickerFolderView *_colorPicker;
    HNBrushPickerFolderView *_brushPicker;
    
    UIImagePickerController *_picker;
    UIImage *_image;

    __weak HNGraffitiView *_focusedGraffitiView;
    NSArray *_graffitiViews;
    HNGraffitiLoadingView *_loadingView;
    
    BOOL _firstLoad;
}

- (IBAction)takePicture:(id)sender;
- (IBAction)handleColorPickerButtonTapped:(id)sender;
- (IBAction)handleBrushPickerButtonTapped:(id)sender;
- (IBAction)handleCameraButtonTapped:(id)sender;

- (void)enablePaintControlsWithGraffitiView:(HNGraffitiView *)view;
- (void)disablePaintControlsWithGraffitiView:(HNGraffitiView *)view;

@end
