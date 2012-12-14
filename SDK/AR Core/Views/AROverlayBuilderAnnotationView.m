//
//  AROverlayBuilderAnnotationView.m
//  MagView
//
//  Created by Demetri Miller on 11/28/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <objc/runtime.h>

#import "AROverlay.h"
#import "AROverlayPoint.h"
#import "AROverlayBuilderAnnotationView.h"
#import "UIView+ContentScaling.h"

@implementation AROverlayBuilderAnnotationView

- (id)initWithFrame:(CGRect)frame andSiteImage:(ARSiteImage*)siteImage backingImageView:(UIImageView *)imageView
{
    self = [super initWithFrame:frame];
    if (self) {
        _editing = NO;
        _backingImageView = imageView;
        
        _pointViews = [[NSMutableArray alloc] init];
        _lockViews = [[NSMutableArray alloc] init];

        self.siteImage = siteImage;
    }
    return self;
}


- (void)setSiteImage:(ARSiteImage*)s
{
    _siteImage = s;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // Connect the dots and fill each overlay.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSaveGState(context);


    // Remove all the overlay views and put them in a reuse array
    NSMutableArray * unusedPointViews = [[NSMutableArray alloc] initWithArray: _pointViews];
    [_pointViews removeAllObjects];

    // Remove all the lock views and put them in a reuse array
    NSMutableArray * unusedLockViews = [[NSMutableArray alloc] initWithArray: _lockViews];
    [_lockViews removeAllObjects];
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Create / place point views for our overlays
    for (AROverlay * overlay in _siteImage.overlays) {
        NSArray * scaledPoints = [self scaledPointsForOverlay: overlay];
        CGRect lockViewRect = CGRectZero;

        if (![overlay isSaved])
            [[[UIColor greenColor] colorWithAlphaComponent:0.4] set];
        else
            [[[UIColor redColor] colorWithAlphaComponent:0.4] set];

        for (int i = 0; i < scaledPoints.count; i++) {
            AROverlayPoint * point = scaledPoints[i];
            
            // Dequeue a point view or create one if we have to
            UIView * pointView = [unusedPointViews lastObject];
            if (!pointView) {
                pointView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble.png"]];
                pointView.contentMode = UIViewContentModeCenter;
                [_pointViews addObject:pointView];
            }
            
            // Place a point view
            [pointView setCenter: CGPointMake(point.x, point.y)];
            [self addSubview:pointView];
            [unusedPointViews removeLastObject];

            // Add this point to the rect that we'll use to center the lock view
            if (CGRectEqualToRect(lockViewRect, CGRectZero))
                lockViewRect = CGRectMake(point.x, point.y, 1, 1);
            lockViewRect = CGRectUnion(lockViewRect, CGRectMake(point.x, point.y, 1, 1));
            
            // Add a point to the path we're drawing
            if (i==0)
                CGContextMoveToPoint(context, point.x, point.y);
            else
                CGContextAddLineToPoint(context, point.x, point.y);
        }
    
        CGContextFillPath(context);
        
        // Dequeue a lock view or create one if we have to
        UIImageView *lockView = [unusedPointViews lastObject];
        if (!lockView) {
            lockView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            lockView.image = [UIImage imageNamed:@"stock_lock_open.png"];
            lockView.contentMode = UIViewContentModeScaleAspectFit;
            [_lockViews addObject: lockView];
        }

        lockView.center = CGPointMake(lockViewRect.origin.x + (lockViewRect.size.width/2), lockViewRect.origin.y + (lockViewRect.size.height/2));
        lockView.hidden = (overlay.points.count <= 2);
//        [self addSubview: lockView];
        [unusedLockViews removeLastObject];
    }
}


#pragma mark - Layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageScale = [_backingImageView aspectFitScaleForCurrentImage];
}

#pragma mark - Convenience

- (AROverlay*)currentOverlay
{
    return [[_siteImage overlays] lastObject];
}

- (NSArray *)scaledPointsForOverlay:(AROverlay *)overlay
{
    NSMutableArray *a = [NSMutableArray array];
    for (AROverlayPoint *p in overlay.points) 
        [a addObject: [AROverlayPoint pointWithX: p.x*_imageScale y: p.y*_imageScale z:0]];
    
    return a;
}

#pragma mark - Point Management
- (void)addScaledTouchPoint:(CGPoint)p
{
    // Size the point to the original image scale before adding it.
    [self addScaledTouchPointToOverlay: p];
    [self setNeedsDisplay];
}

- (void)addScaledTouchPointToOverlay:(CGPoint)p
{
    if (([self currentOverlay] == nil) || ([[self currentOverlay] isSaved]))
        [_siteImage.site addOverlay: [[AROverlay alloc] initWithSiteImage: self.siteImage]];
    
    CGPoint fullPoint = CGPointMake(p.x/_imageScale, p.y/_imageScale);
    [[self currentOverlay] addPointWithX:fullPoint.x andY:fullPoint.y];

    if (_delegate && [_delegate respondsToSelector:@selector(didAddScaledTouchPoint:)]) {
        [_delegate didAddScaledTouchPoint:p];
    }
}

- (void)closeCurrentOverlay
{
    // Create a new overlay and add it to our points array.
    AROverlay *overlay = [[AROverlay alloc] initWithSiteImage: self.siteImage];
    [_siteImage.site addOverlay: overlay];
    
    [self setNeedsDisplay];
}

- (BOOL)isClosingTouchPoint:(CGPoint)p
{
    NSArray *scaledPoints = [self scaledPointsForOverlay:[self currentOverlay]];
    if (scaledPoints.count > 1) {
        AROverlayPoint *firstPoint = scaledPoints[0];
        CGRect firstPointRect = CGRectMake(firstPoint.x - 20, firstPoint.y - 20, 40, 40);
        return CGRectContainsPoint(firstPointRect, p);
    }
    return NO;
}

@end
