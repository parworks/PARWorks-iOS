//
//  BRCircleView.m
//  PARWorks iOS SDK
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


#import "BRCircleView.h"

@implementation BRCircleView

- (id)initWithFrame:(CGRect)frame points:(NSArray *)points
{
    self = [super initWithFrame:frame points:points];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 0.0;
        self.anim = [[AROverlayAnimation alloc] init];
        self.animDelegate = _anim;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:(rect.size.width/2) - 5 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [[UIColor cyanColor] set];
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
}


@end
