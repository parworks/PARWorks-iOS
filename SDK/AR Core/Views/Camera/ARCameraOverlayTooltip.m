//
//  ARCameraOverlayTooltip.m
//  PARViewer
//
//  Created by Demetri Miller on 2/18/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARCameraOverlayTooltip.h"

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
    layer.fillColor = [UIColor redColor].CGColor;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeZero;
    layer.shadowOpacity = 1.0;
    layer.shadowRadius = 3.0;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    self.label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 4, 4)];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentLeft;
    _label.numberOfLines = 0;
    
    self.arrow = [[ARCameraOverlayTooltipArrow alloc] initWithFrame:CGRectMake(0, 0, 24, 12)];
    [self addSubview:_arrow];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:4].CGPath;
    _arrow.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height + _arrow.frame.size.height/2);
}
@end



@implementation ARCameraOverlayTooltipArrow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width/2, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextClosePath(context);
    
    [[UIColor greenColor] set];
    CGContextFillPath(context);
}

@end