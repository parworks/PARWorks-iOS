//
//  UIView+ImageCapture.m
//  CameraTransitionTest
//
//  Created by Demetri Miller on 2/7/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+ImageCapture.h"


@implementation UIView (ImageCapture)

- (UIImage*)imageRepresentationAtScale:(float)outputScaleFactor
{
    CGRect b = [self bounds];
    float contentScaleFactor = [self contentScaleFactor];
    
    if ((b.size.width == 0) || (b.size.height == 0))
        return nil;
    
    b.size.width = b.size.width * contentScaleFactor * outputScaleFactor;
    b.size.height = b.size.height * contentScaleFactor * outputScaleFactor;
    
    UIGraphicsBeginImageContext(b.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(c, outputScaleFactor * contentScaleFactor, outputScaleFactor * contentScaleFactor);
    if ([self isKindOfClass:[UIScrollView class]]) {
        CGContextTranslateCTM(c, -[(UIScrollView*)self contentOffset].x, -[(UIScrollView*)self contentOffset].y);
    }
    [[self layer] renderInContext: c];
    UIImage * i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return i;
}



@end
