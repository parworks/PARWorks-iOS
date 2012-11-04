//
//  GRGraffitiCameraOverlayView.m
//  Graffiti
//
//  Created by Demetri Miller on 11/4/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "GRCameraOverlayView.h"
#import "UIView+Layout.h"

@implementation GRCameraOverlayView

- (id)initWithFrame:(CGRect)frame
{
    // The overlayView should always be the same frame as the UIWindow.
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    self = [super initWithFrame:window.frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.userInteractionEnabled = YES;
    
    self.augmentButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width/2 - 30, self.height - 70, 60, 60)];
    _augmentButton.backgroundColor = [UIColor clearColor];
    [_augmentButton setImage:[UIImage imageNamed:@"camera-icon.png"] forState:UIControlStateNormal];
    [_augmentButton setImage:[UIImage imageNamed:@"camera-icon-down.png"] forState:UIControlStateHighlighted];
    [_augmentButton setImage:[UIImage imageNamed:@"camera-icon-down.png"] forState:UIControlStateSelected];
    [_augmentButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _buttonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera-graphic.png"]];
    _buttonImageView.center = CGPointMake(_augmentButton.width/2, _augmentButton.height/2);
    _buttonImageView.userInteractionEnabled = NO;
    
    [_augmentButton addSubview:_buttonImageView];
    [self addSubview:_augmentButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self handleOrientationChange:nil];
//    [self layoutAugmentButtonForCurrentFrame];
}

- (void)buttonTapped
{
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
//    [self layoutAugmentButtonForCurrentFrame];
}

- (void)layoutAugmentButtonForCurrentFrame
{
//    _augmentButton.position = CGPointMake(self.width/2, self.height - (_augmentButton.height/2) - 10);
}

- (void)handleOrientationChange:(NSNotification *)note
{
    UIInterfaceOrientation orientation = [UIDevice currentDevice].orientation;
    // Default orientation for the camera overlay is portrait...

    CGFloat rotateAngle;
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            break;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _buttonImageView.transform = CGAffineTransformMakeRotation(rotateAngle);
    }];

}

@end
