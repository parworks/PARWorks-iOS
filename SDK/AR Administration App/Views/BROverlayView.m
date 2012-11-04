//
//  BROverlayView.m
//  PAR Works iOS SDK
//
//  Copyright 2012 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "AROverlayUtil.h"
#import "ARAugmentedView.h"
#import "BROverlayView.h"

@implementation BROverlayView

- (id)initWithFrame:(CGRect)frame points:(NSArray *)points
{
    self = [super initWithFrame:frame points:points];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.animDelegate = self;
    
    UIWebView *wv = [[UIWebView alloc] initWithFrame:self.bounds];
    wv.userInteractionEnabled = YES;
    [self addSubview:wv];
    [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://nyan.cat/"]]];
    wv.scalesPageToFit = YES;
    wv.userInteractionEnabled = NO;
    
    self.thumbnail = [[UIImageView alloc] initWithFrame:self.bounds];
    _thumbnail.userInteractionEnabled = NO;
    _thumbnail.image = [UIImage imageNamed:@"2br.png"];
    //[self addSubview:_thumbnail];
}


#pragma mark - AROverlayViewAnimationDelegate
- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    // God help whoever has to read this...
    // All we're doing is daisy-chaining together animations
    // to animate the overlay to the center of the screen (first animation) and then scale it
    // to full size with a bounce animation (the rest of the animations).
    
    [UIView animateWithDuration:0.3 animations:^{
        overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.5, 0.5, 0.5);
        overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:overlayView withParent:parent.overlayImageView];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            _thumbnail.alpha = 0.0;
            overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.2, 1.2, 1.2);
            overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:overlayView withParent:parent.overlayImageView];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.9, 0.9, 0.9);
                overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:overlayView withParent:parent.overlayImageView];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.1, 1.1, 1.1);
                    overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:overlayView withParent:parent.overlayImageView];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 1.0);
                        overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:overlayView withParent:parent.overlayImageView];
                    } completion:^(BOOL finished) {
                    }];
                }];
            }];
        }];
    }];
}

- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    [UIView animateWithDuration:0.3 animations:^{
        // Shrink the view and then animate it back to it's proper position
        overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, .5, .5, .5);;
        overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:overlayView withParent:parent.overlayImageView];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            _thumbnail.alpha = 1.0;
            overlayView.layer.position = CGPointZero;
            [overlayView applyAttachmentStyleWithParent:parent];
        } completion:^(BOOL finished) {
        }];
    }];
}


@end
