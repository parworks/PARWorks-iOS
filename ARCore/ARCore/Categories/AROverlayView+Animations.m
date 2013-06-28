//
//  AROverlayView+Animations.m
//  ViewerDemo
//
//  Created by Demetri Miller on 1/31/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "ARAugmentedView.h"
#import "AROverlayView+Animations.h"
#import "AROverlayUtil.h"

@implementation AROverlayView (Animations)

- (void)animateBounceFocusWithParent:(ARAugmentedView *)parent
                       centeredBlock:(AROverlayViewAnimationFocusCenter)centered
                            complete:(AROverlayViewAnimationFocusCompletion)complete
{
    [UIView animateWithDuration:0.3 animations:^{
        self.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.5, 0.5, 0.5);
        self.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            if (centered) {
                centered();
            }
            
            self.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.2, 1.2, 1.2);
            self.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.9, 0.9, 0.9);
                self.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.1, 1.1, 1.1);
                    self.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        self.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 1.0);
                        self.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
                    } completion:^(BOOL finished) {
                        if (complete) {
                            complete();
                        }
                    }];
                }];
            }];
        }];
    }];

}

- (void)animateBounceUnfocusWithParent:(ARAugmentedView *)parent
                       uncenteredBlock:(AROverlayViewAnimationUnfocusCenter)uncentered
                              complete:(AROverlayViewAnimationFocusCompletion)complete
{
    [UIView animateWithDuration:0.3 animations:^{
        // Shrink the view and then animate it back to it's proper position
        self.layer.transform = CATransform3DScale(CATransform3DIdentity, .5, .5, .5);
        self.layer.position = [AROverlayUtil focusedCenterForOverlayView:self withParent:parent.overlayImageView];
        self.layer.opacity = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            if (uncentered) {
                uncentered();
            }
            self.layer.position = CGPointZero;
            self.layer.opacity = 1;
            [self layoutWithinParent:parent];
        } completion:^(BOOL finished) {
            if (complete) {
                complete();
            }
        }];
    }];
}

@end
