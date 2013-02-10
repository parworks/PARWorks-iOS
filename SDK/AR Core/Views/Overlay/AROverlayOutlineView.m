//
//  AROverlayOutlineView.m
//  ViewerDemo
//
//  Created by Demetri Miller on 1/31/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayOutlineView.h"
#import "AROverlay.h"
#import "AROverlayPoint.h"
#import "AROverlayUtil.h"
#import "ARAugmentedView.h"

#define kAROverlayOutlineViewAnimationDuration 1.5

@implementation AROverlayOutlineView

#pragma mark - Lifecycle
+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithOverlay:(AROverlay *)overlay
{
    self = [super initWithFrame: CGRectZero];
    if (self) {
        self.clipsToBounds = NO;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        _overlay = overlay;
        
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.masksToBounds = NO;

        if (overlay.boundaryType == AROverlayBoundaryType_Dashed) {
            layer.strokeColor = _overlay.boundaryColor.CGColor;
            layer.lineWidth = 2.0;
            layer.lineDashPattern = @[@4];

        } else if (overlay.boundaryType == AROverlayBoundaryType_Solid) {
            layer.strokeColor = _overlay.boundaryColor.CGColor;
            layer.lineWidth = 2.0;
        }        
    }
    return self;
}

- (void)layoutWithinParent:(ARAugmentedView *)parent
{
    _scaledOutlinePoints = [AROverlayUtil scaledOverlayPointsForPoints:_overlay.points withScaleFactor:parent.overlayScaleFactor];
    self.frame = [AROverlayUtil boundingFrameForPoints: _scaledOutlinePoints];

    _scaledPath = [self outlinePathWithUnnormalizedScaledPoints:_scaledOutlinePoints];
    [self drawAnimated:parent.animateOutlineViewDrawing];
}


#pragma mark - Presentation

- (void)drawAnimated:(BOOL)animated
{
    if (_scaledPath == nil) return;

    CAShapeLayer *l = (CAShapeLayer *)self.layer;
    self.layer.sublayers = nil;

    if (animated) {
        _animationIndex = 0;
        _animationDurations = [self durationsForStrokeAnimation];
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
        anim.duration  = kAROverlayOutlineViewAnimationDuration;
        anim.values = @[@0.0, @1.0];
        [l addAnimation:anim forKey:@"anim"];
        l.path = _scaledPath.CGPath;
        
        [self addVertexBubbleWithPoint:_scaledOutlinePoints[_animationIndex] animated:animated];
        
        CGFloat duration = [_animationDurations[0] floatValue] * kAROverlayOutlineViewAnimationDuration;
        [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(animationSegmentFinished) userInfo:nil repeats:NO];

    } else {
        l.path = _scaledPath.CGPath;
        for (int i=0; i<_scaledOutlinePoints.count; i++) {
            [self addVertexBubbleWithPoint:_scaledOutlinePoints[i] animated:animated];
        }
    }
}

- (void)animationSegmentFinished
{
    _animationIndex++;
    if (_animationIndex < _scaledOutlinePoints.count) {
        [self addVertexBubbleWithPoint:_scaledOutlinePoints[_animationIndex] animated:YES];
        CGFloat duration = [_animationDurations[_animationIndex] floatValue] * kAROverlayOutlineViewAnimationDuration;
        [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(animationSegmentFinished) userInfo:nil repeats:NO];
    }
}


#pragma mark - Convenience

- (UIBezierPath *)outlinePathWithUnnormalizedScaledPoints:(NSArray *)scaledPoints
{
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    
    for (AROverlayPoint *p in scaledPoints) {
        p.x -= x;
        p.y -= y;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    AROverlayPoint *p = scaledPoints[0];
    [path moveToPoint:CGPointMake(p.x, p.y)];
    for (int i=1; i<scaledPoints.count; i++) {
        p = scaledPoints[i];
        [path addLineToPoint:CGPointMake(p.x, p.y)];
    }
    [path closePath];
    return path;
}

- (NSArray *)durationsForStrokeAnimation
{
    NSMutableArray *durations = [NSMutableArray array];
    
    CGFloat totalDistance = 0;
    CGFloat distances[_scaledOutlinePoints.count];

    for (int i=0; i<_scaledOutlinePoints.count; i++) {
        AROverlayPoint *start = _scaledOutlinePoints[i];
        AROverlayPoint *end = _scaledOutlinePoints[(i+1)%_scaledOutlinePoints.count];
        
        CGFloat d = sqrtf(powf(start.x - end.x, 2) + powf(start.y - end.y, 2));
        totalDistance += d;
        distances[i] = d;
    }
    
    for (int i=0; i<_scaledOutlinePoints.count; i++) {
        [durations addObject:@(distances[i]/totalDistance)];
    }
    return durations;
}

- (void)addVertexBubbleWithPoint:(AROverlayPoint *)p animated:(BOOL)animated
{
    UIView * bubble = [[UIView alloc] initWithFrame: CGRectMake(p.x - 3, p.y - 3, 6, 6)];
    bubble.backgroundColor = _overlay.boundaryColor;
    bubble.layer.cornerRadius = 3;
    [self addSubview: bubble];
    
    CGFloat duration = animated ? 0.2 : 0.0;
    if (duration) {
        bubble.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:duration animations:^{
            bubble.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            if (!finished)
                return; // view may have been removed from superview—bubble is now a bad ptr
            [UIView animateWithDuration:duration animations:^{
                bubble.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}



@end
