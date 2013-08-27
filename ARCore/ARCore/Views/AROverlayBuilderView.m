//
//  AROverlayBuilderView.m
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


#import <QuartzCore/QuartzCore.h>
#import "AROverlayBuilderView.h"
#import "AROverlayBuilderAnnotationView.h"
#import "UIView+ContentScaling.h"
#import "AROverlayUtil.h"
#import "AROverlayPoint.h"

// Convenience method for pinning a value between a min and max.
float pin( float minValue, float value, float maxValue )
{
	if( minValue > value )
		return minValue;
	else if( maxValue < value )
		return maxValue;
	else
		return value;
}

@implementation AROverlayBuilderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self sharedInit];
}


- (void)sharedInit
{
    self.userInteractionEnabled = YES;
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.multipleTouchEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    
    _imageView = [[CachedImageView alloc] initWithFrame:self.bounds];
    _imageView.userInteractionEnabled = NO;
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    __weak AROverlayBuilderView * _self = self;
    _imageView.loadCompletionBlock = ^(UIImage *image) {
        [_self setNeedsLayout];
    };
    [self addSubview:_imageView];
    
    _annotationView = [[AROverlayBuilderAnnotationView alloc] initWithFrame:self.bounds andSiteImage:_siteImage backingImageView:_imageView];
    _annotationView.userInteractionEnabled = NO;
    _annotationView.backgroundColor = [UIColor clearColor];
    _annotationView.delegate = self;
    [self addSubview:_annotationView];
    
    self.lensView = [[ARMagnifiedLensView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) zoomableImageView:_imageView];
    [self addSubview:_lensView];
    [self hideLensViewAnimated:NO];
        
    [self addTarget:self action:@selector(touchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self addTarget:self action:@selector(touchEnded:withEvent:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Layout & Redraw

- (void)setNeedsDisplay
{
    [_annotationView setNeedsDisplay];
    [super setNeedsDisplay];
}

- (void)layoutSubviews
{
    [_annotationView setNeedsLayout];
    [super layoutSubviews];
    
    CGRect scaledImageRect = [_imageView aspectFitFrameForCurrentImage];
    if (!CGRectEqualToRect(scaledImageRect, CGRectZero)) {
        _annotationView.bounds = CGRectMake(0, 0, scaledImageRect.size.width, scaledImageRect.size.height);
        _annotationView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);        
    }
}


#pragma mark - Convenience

- (void)showLensViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.1 : 0.0;
    CGAffineTransform t = CGAffineTransformMakeScale(0.5, 0.5);
    _lensView.transform = t;
    [UIView animateWithDuration:duration animations:^{
        _lensView.alpha = 1.0;
        _lensView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            _lensView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)hideLensViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.1 : 0.0;
    CGAffineTransform t = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:duration animations:^{
        _lensView.alpha = 0.0;
        _lensView.transform = t;
    }];
}

- (void)setSiteImage:(ARSiteImage*)siteImage;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _siteImage = siteImage;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NOTIF_SITE_UPDATED object:_siteImage.site];

    [_imageView setImagePath: [[_siteImage urlForSize: 2000] absoluteString]];
    [_annotationView setSiteImage: _siteImage];
}

- (AROverlay*)lastInteractedOverlay
{
    return _lastInteractedOverlay;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - AROverlayBuilderAnnotationViewDelegate

- (BOOL)canAddScaledTouchPoint
{
    return ([[[_annotationView currentOverlay] points] count] < _maxPointsPerOverlay);
}

- (void)didAddScaledTouchPoint:(CGPoint)p
{
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdatePointWithOverlay:)]) {
        [_delegate didUpdatePointWithOverlay: _lastInteractedOverlay];
    }
}


#pragma mark - Zooming
- (void)touchDown:(id)sender withEvent:(UIEvent *)event
{
    // identify the closest point to the user's finger. That's gonna be the one they're now dragging
    UITouch *t = [event.allTouches anyObject];
    CGPoint p = [t locationInView:self];
    CGPoint pScaled = [self scaledTouchPointForPointOverlayView: p withScaledImageFrame: [_imageView aspectFitFrameForCurrentImage]];
    float scale = [_imageView aspectFitScaleForCurrentImage];
    pScaled.x /= scale;
    pScaled.y /= scale;
    
    _pointIndex = NSNotFound;
    _overlayIndex = NSNotFound;
    
    float pointDist = INT_MAX;
    
    for (int x = 0; x < [[_siteImage overlays] count]; x ++) {
        AROverlay * overlay = [[_siteImage overlays] objectAtIndex: x];
        if ([overlay processed])
            continue;
        
        for (int ii = 0; ii < [[overlay points] count]; ii ++) {
            AROverlayPoint * point = [[overlay points] objectAtIndex: ii];
            float dist = sqrtf(powf(point.x - pScaled.x, 2) + powf(point.y - pScaled.y, 2));
            
            if ((dist < pointDist) && (dist < 44)) {
                _pointIndex = ii;
                _overlayIndex = x;
                pointDist = dist;
            }
        }
    }

    if (_pointIndex == NSNotFound) {
        BOOL withinAnotherOverlay = NO;
        for (AROverlay * o in [_siteImage overlays]) {
            if ([AROverlayUtil isPoint:pScaled withinOverlay: o]) {
                withinAnotherOverlay = YES;
                if ([NSDate timeIntervalSinceReferenceDate] - _lastInsideTouchTimestamp > 1.0)
                    _lastInsideTouchTimestamp = [NSDate timeIntervalSinceReferenceDate];
                else {
                    _lastInteractedOverlay = o;
                    [_delegate didDoubleTapOverlay: o];
                }
            }
        }
        if (!withinAnotherOverlay) {
            [_annotationView beginNewOverlay: pScaled];
            _lastInteractedOverlay = [[_siteImage overlays] lastObject];
        }
    } else {
        [self showLensViewAnimated:YES];
        [self refreshLensViewForTouchPoint: p];

        _lastInteractedOverlay = [[_siteImage overlays] objectAtIndex: _overlayIndex];
    }

}

- (void)touchMoved:(id)sender withEvent:(UIEvent *)event
{
    // Move the magnifying glass to be above the touch point.
    if (_pointIndex != NSNotFound) {
        UITouch *t = [event.allTouches anyObject];
        CGPoint p = [t locationInView:self];
        CGPoint pScaled = [self scaledTouchPointForPointOverlayView: p withScaledImageFrame: [_imageView aspectFitFrameForCurrentImage]];

        [self refreshLensViewForTouchPoint: p];
        [_annotationView updatePoint:_pointIndex ofOverlay: _overlayIndex to: pScaled];
    }
}

- (void)touchEnded:(id)sender withEvent:(UIEvent *)event
{
    UITouch *t = [event.allTouches anyObject];
    CGPoint p = [t locationInView:self];

    [self hideLensViewAnimated:YES];
    [self refreshLensViewForTouchPoint: p];

    [_delegate didUpdatePointWithOverlay: _lastInteractedOverlay];
}

- (CGPoint)cappedTouchPointForPoint:(CGPoint)p withScaledImageFrame:(CGRect)scaledFrame
{
    p.x = pin(scaledFrame.origin.x, p.x, self.frame.size.width - scaledFrame.origin.x);
    p.y = pin(scaledFrame.origin.y, p.y, self.frame.size.height - scaledFrame.origin.y);
    return p;
}

- (CGPoint)scaledTouchPointForPointOverlayView:(CGPoint)p withScaledImageFrame:(CGRect)scaledFrame
{
    p.x = pin(0, p.x - scaledFrame.origin.x, self.frame.size.width - scaledFrame.origin.x);
    p.y = pin(0, p.y - scaledFrame.origin.y, self.frame.size.height - scaledFrame.origin.y);
    return p;
}

// Frame the zoome view so it's centered above out touch point.
- (void)refreshLensViewForTouchPoint:(CGPoint)p
{
    // Cap the touch points.
    CGRect scaledFrame = [_imageView aspectFitFrameForCurrentImage];
    CGPoint imageZoomPoint = [self cappedTouchPointForPoint:p withScaledImageFrame:scaledFrame];
    _lensView.currentZoomPoint = imageZoomPoint;
    
    CGRect draggableFrame = CGRectInset(scaledFrame, _lensView.bounds.size.width/2, _lensView.bounds.size.height/2);
    CGFloat zoomOffsetY = (_lensView.bounds.size.height/2) + 10;
    CGPoint zoomCenter = CGPointMake(p.x, p.y - zoomOffsetY);

    zoomCenter.x = pin(draggableFrame.origin.x, zoomCenter.x, draggableFrame.origin.x + draggableFrame.size.width);
    zoomCenter.y = pin(draggableFrame.origin.y, zoomCenter.y, draggableFrame.origin.y + draggableFrame.size.height);
    
    _lensView.center = zoomCenter;
    [_lensView setNeedsDisplay];
}

@end



@implementation ARMagnifiedLensView

- (id)initWithFrame:(CGRect)frame zoomableImageView:(UIImageView *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 4.0;
        self.layer.cornerRadius = frame.size.width/2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
        self.layer.shadowRadius = 3.0;
        self.fullImageView = image;
        _currentZoomPoint = CGPointZero;
    }
    return self;
}

- (void)dealloc
{
    CGLayerRelease(_cacheLayer);
    _cacheLayer = nil;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    UIBezierPath *path;
    path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius];
    CGContextAddPath(context, path.CGPath);
    CGContextClip(context);
    
    CGContextSaveGState(context);
    CGContextScaleCTM(context, 1, -1);
    
    // Get the scaled coordinates for drawing.
    CGFloat scale = [_fullImageView aspectFitScaleForCurrentImage];
    CGRect scaledFrame = [_fullImageView aspectFitFrameForCurrentImage];
    CGSize imageSize = _fullImageView.image.size;
    
    _currentZoomPoint.x -= scaledFrame.origin.x;
    _currentZoomPoint.y -= scaledFrame.origin.y;
    
    // Draw the image into the view.
    CGPoint p = CGPointMake(((_currentZoomPoint.x / scale) - (self.bounds.size.width/2)), ((_currentZoomPoint.y / scale) - (self.bounds.size.height/2)));

    if (_cacheLayer == nil) {
        _cacheLayer = CGLayerCreateWithContext(context, _fullImageView.image.size, NULL);
        CGContextRef c = CGLayerGetContext(_cacheLayer);
        CGContextDrawImage(c, CGRectMake(0, 0, _fullImageView.image.size.width, _fullImageView.image.size.height), _fullImageView.image.CGImage);
    }
    
    CGContextTranslateCTM(context, -p.x, -imageSize.height + p.y);
    CGContextDrawLayerAtPoint(context, CGPointZero, _cacheLayer);
    CGContextRestoreGState(context);
    
    // Draw the crosshairs
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor);
    CGContextSetLineWidth(context, 2);

    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, rect.size.height/2)];
    [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height/2)];
    CGContextAddPath(context, path.CGPath);
    
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(rect.size.width/2, 0)];
    [path addLineToPoint:CGPointMake(rect.size.width/2, rect.size.height)];
    CGContextAddPath(context, path.CGPath);
    
    CGContextStrokePath(context);
}

@end
