//
//  GRCameraOverlayToolbar.h
//  ARCore
//
//  Created by Demetri Miller on 2/13/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GRCameraOverlayView;

@interface GRCameraOverlayToolbar : UIView

@property(nonatomic, weak) IBOutlet UIButton *cancelButton;
@property(nonatomic, weak) IBOutlet UIButton *flashButton;
@property(nonatomic, weak) IBOutlet UIButton *cameraButton;
@property(nonatomic, strong) UIImageView *cameraIcon;

+ (id)toolbarFromXIBWithParent:(GRCameraOverlayView *)parent;
- (void)updateFlashImageForFlashMode:(UIImagePickerControllerCameraFlashMode)mode withParent:(GRCameraOverlayView *)parent;

@end
