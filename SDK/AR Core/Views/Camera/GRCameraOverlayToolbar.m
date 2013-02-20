//
//  GRCameraOverlayToolbar.m
//  PARViewer
//
//  Created by Demetri Miller on 2/13/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "GRCameraOverlayToolbar.h"
#import "GRCameraOverlayView.h"


@implementation GRCameraOverlayToolbar

+ (id)toolbarFromXIBWithParent:(GRCameraOverlayView *)parent
{
    NSString *nibName;
    NSString *cameraIconName;
    if (parent.frame.size.height > 480) {
        nibName = @"GRCameraOverlayToolbar_4_0";
    } else {
        nibName = @"GRCameraOverlayToolbar_3_5";
        cameraIconName = @"camera_icon_3.5.png";
    }
    
    GRCameraOverlayToolbar *toolbar = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] objectAtIndex:0];
    [toolbar updateFlashImageForFlashMode:[parent flashModeFromDefaults] withParent:parent];
    
    UIButton *camera = toolbar.cameraButton;
    UIImage *image = [UIImage imageNamed:cameraIconName];
    toolbar.cameraIcon = [[UIImageView alloc] initWithImage:image];
    toolbar.cameraIcon.center = CGPointMake(camera.bounds.size.width/2, camera.bounds.size.height/2);
    toolbar.cameraIcon.userInteractionEnabled = NO;
    [camera addSubview:toolbar.cameraIcon];
    
    return toolbar;
}

+ (NSString *)flashImageNameWithParent:(GRCameraOverlayView *)parent
{
    UIImagePickerControllerCameraFlashMode mode = [parent flashModeFromDefaults];
    NSString *name;
    switch (mode) {
        case UIImagePickerControllerCameraFlashModeAuto:
            name = @"camera_flash_auto";
            break;
        case UIImagePickerControllerCameraFlashModeOff:
            name = @"camera_flash_off";
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            name = @"camera_flash_on";
            break;
        default:
            break;
    }
    
    if (parent.frame.size.height > 480) {
        name = [name stringByAppendingString:@"_4.png"];
    } else {
        name = [name stringByAppendingString:@"_3.5.png"];
    }
    return name;
}

- (void)updateFlashImageForFlashMode:(UIImagePickerControllerCameraFlashMode)mode withParent:(GRCameraOverlayView *)parent
{
    NSString *flashImageName = [[self class] flashImageNameWithParent:parent];
    [_flashButton setImage:[UIImage imageNamed:flashImageName] forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage imageNamed:[flashImageName stringByReplacingOccurrencesOfString:@".png" withString:@"_pressed.png"]] forState:UIControlStateHighlighted];
}

@end
