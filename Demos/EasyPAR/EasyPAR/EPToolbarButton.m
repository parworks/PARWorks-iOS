//
//  EPToolbarButton.m
//  EasyPAR
//
//  Created by Demetri Miller on 12/4/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "EPToolbarButton.h"

@implementation EPToolbarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    UIBezierPath *darkStrokePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, rect.size.width, rect.size.height-1) cornerRadius:4];
    UIBezierPath *lightStrokePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 1, rect.size.width, rect.size.height-1) cornerRadius:4];

    if (self.highlighted) {
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.15].CGColor);
        CGContextAddPath(context, darkStrokePath.CGPath);
        CGContextFillPath(context);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextAddPath(context, darkStrokePath.CGPath);
        CGContextFillPath(context);
    }
    
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor);
    CGContextAddPath(context, lightStrokePath.CGPath);
    CGContextStrokePath(context);
    
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end
