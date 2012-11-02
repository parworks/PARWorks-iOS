//
//  DMColorPickerMask.m
//  RSColorPicker
//
//  Created by Demetri Miller on 10/22/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "DMColorPickerConstants.h"
#import "DMColorPickerMask.h"

@implementation DMColorPickerMask

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = [UIBezierPath bezierPathWithArcCenter:center radius:(self.bounds.size.width/2) - (kDMColorPickerMaskStrokeWidth/2) + 0.5 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        layer.contentsScale = [UIScreen mainScreen].scale;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = [UIColor blackColor].CGColor;
        layer.lineWidth = kDMColorPickerMaskStrokeWidth;
        [self.layer addSublayer:layer];
    }
    return self;
}

@end
