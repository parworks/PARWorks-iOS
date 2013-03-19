//
//  ARCameraOverlayTooltip.m
//  PARViewer
//
//  Created by Demetri Miller on 2/18/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARCameraOverlayTooltip.h"
#import "UIColor+Utils.h"

@implementation ARCameraOverlayTooltip

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.clipsToBounds = NO;
    
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeZero;
    layer.shadowOpacity = 1.0;
    layer.shadowRadius = 3.0;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = layer.bounds;
    gradient.cornerRadius = 4;
    gradient.colors = @[(id)[UIColor colorWithHexRGBValue:0x1e1e1e].CGColor, (id)[UIColor colorWithHexRGBValue:0x141414].CGColor];
    [layer addSublayer:gradient];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 4, 4)];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentLeft;
    _label.font = [UIFont boldSystemFontOfSize:13];
    _label.numberOfLines = 0;
    [self addSubview:_label];
    
    self.arrow = [[ARCameraOverlayTooltipArrow alloc] initWithFrame:CGRectMake(0, 0, 24, 12)];
    [self addSubview:_arrow];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:4].CGPath;
    _label.frame = CGRectInset(self.bounds, 10, 4);
}

- (void)updateArrowLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat rotateAngle;
    CGPoint center;
    UIColor *fillColor;

    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            center = CGPointMake(self.bounds.size.width/2, -_arrow.bounds.size.height/2);
            fillColor = [UIColor colorWithHexRGBValue:0x1e1e1e];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            center = CGPointMake(-_arrow.bounds.size.height/2, self.bounds.size.height/2);
            fillColor = [UIColor colorWithHexRGBValue:0x191919];
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            center = CGPointMake(self.bounds.size.width + _arrow.bounds.size.height/2, self.bounds.size.height/2);
            fillColor = [UIColor colorWithHexRGBValue:0x191919];
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height + _arrow.bounds.size.height/2);
            fillColor = [UIColor colorWithHexRGBValue:0x141414];
            break;
    }
    
    _arrow.transform = CGAffineTransformIdentity;
    _arrow.center = center;
    _arrow.transform = CGAffineTransformMakeRotation(-rotateAngle);
    _arrow.fillColor = fillColor;
    [_arrow setNeedsDisplay];
}

@end



@implementation ARCameraOverlayTooltipArrow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.fillColor = [UIColor colorWithHexRGBValue:0x141414];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width/2, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextClosePath(context);
    
    [_fillColor set];
    CGContextFillPath(context);
}

@end