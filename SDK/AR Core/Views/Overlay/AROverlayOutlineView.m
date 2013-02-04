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

#define kAROverlayOutlineViewAnimationDuration 3.0

@implementation AROverlayOutlineView

#pragma mark - Lifecycle
+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithOverlay:(AROverlay *)overlay scaleFactor:(CGFloat)scaleFactor
{
    // Set the frame to be the bounding box for the scaled points.
    NSArray *points = [AROverlayUtil scaledOverlayPointsForPoints:overlay.points withScaleFactor:scaleFactor];
    CGRect frame = [AROverlayUtil boundingFrameForPoints:points];
    
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.userInteractionEnabled = NO;
        _overlay = overlay;
        _overlayScaleFactor = scaleFactor;
        self.backgroundColor = [UIColor clearColor];
        
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        layer.masksToBounds = NO;
        layer.fillColor = [UIColor clearColor].CGColor;

        if (overlay.boundaryType == AROverlayBoundaryType_Dashed) {
            layer.strokeColor = _overlay.boundaryColor.CGColor;
            layer.lineWidth = 3.0;
            layer.lineDashPattern = @[@4];

        } else if (overlay.boundaryType == AROverlayBoundaryType_Solid) {
            layer.strokeColor = _overlay.boundaryColor.CGColor;
            layer.lineWidth = 3.0;
        }        
    }
    return self;
}


#pragma mark - Presentation
- (void)drawAnimated:(BOOL)animated
{
    if (_overlay.points.count == 0) return;
    

    // Adjust the points to this view's reference frame
    _scaledOutlinePoints = [AROverlayUtil scaledOverlayPointsForPoints:_overlay.points withScaleFactor:_overlayScaleFactor];
    UIBezierPath *path = [self outlinePathWithUnnormalizedScaledPoints:_scaledOutlinePoints];

    _animationIndex = 0;
    CAShapeLayer *l = (CAShapeLayer *)self.layer;

    if (animated) {
        _animationDurations = [self durationsForStrokeAnimation];
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
        anim.duration  = kAROverlayOutlineViewAnimationDuration;
        anim.values = @[@0.0, @1.0];
        [l addAnimation:anim forKey:@"anim"];
        l.path = path.CGPath;
        
        [self addVertexBubbleWithPoint:_scaledOutlinePoints[_animationIndex] animated:animated];
        
        CGFloat duration = [_animationDurations[0] floatValue] * kAROverlayOutlineViewAnimationDuration;
        [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(animationSegmentFinished) userInfo:nil repeats:NO];
    } else {
        l.path = path.CGPath;
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
    UIView *bubble = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    bubble.backgroundColor = _overlay.boundaryColor;
    bubble.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.8].CGColor;
    bubble.layer.borderWidth = 1.0;
    bubble.center = CGPointMake(p.x, p.y);
    [self addSubview:bubble];
    
    bubble.transform = CGAffineTransformMakeScale(0.5, 0.5);

    CGFloat duration = animated ? 0.2 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        bubble.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            bubble.transform = CGAffineTransformIdentity;
        }];
    }];
}



@end
