//
//  DMColorPickerMask.m
//  Graffiti
//
//  Copyright 2012 PAR Works, Inc.
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
