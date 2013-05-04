//
//  GRCameraOverlayToolbar.m
//  ARCore
//
//  Created by Demetri Miller on 2/13/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "GRCameraOverlayToolbar.h"
#import "NSBundle+ARCoreResources.h"
#import "UIImage+ARCoreResources.h"

@implementation GRCameraOverlayToolbar
{
    AVCaptureDevice *_defaultVideoDevice;
}


#pragma mark - Lifecycle
+ (id)toolbarFromXIB
{
    CGFloat windowHeight = [[UIApplication sharedApplication] keyWindow].bounds.size.height;
    NSString *nibName = (windowHeight > 480) ? @"GRCameraOverlayToolbar_4_0" : @"GRCameraOverlayToolbar_3_5";
        
    GRCameraOverlayToolbar *toolbar = [[[NSBundle arCoreResourcesBundle] loadNibNamed:nibName owner:nil options:nil] objectAtIndex:0];
    return toolbar;
}

- (void)awakeFromNib
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _defaultVideoDevice = device;
    
    [self setupViews];
    [self registerForNotifications];
}

- (void)setupViews
{
    // Set up the camera button
    CGFloat windowHeight = [[UIApplication sharedApplication] keyWindow].bounds.size.height;
    NSString *cameraIconName = (windowHeight > 480) ? @"camera_icon_4.0.png" : @"camera_icon_3.5.png";
    
    UIImage *image = [UIImage arCoreImageNamed:cameraIconName];
    _cameraIcon = [[UIImageView alloc] initWithImage:image];
    _cameraIcon.center = CGPointMake(_cameraButton.bounds.size.width/2, _cameraButton.bounds.size.height/2);
    _cameraIcon.userInteractionEnabled = NO;
    [_cameraButton addSubview:_cameraIcon];
    
    [self updateFlashImage];
}

- (void)dealloc
{
    @try {
        [_defaultVideoDevice removeObserver:self forKeyPath:@"flashMode"];
    }
    @catch (NSException *exception) {}
    @finally {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


#pragma mark - Notifications
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayoutForCurrentOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [_defaultVideoDevice addObserver:self forKeyPath:@"flashMode" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"flashMode"]) {
        [self updateFlashImage];
    }
}


#pragma mark - Layout
- (void)relayoutForCurrentOrientation:(NSNotification *)note
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    CGFloat rotateAngle;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            rotateAngle = 0;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            rotateAngle = -M_PI/2.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            rotateAngle = M_PI/2.0f;
            break;
        default: // do nothing
            return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform t = CGAffineTransformMakeRotation(rotateAngle);
        UIWindow *mainWindow = [[UIApplication sharedApplication] windows][0];
        if (mainWindow.bounds.size.height > 480) {
            _cameraButton.transform = t;
        } else {
            _cameraIcon.transform = t;
        }
                
        _flashButton.transform = t;
        _cancelButton.transform = t;
    }];
}

#pragma mark - View Updates
- (NSString *)flashImageName
{
    AVCaptureFlashMode flashMode = [[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] flashMode];
    NSString *name;
    switch (flashMode) {
        case AVCaptureFlashModeAuto:
            name = @"camera_flash_auto";
            break;
        case AVCaptureFlashModeOff:
            name = @"camera_flash_off";
            break;
        case AVCaptureFlashModeOn:
            name = @"camera_flash_on";
            break;
        default:
            break;
    }
    
    CGFloat windowHeight = [[UIApplication sharedApplication] keyWindow].bounds.size.height;
    if (windowHeight > 480) {
        name = [name stringByAppendingString:@"_4.png"];
    } else {
        name = [name stringByAppendingString:@"_3.5.png"];
    }
    return name;
}

- (void)updateFlashImage
{
    NSString *flashImageName = [self flashImageName];
    [_flashButton setImage:[UIImage arCoreImageNamed:flashImageName] forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage arCoreImageNamed:[flashImageName stringByReplacingOccurrencesOfString:@".png" withString:@"_pressed.png"]] forState:UIControlStateHighlighted];
}

@end
