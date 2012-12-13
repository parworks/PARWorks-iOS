//
//  ARPointOverlayView.m
//  MagView
//
//  Created by Demetri Miller on 11/28/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <objc/runtime.h>

#import "AROverlay.h"
#import "AROverlayPoint.h"
#import "ARPointOverlayView.h"
#import "UIView+ContentScaling.h"

@implementation ARPointOverlayView

- (id)initWithFrame:(CGRect)frame backingImageView:(UIImageView *)imageView
{
    self = [super initWithFrame:frame];
    if (self) {
        _editing = NO;
        _backingImageView = imageView;
        _imageScale = [_backingImageView aspectFitScaleForCurrentImage];
        
        _pointViews = [[NSMutableArray alloc] init];
        self.points = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    // Connect the dots and fill each overlay.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGContextSaveGState(context);
    
    for (AROverlay *overlay in _points) {
        NSArray *scaledPoints = [self scaledPointsForOverlay:overlay];
        
        if (overlay == [_points lastObject]) {
            [[[UIColor greenColor] colorWithAlphaComponent:0.4] set];
        } else {
            [[[UIColor redColor] colorWithAlphaComponent:0.4] set];
        }
        
        for (int i=0; i<scaledPoints.count; i++) {
            AROverlayPoint *p = scaledPoints[i];
            if (i==0) {
                CGContextMoveToPoint(context, p.x, p.y);
            } else {
                CGContextAddLineToPoint(context, p.x, p.y);
            }
        }
        CGContextFillPath(context);
    }
}


#pragma mark - Layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageScale = [_backingImageView aspectFitScaleForCurrentImage];
    
    // TODO: Layout the point views for the current image scale.
    int count = 0;
    for (AROverlay *overlay in _points) {
        NSArray *scaledPoints = [self scaledPointsForOverlay:overlay];
        CGRect lockViewRect = CGRectZero;
        for (int i=0; i<scaledPoints.count; i++) {
            AROverlayPoint *p = scaledPoints[i];
            
            if (CGRectEqualToRect(lockViewRect, CGRectZero)) {
                lockViewRect = CGRectMake(p.x, p.y, 1, 1);
            }
            
            UIImageView *pointView = _pointViews[count++];
            pointView.center = CGPointMake(p.x, p.y);
            lockViewRect = CGRectUnion(lockViewRect, CGRectMake(p.x, p.y, 1, 1));
        }
        
        UIImageView *lockView = [self lockImageViewForOverlay:overlay];
        lockView.center = CGPointMake(lockViewRect.origin.x + (lockViewRect.size.width/2), lockViewRect.origin.y + (lockViewRect.size.height/2));
        lockView.hidden = (overlay.points.count <= 2);
    }
    
    [self setNeedsDisplay];
}

#pragma mark - Convenience
- (void)clearPoints
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_pointViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_pointViews removeAllObjects];
    [_points removeAllObjects];
    [self setNeedsDisplay];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didClearPoints)]) {
        [_delegate didClearPoints];
    }
}

- (void)removeLastPoint
{
    AROverlay *lastOverlay = [_points lastObject];
    
    if (lastOverlay.points.count > 0) {
        [lastOverlay.points removeLastObject];

        UIView *lastView = [_pointViews lastObject];
        [lastView removeFromSuperview];
        [_pointViews removeLastObject];
        [self setNeedsLayout];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didRemoveLastPoint)]) {
        [_delegate didRemoveLastPoint];
    }

}

- (NSArray *)scaledPointsForOverlay:(AROverlay *)overlay
{
    NSMutableArray *a = [NSMutableArray array];
    for (AROverlayPoint *p in overlay.points) {
        AROverlayPoint *scaledPoint = [AROverlayPoint pointWithX:p.x*_imageScale y:p.y*_imageScale z:0];
        [a addObject:scaledPoint];
    }
    return a;
}

- (UIImageView *)lockImageViewForOverlay:(AROverlay *)overlay
{
    if (overlay == nil) {
        return nil;
    }
    
    UIImageView *lockView = objc_getAssociatedObject(overlay, @"LockView");
    if (!lockView) {
        lockView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        lockView.image = [UIImage imageNamed:@"stock_lock_open.png"];
        lockView.contentMode = UIViewContentModeScaleAspectFit;
        
        objc_setAssociatedObject(overlay, @"LockView", lockView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addSubview:lockView];
    }
    
    return lockView;
}

#pragma mark - Point Management
- (void)addScaledTouchPoint:(CGPoint)p
{
    
    UIImageView *lockView = [self lockImageViewForOverlay:[_points lastObject]];

    // We'll do hit detection on the lock view manually.
    if (CGRectContainsPoint(lockView.frame, p)) {
        [self closeCurrentOverlay];
        return;
    }
    
    // Size the point to the original image scale before adding it.
    [self addScaledTouchPointToPointArray:p];
    
    UIImageView *pointView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble.png"]];
    pointView.contentMode = UIViewContentModeCenter;
    pointView.center = p;
    [self addSubview:pointView];
    [_pointViews addObject:pointView];
    [self setNeedsDisplay];    
}

- (void)addScaledTouchPointToPointArray:(CGPoint)p
{
    AROverlay *overlay = [_points lastObject];
    
    if (overlay == nil) {
        overlay = [[AROverlay alloc] init];
        overlay.points = [NSMutableArray array];
        [_points addObject:overlay];
    }
    
    CGPoint fullPoint = CGPointMake(p.x/_imageScale, p.y/_imageScale);
    [overlay addPointWithX:fullPoint.x andY:fullPoint.y];

    if (_delegate && [_delegate respondsToSelector:@selector(didAddScaledTouchPoint:)]) {
        [_delegate didAddScaledTouchPoint:p];
    }
}

- (void)closeCurrentOverlay
{
    // Set the image to locked on our current overlay.
    UIImageView *lockView = [self lockImageViewForOverlay:[_points lastObject]];
    lockView.image = [UIImage imageNamed:@"stock_lock.png"];
    [lockView removeFromSuperview];
    
    // Create a new overlay and add it to our points array.
    AROverlay *overlay = [[AROverlay alloc] init];
    overlay.points = [NSMutableArray array];
    [_points addObject:overlay];
    
    
    [self setNeedsDisplay];
}

- (BOOL)isClosingTouchPoint:(CGPoint)p
{
    NSArray *scaledPoints = [self scaledPointsForOverlay:[_points lastObject]];
    if (scaledPoints.count > 1) {
        AROverlayPoint *firstPoint = scaledPoints[0];
        CGRect firstPointRect = CGRectMake(firstPoint.x - 20, firstPoint.y - 20, 40, 40);
        return CGRectContainsPoint(firstPointRect, p);
    }
    return NO;
}

@end
