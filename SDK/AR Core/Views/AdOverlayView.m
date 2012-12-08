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
#import "AdOverlayView.h"

@implementation AdOverlayView

- (id)initWithFrame:(CGRect)frame points:(NSArray *)points andMedia:(NSString*)media ofType:(NSString*)mediaType withWebTarget:(NSURL*)webURL
{
    self = [super initWithFrame:frame points:points];
    if (self) {
        [self setMedia: media];
        [self setMediaType: mediaType];
        [self setWebURL: webURL];
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.backgroundColor = [UIColor clearColor];
    [self.layer setShadowPath: [UIBezierPath bezierPathWithRect:self.bounds].CGPath];
    [self.layer setShadowOpacity: 0.0];
    [self.layer setShadowRadius:10];
    [self.layer setShadowColor: [[UIColor cyanColor] CGColor]];
    
    self.animDelegate = self;
    self.thumbnail = [[UIImageView alloc] initWithFrame:self.bounds];
    _thumbnail.userInteractionEnabled = NO;
    _thumbnail.image = [UIImage imageNamed: [NSString stringWithFormat:@"%@.png", _media]];
    [self addSubview:_thumbnail];
   
    if (_webURL) {
        _webView = [[UIWebView alloc] initWithFrame: self.bounds];
        [_webView setScalesPageToFit: YES];
        [_webView loadRequest: [NSURLRequest requestWithURL: _webURL]];
        [_webView setAlpha: 0];
        [self addSubview: _webView];

    } else {
        NSURL * b = [[NSBundle mainBundle] URLForResource:@"Broll_OhWhataNight" withExtension:@"mp4"];
        _player = [[MPMoviePlayerController alloc] initWithContentURL: b];
        _player.view.alpha = 0;
        _player.view.frame = self.bounds;
        [self addSubview: _player.view];
    }
}


#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    if (self.thumbnail.image == nil) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetShadowWithColor(context, CGSizeZero, 20.0, [UIColor cyanColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 10);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 20, 20) cornerRadius:5];
        CGContextAddPath(context, path.CGPath);
        CGContextStrokePath(context);        
    } else {
        self.layer.borderWidth = 5.0;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.shadowOpacity = 1.0;
    }
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
            _player.view.alpha = 1.0;
            _webView.alpha = 1.0;
            
            if (_thumbnail.image == nil) {
                self.layer.borderWidth = 5.0;
                self.layer.borderColor = [UIColor whiteColor].CGColor;
                self.layer.shadowOpacity = 1.0;
            }
            
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
                        [_player play];
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
        overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, .5, .5, .5);
        overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:overlayView withParent:parent.overlayImageView];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            _player.view.alpha = 0.0;
            _webView.alpha = 0.0;

            if (_thumbnail.image == nil) {
                self.layer.borderWidth = 0.0;
                self.layer.borderColor = [UIColor whiteColor].CGColor;
                self.layer.shadowOpacity = 0.0;
            }

            [_player stop];
            overlayView.layer.position = CGPointZero;
            [overlayView applyAttachmentStyleWithParent:parent];
        } completion:^(BOOL finished) {
        }];
    }];
}


@end
