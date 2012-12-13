//
//  MagView.m
//  MagView
//
//  Created by Demetri Miller on 11/27/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ARMagView.h"
#import "ARPointOverlayView.h"
#import "UIView+ContentScaling.h"

// Convenience method for pinning a value between a min and max.
float pin(float min, float value, float max)
{
    float v = value;
    v = MAX(min, v);
    v = MIN(max, v);
    return v;
}

@implementation ARMagView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        _image = image;
        [self sharedInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame imagePath:(NSString *)imagePath
{
    self = [super initWithFrame:frame];
    if (self) {
        _imagePath = [imagePath copy];
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
    
    _imageView = [[CachedImageView alloc] initWithFrame:self.bounds];
    _imageView.userInteractionEnabled = NO;
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    __weak ARMagView *blockSelf = self;
    _imageView.loadCompletionBlock = ^(UIImage *image) {
        [blockSelf setNeedsLayout];
    };
    
    // Set our image if it exists.
    if (_image != nil) {
        _imageView.image = _image;
    } else if (_imagePath != nil) {
        [_imageView setImagePath:_imagePath];
    }
    
    [self addSubview:_imageView];
    
    _pointOverlay = [[ARPointOverlayView alloc] initWithFrame:self.bounds backingImageView:_imageView];
    _pointOverlay.userInteractionEnabled = NO;
    _pointOverlay.backgroundColor = [UIColor clearColor];
    _pointOverlay.delegate = self;
    [self addSubview:_pointOverlay];
    
    self.zoomView = [[ARZoomView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) zoomableImageView:_imageView];
    [self addSubview:_zoomView];
    [self hideZoomViewAnimated:NO];
    
    [self addTarget:self action:@selector(touchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self addTarget:self action:@selector(touchEnded:withEvent:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect scaledImageRect = [_imageView aspectFitFrameForCurrentImage];
    if (!CGRectEqualToRect(scaledImageRect, CGRectZero)) {
        _pointOverlay.bounds = CGRectMake(0, 0, scaledImageRect.size.width, scaledImageRect.size.height);
        _pointOverlay.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);        
    }
}


#pragma mark - Convenience
- (void)showZoomViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.1 : 0.0;
    CGAffineTransform t = CGAffineTransformMakeScale(0.5, 0.5);
    _zoomView.transform = t;
    [UIView animateWithDuration:duration animations:^{
        _zoomView.alpha = 1.0;
        _zoomView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            _zoomView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)hideZoomViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? 0.1 : 0.0;
    CGAffineTransform t = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:duration animations:^{
        _zoomView.alpha = 0.0;
        _zoomView.transform = t;
    }];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = image;
    [_pointOverlay clearPoints];
}

- (AROverlay *)currentOverlay
{
    return [_pointOverlay.points lastObject];
}


#pragma mark - ARPointOverlayViewDelegate
- (void)didAddScaledTouchPoint:(CGPoint)p
{
    [self notifyDelegateOverlayUpdated];
}

- (void)didClearPoints
{
    [self notifyDelegateOverlayUpdated];
}

- (void)didRemoveLastPoint
{
    [self notifyDelegateOverlayUpdated];
}

- (void)notifyDelegateOverlayUpdated
{
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdatePointWithOverlay:)]) {
        [_delegate didUpdatePointWithOverlay:[_pointOverlay.points lastObject]];
    }
}



#pragma mark - Zooming
- (void)touchDown:(id)sender withEvent:(UIEvent *)event
{
    [self showZoomViewAnimated:YES];
    [self refreshZoomViewForTouches:event.allTouches];
}

- (void)touchMoved:(id)sender withEvent:(UIEvent *)event
{
    // Move the magnifying glass to be above the touch point.
    [self refreshZoomViewForTouches:event.allTouches];
}

- (void)touchEnded:(id)sender withEvent:(UIEvent *)event
{
    // If the touch is close enough to the first touch point, go ahead and close this point.
    UITouch *t = [event.allTouches anyObject];
    CGPoint p = [t locationInView:self];

    CGPoint scaledPoint = [self scaledTouchPointForPointOverlayView:p withScaledImageFrame:[_imageView aspectFitFrameForCurrentImage]];
    float scale = [_imageView aspectFitScaleForCurrentImage];
    _pointOverlay.imageScale = scale;
    [_pointOverlay addScaledTouchPoint:scaledPoint];

    [self hideZoomViewAnimated:YES];
    [self refreshZoomViewForTouches:event.allTouches];
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
- (void)refreshZoomViewForTouches:(NSSet *)touches
{
    CGRect scaledFrame = [_imageView aspectFitFrameForCurrentImage];
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self];

    // Cap the touch points.
    CGPoint imageZoomPoint = [self cappedTouchPointForPoint:p withScaledImageFrame:scaledFrame];
    _zoomView.currentZoomPoint = imageZoomPoint;
    
    CGFloat zoomOffsetY = (_zoomView.bounds.size.height/2) + 10;
    CGPoint zoomCenter = CGPointMake(p.x, p.y - zoomOffsetY);
    zoomCenter.x = pin(scaledFrame.origin.x + _zoomView.bounds.size.width/2, zoomCenter.x, self.frame.size.width - scaledFrame.origin.x - _zoomView.bounds.size.width/2);
    zoomCenter.y = pin(scaledFrame.origin.y + _zoomView.bounds.size.height/2, zoomCenter.y, self.frame.size.height - scaledFrame.origin.y - _zoomView.bounds.size.height/2);
    _zoomView.center = zoomCenter;
    [_zoomView setNeedsDisplay];
}

@end



@implementation ARZoomView

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
    CGContextTranslateCTM(context, -p.x, -imageSize.height + p.y);
    CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), _fullImageView.image.CGImage);
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
