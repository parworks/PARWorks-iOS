//
//  ARShapeOverlayView.m
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


#import "ARAugmentedView.h"
#import "AROverlayAnimation.h"
#import "AROverlayPoint.h"
#import "AROverlayUtil.h"
#import "ARShapeOverlayView.h"

@implementation ARShapeOverlayView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame points:(NSArray *)points
{
    self = [super initWithFrame:frame points:points];
    if (self) {
        self.animDelegate = self;
        self.webView = [[UIWebView alloc] initWithFrame:self.bounds];
        _webView.scalesPageToFit = YES;
        _webView.userInteractionEnabled = NO;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        //        [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://foundry376.com/hdar/index.html"]]];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://nyan.cat"]]];
        [self addSubview:_webView];
    }
    return self;
}


#pragma mark - Layout
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _webView.frame = self.bounds;
    [_webView setNeedsDisplay];
    
}


#pragma mark - Masking
- (void)applyAttachmentStyleWithParent:(ARAugmentedView *)parent
{
    [super applyAttachmentStyleWithParent:parent];
    [self applyMaskLayer];
}

- (void)applyMaskLayer
{
    if (!_maskLayer) {
        self.maskLayer = [CAShapeLayer layer];
    }

//    _maskLayer.frame = self.bounds;
    _maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // Scale the points by whatever the bounds of the view are and then
    // normalize the points to zero.
    NSArray *normalizedPoints = [self normalizedPointsForPoints:self.points];
    
    
    for (int i=0; i<normalizedPoints.count; i++) {
        AROverlayPoint *p = [normalizedPoints objectAtIndex:i];
        if (i==0) {
            [path moveToPoint:CGPointMake(p.x, p.y)];
        } else {
            [path addLineToPoint:CGPointMake(p.x, p.y)];
        }
    }
    [path closePath];
    
//    path = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.bounds.size.height/2)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width/2, 0)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height/2)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width/2, self.bounds.size.height)];
    [path closePath];
    
    _maskLayer.path = path.CGPath;
    _maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    [self.layer setMask:_maskLayer];
}

// Normalize the points such that the upper left corner is at 0,0.
- (NSArray *)normalizedPointsForPoints:(NSArray *)points
{
    NSMutableArray *normPts = [NSMutableArray array];

    AROverlayPoint *firstPoint = [points objectAtIndex:0];
    
    for (int i=0; i<points.count; i++) {
        AROverlayPoint *p = [points objectAtIndex:i];
        AROverlayPoint *newP = [[AROverlayPoint alloc] init];
        newP.x = p.x - firstPoint.x;
        newP.y = p.y - firstPoint.y;
        [normPts addObject:newP];
    }
    return normPts;
}


- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    
    [UIView animateWithDuration:0.3 animations:^{
        overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.5, 0.5, 0.5);
        overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:overlayView withParent:parent.overlayImageView];
        self.layer.mask = nil;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
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
        overlayView.layer.transform = CATransform3DScale(CATransform3DIdentity, .5, .5, .5);
        overlayView.layer.position = [AROverlayUtil focusedCenterForOverlayView:overlayView withParent:parent.overlayImageView];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            overlayView.layer.transform = CATransform3DIdentity;
            [overlayView applyAttachmentStyleWithParent:parent];
        } completion:^(BOOL finished) {
        }];
    }];
}



@end
