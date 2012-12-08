//
//  DrawView.h
//  EasyPAR
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
#import "DrawView.h"

@implementation DrawView
@synthesize drawBlock;

- (void)dealloc
{
    drawBlock = nil;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(self.drawBlock)
        self.drawBlock(self,context);
}

@end

@implementation UIView (DrawView)

- (void)addDrawBlock:(DrawView_DrawBlock)drawBlock
{
    DrawView* drawView = [[DrawView alloc] initWithFrame:self.bounds];
    drawView.backgroundColor = [UIColor clearColor];
    drawView.drawBlock = drawBlock;
    [self addSubview:drawView];
}

@end

void drawLinearGradient(CGContextRef context, CGRect rect,UIColor* startColor,UIColor*  endColor) 
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,(__bridge CFArrayRef)colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}




