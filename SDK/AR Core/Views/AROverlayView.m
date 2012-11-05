//
//  AROverlayView.m
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
#import "AROverlayUtil.h"
#import "AROverlayView.h"
#import "AROverlayPoint.h"
#import "AROverlay.h"

@implementation AROverlayView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"%@ -- %@ - Cannot init with this method.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return nil;
}

- (id)initWithPoints:(NSArray *)points
{
    CGRect frame = [AROverlayUtil boundingFrameForPoints:points];
    return [self initWithFrame:frame points:points];
}

- (id)initWithOverlay:(AROverlay*)model
{
    return [self initWithFrame:CGRectMake(0, 0, 200, 200) points:[model points]];
}

- (id)initWithFrame:(CGRect)frame points:(NSArray *)points
{
    self = [super initWithFrame:frame];
    if (self) {
        _attachmentStyle = AROverlayAttachmentStyle_Skew;
        self.userInteractionEnabled = YES;
        self.points = points;
        
        CGRect overlayBounds = self.bounds;
        self.layer.anchorPoint = CGPointMake(0, 0);
        self.layer.frame = overlayBounds;
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowRadius = 3.0;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    
    return self;
}


#pragma mark - Presentation
- (void)focusInParent:(ARAugmentedView *)parent
{
    if (_animDelegate) {
        [_animDelegate focusOverlayView:self inParent:parent];
    }
}

- (void)unfocusInParent:(ARAugmentedView *)parent
{
    if (_animDelegate) {
        [_animDelegate unfocusOverlayView:self inParent:parent];
    }
}


#pragma mark - Transforms
- (void)addDemoSubviewToOverlay
{
    UIWebView *wv = [[UIWebView alloc] initWithFrame:self.bounds];
    wv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    wv.scalesPageToFit = YES;
    wv.opaque = NO;
    [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://foundry376.com/hdar/index.html"]]];
    wv.userInteractionEnabled = NO;
    [self addSubview:wv];
}

- (void)applyAttachmentStyleWithParent:(ARAugmentedView *)parent
{
    self.scaledPoints = [AROverlayUtil scaledOverlayPointsForPoints:_points withScaleFactor:parent.overlayScaleFactor];
    switch (_attachmentStyle) {
        case AROverlayAttachmentStyle_Skew:
            [self applySkewStyle];
            break;
        case AROverlayAttachmentStyle_Bounded:
            [self applyBoundedStyle];
            break;
        case AROverlayAttachmentStyle_Centered:
            [self applyCenteredStyle];
            break;
            
        default:
            break;
    }
}

- (void)applySkewStyle
{
    
    // Apply the transform
    AROverlayPoint *tl = [_scaledPoints objectAtIndex:0];
    AROverlayPoint *tr = [_scaledPoints objectAtIndex:1];
    AROverlayPoint *br = [_scaledPoints objectAtIndex:2];
    AROverlayPoint *bl = [_scaledPoints objectAtIndex:3];
    
    CATransform3D transform = [AROverlayUtil rectToQuad:self.bounds
                                                quadTLX:tl.x quadTLY:tl.y
                                                quadTRX:tr.x quadTRY:tr.y
                                                quadBLX:bl.x quadBLY:bl.y
                                                quadBRX:br.x quadBRY:br.y];
    self.layer.transform = transform;
}

- (void)applyBoundedStyle
{
    CGRect frame = [AROverlayUtil boundingFrameForPoints:_scaledPoints];
    self.frame = frame;
}

- (void)applyCenteredStyle
{
    
}


#pragma mark - Convenience


@end