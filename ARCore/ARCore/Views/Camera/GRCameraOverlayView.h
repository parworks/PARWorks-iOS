//
//  GRGraffitiCameraOverlayView.h
//  Graffiti
//
//  Created by Demetri Miller on 11/4/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARAugmentedPhotoSource.h"

@class ARAugmentedPhoto;
@class ARCameraOverlayTooltip;
@class ARSite;
@class ARAugmentedView;
@class GRCameraOverlayToolbar;
@class MBProgressHUD;

@protocol GRCameraOverlayViewDelegate <NSObject>

@optional
- (id)contentsForWaitingOnImage:(UIImage*)img;

@required
- (void)dismissImagePicker;

@end

@interface GRCameraOverlayView : UIView <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    ARAugmentedView  *_augmentedView;
    
    UITapGestureRecognizer  *_tap;
    MBProgressHUD           *_progressHUD;
    CALayer                 *_takenBlackLayer;
    CALayer                 *_takenPhotoLayer;
    NSTimeInterval          _pickerFinishedTimestamp;
    
    BOOL                    _isiPhone5;
}

@property(nonatomic, strong) ARAugmentedPhoto *augmentedPhoto;
@property(nonatomic, strong) GRCameraOverlayToolbar *toolbar;
@property(nonatomic, strong) ARCameraOverlayTooltip *tooltip;
@property(nonatomic, weak) UIImagePickerController *imagePicker;
@property(nonatomic, weak) NSObject<GRCameraOverlayViewDelegate> * delegate;
@property(nonatomic, strong) NSMutableArray *siteSet;
@property(nonatomic, weak) NSObject <ARAugmentedPhotoSource> *site;

/// Convenience Class Methods
+ (UIImagePickerController *)defaultImagePicker;
- (CGRect)cameraArea;
- (ARAugmentedView*)augmentedView;

- (void)sharedInit;

- (void)showTooltipWithString:(NSString *)string;
- (UIImagePickerControllerCameraFlashMode)flashModeFromDefaults;


#pragma mark - Convenience

- (void)showAugmentingInterface;
- (void)resetToLiveCameraInterface;

@end





