//
//  DMRotatableView.m
//  SquareCam 
//
//  Created by Demetri Miller on 5/1/13.
//
//

#import "ARCameraViewUtil.h"
#import "DMRotatableCameraHUD.h"

@implementation DMRotatableCameraHUD

CGFloat UIDeviceOrientationAngleOfOrientation(UIDeviceOrientation orientation);


#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self sharedInit];
}

- (void)sharedInit
{
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Interaction
/** We only want to respond to user events that occur within
    the bounds of one of our subviews.
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *v in self.subviews) {
        CGPoint convertedPoint = [self convertPoint:point toView:v];
        if ([v pointInside:convertedPoint withEvent:event]) {
            return [super hitTest:point withEvent:event];
        }
    }
    return nil;
}

#pragma mark - Notifications
- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (deviceOrientation != UIDeviceOrientationFaceDown &&
        deviceOrientation != UIDeviceOrientationFaceUp &&
        deviceOrientation != UIDeviceOrientationUnknown) {
        [UIView animateWithDuration:0.4 animations:^{
            [self rotateAccordingToDeviceOrientation];
        }];
    }
}


#pragma mark - Layout
- (void)rotateAccordingToDeviceOrientation
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    CGFloat angle = UIDeviceOrientationAngleOfOrientation(deviceOrientation);
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    CGRect frame = self.superview.bounds;
    
    [self setIfNotEqualTransform:transform frame:frame];
}

- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame
{
    if (!CGAffineTransformEqualToTransform(self.transform, transform)) {
        self.transform = transform;
    }
    
    if (!CGRectEqualToRect(self.frame, frame)) {
        self.frame = frame;
    }
}

- (UIInterfaceOrientation)currentDisplayedInterfaceOrientation
{
    CGFloat angle = UIDeviceOrientationAngleOfOrientation([[UIDevice currentDevice] orientation]);
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (angle == M_PI) {
        orientation = UIInterfaceOrientationPortraitUpsideDown;
    } else if (angle == M_PI_2) {
        orientation = UIInterfaceOrientationLandscapeLeft;
    } else if (angle == -M_PI_2) {
        orientation = UIInterfaceOrientationLandscapeRight;
    }
    
    return orientation;
}


CGFloat UIDeviceOrientationAngleOfOrientation(UIDeviceOrientation orientation)
{
    CGFloat angle;
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }
    
    return angle;
}


@end
