//
//  GRGraffitiCameraOverlayView.h
//  Graffiti
//
//  Created by Demetri Miller on 11/4/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARAugmentedPhoto;
@class ARSite;
@class ARAugmentedView;
@class GRCameraOverlayToolbar;
@class MBProgressHUD;

@interface GRCameraOverlayView : UIView <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    ARAugmentedPhoto *_augmentedPhoto;
    ARAugmentedView  *_augmentedView;
    
    UITapGestureRecognizer  *_tap;
    MBProgressHUD           *_progressHUD;
    CALayer                 *_takenBlackLayer;
    CALayer                 *_takenPhotoLayer;
    NSTimeInterval          _pickerFinishedTimestamp;
}

@property(nonatomic, strong) GRCameraOverlayToolbar *toolbar;
@property(nonatomic, weak) UIImagePickerController *imagePicker;
@property(nonatomic, weak) ARSite *site;

- (UIImagePickerControllerCameraFlashMode)flashModeFromDefaults;

@end





