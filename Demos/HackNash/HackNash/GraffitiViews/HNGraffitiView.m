//
//  HNGraffitiView.m
//  Graffiti
//
//  Created by Demetri Miller on 10/13/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "ARAugmentedView.h"
#import "HNGraffitiView.h"
#import "SimplePaintView.h"
#import "HNViewController.h"

@implementation HNGraffitiView

- (id)initWithOverlay:(AROverlay *)model
{
    self = [super initWithFrame:CGRectMake(0, 0, 225, 225) points:model.points];
    if (self) {
        self.animDelegate = self;
        self.backgroundView = [[SimplePaintView alloc] initWithFrame:self.bounds];
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    srand(time(0));
    self.sprayView = [[HNSprayView alloc] initWithFrame:self.bounds animatedRevealImageFormat:@"spray_%d.png" delegate:self];
    [self addSubview:_sprayView];
    _sprayView.hidden = YES;
    
    self.graffitiMask = [[SimplePaintView alloc] initWithFrame:self.bounds];
    _graffitiMask.backgroundColor = [UIColor clearColor];
    _backgroundView.layer.mask = _graffitiMask.layer;
    [self addSubview:_backgroundView];
    
    _graffitiMask.userInteractionEnabled = NO;
    _backgroundView.userInteractionEnabled = NO;
    _sprayView.userInteractionEnabled = NO;
}

- (void)reveal
{
    [self revealWithType:SprayViewRevealType_TopBottom];
}

- (void)revealWithRandomType
{
    [self revealWithType:rand()%SprayViewRevealTypeCount];
}

- (void)revealWithType:(SprayViewRevealType)type
{
    _sprayView.hidden = NO;
    [self bringSubviewToFront:_sprayView];
    [_sprayView revealWithRevealType:type];
}


#pragma mark - AROverlayViewAnimationDelegate
- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    [UIView animateWithDuration:0.3 animations:^{
        overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.5, 0.5, 0.5);
        overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
        self.layer.mask = nil;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.2, 1.2, 1.2);
            overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.9, 0.9, 0.9);
                overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.1, 1.1, 1.1);
                    overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 1.0);
                        overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
                    } completion:^(BOOL finished) {
                        self.userInteractionEnabled = YES;
                        _backgroundView.userInteractionEnabled = YES;
                        [_controller enablePaintControlsWithGraffitiView:self];
                    }];
                }];
            }];
        }];
    }];
}

- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    _backgroundView.userInteractionEnabled = NO;
    [_controller disablePaintControlsWithGraffitiView:self];
    [UIView animateWithDuration:0.3 animations:^{
        // Shrink the view and then animate it back to it's proper position
        overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, .5, .5, .5);
        overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:overlayView withParent:parent.overlayImageView];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [overlayView applyAttachmentStyleWithParent:parent];
            overlayView.layer.position = CGPointZero;
        } completion:^(BOOL finished) {
        }];
    }];
}


#pragma mark - HNSprayViewDelegate

- (void)sprayViewPositionChanged:(CGPoint)position
{
    [_graffitiMask strokedToPoint:position];
}

- (void)sprayViewAnimationEnded
{
    _backgroundView.layer.mask = nil;
}

@end
