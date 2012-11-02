//
//  DMIndicatorView.m
//  DMColorPicker
//
//  Created by Demetri Miller on 10/28/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "DMIndicatorView.h"

@implementation DMIndicatorView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        
        CGPoint center = {CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
        CGFloat radius = CGRectGetMidX(self.bounds);
        
        CAShapeLayer *outerStroke = [CAShapeLayer layer];
        outerStroke.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius - 1.0 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        outerStroke.contentsScale = [UIScreen mainScreen].scale;
        outerStroke.fillColor = [UIColor clearColor].CGColor;
        outerStroke.strokeColor = [UIColor blackColor].CGColor;
        outerStroke.lineWidth = 1.0;
        [self.layer addSublayer:outerStroke];
        
        CAShapeLayer *innerStroke = [CAShapeLayer layer];
        innerStroke.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius - 2.0 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        innerStroke.contentsScale = [UIScreen mainScreen].scale;
        innerStroke.fillColor = [UIColor clearColor].CGColor;
        innerStroke.strokeColor = [UIColor whiteColor].CGColor;
        innerStroke.lineWidth = 1.0;
        [self.layer addSublayer:innerStroke];
    }
    return self;
}


#pragma mark - Getters/Setters
- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}


#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGPoint center = {CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
	CGFloat radius = CGRectGetMidX(self.bounds);
	
	// Fill it:
	CGContextAddArc(context, center.x, center.y, radius - 1.0f, 0.0f, 2.0f*M_PI, YES);
	[self.color setFill];
	CGContextFillPath(context);
}

@end

