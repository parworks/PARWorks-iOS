//
//  HNFolderButton.m
//  HackNash
//
//  Created by Demetri Miller on 10/29/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "HNFolderButton.h"

@implementation HNFolderButton

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
