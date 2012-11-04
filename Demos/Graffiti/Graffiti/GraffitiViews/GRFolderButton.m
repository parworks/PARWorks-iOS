//
//  GRFolderButton.m
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


#import "GRFolderButton.h"

@implementation GRFolderButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

    CGContextRef context = UIGraphicsGetCurrentContext();
    /*
    CGContextMoveToPoint(context, rect.size.width, 0);
    CGContextAddArcToPoint(context, 4, 0, 0, 5, 5);
    CGContextAddArcToPoint(context, 0, rect.size.height - 5, 4, rect.size.height - 0, 5);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextClosePath(context);
    */
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
    CGContextAddPath(context, path.CGPath);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:240.0/255.0 green:225.0/255.0 blue:168.0/255.0 alpha:1.0].CGColor);
    CGContextFillPath(context);
}

@end
