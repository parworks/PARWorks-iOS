//
//  BRPopupOverlayView.m
//  PAR Works iOS SDK
//
//  Copyright 2013 PAR Works, Inc.
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


#import "BRPopupOverlayView.h"
#import "AROverlayUtil.h"
#import "ARAugmentedView.h"

@implementation BRPopupOverlayView

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
    
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 3.0;
    
    [self addTarget:self action:@selector(handlePopupTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIWebView *wv = [[UIWebView alloc] initWithFrame:self.bounds];
    wv.userInteractionEnabled = NO;
    [self addSubview:wv];
    [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://thefuckingweather.com"]]];
    
    self.thumbnail = [[UIImageView alloc] initWithFrame:self.bounds];
    _thumbnail.userInteractionEnabled = NO;
    _thumbnail.image = [UIImage imageNamed:@"2br.png"];
    [self addSubview:_thumbnail];
}


#pragma mark - User Interaction
- (void)handlePopupTapped:(id)sender
{
    
}

#pragma mark - AROverlayViewAnimationDelegate
- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    self.popup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _popup.alpha = 0.0;
    _popup.layer.backgroundColor = [UIColor greenColor].CGColor;
    [parent.overlayImageView addSubview:_popup];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectInset(_popup.bounds, 20, 20)];
    v.backgroundColor = [UIColor redColor];
    [_popup addSubview:v];
    
    // Determine where the popup should be positioned in the overlay.
    UIView *superview = parent.overlayImageView;
    CGFloat maxDistX = superview.bounds.size.width - CGRectGetMaxX(overlayView.frame);
    CGFloat maxDistY = superview.bounds.size.height - CGRectGetMaxY(overlayView.frame);
    
    CGFloat anchorX, anchorY;
    anchorX = (maxDistX > CGRectGetMinX(overlayView.frame)) ? 0.0 : 1.0;
    anchorY = (maxDistY > CGRectGetMinY(overlayView.frame)) ? 0.0 : 1.0;

    _popup.layer.anchorPoint = CGPointMake(anchorX, anchorY);
    _popup.layer.position = CGPointMake(CGRectGetMidX(overlayView.frame), CGRectGetMidY(overlayView.frame));

    [self performSelector:@selector(animatePopupVisible:) withObject:overlayView afterDelay:0.1];
}

- (void)animatePopupVisible:(AROverlayView *)overlayView
{
    CAAnimation *animation = [self bounceAnimationForPopup];
    [_popup.layer addAnimation:animation forKey:nil];

    [UIView animateWithDuration:1.0 animations:^{
        _popup.alpha = 1.0;
    }];
}

- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    _popup.alpha = 0.0;
    [_popup removeFromSuperview];
}

- (CAAnimation *)bounceAnimationForPopup
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 1.0;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *timings = [NSMutableArray array];
    NSMutableArray *keytimes = [NSMutableArray array];
    
    //Start
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [values addObject:[NSNumber numberWithFloat:0.5]];
    [timings addObject:timingFunction];
    [keytimes addObject:[NSNumber numberWithFloat:0.0]];
    
    // Bounce up
    [values addObject:[NSNumber numberWithFloat:1.2]];
    [timings addObject:timingFunction];
    [keytimes addObject:[NSNumber numberWithFloat:0.25]];
    
    
    // bounce down
    [values addObject:[NSNumber numberWithFloat:0.9]];
    [timings addObject:timingFunction];
    [keytimes addObject:[NSNumber numberWithFloat:0.5]];
    
    // bounce up
    [values addObject:[NSNumber numberWithFloat:1.1]];
    [timings addObject:timingFunction];
    [keytimes addObject:[NSNumber numberWithFloat:0.75]];
    
    // finish down
    [values addObject:[NSNumber numberWithFloat:1.0]];
    [timings addObject:timingFunction];
    [keytimes addObject:[NSNumber numberWithFloat:1.0]];
    
    animation.values = values;
    animation.timingFunctions = timings;
    animation.keyTimes = keytimes;
    return animation;
}

@end
