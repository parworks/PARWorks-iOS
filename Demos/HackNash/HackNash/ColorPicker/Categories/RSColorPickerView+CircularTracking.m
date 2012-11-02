//
//  RSColorPickerView+CircularTracking.m
//  RSColorPicker
//
//  Created by Demetri Miller on 10/22/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "RSColorPickerView+CircularTracking.h"

@implementation RSColorPickerView (CircularTracking)

- (CGPoint)circularPointForTouchPoint:(CGPoint)touch withRadius:(CGFloat)radius
{
    CGPoint viewCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    // Get the angle between the center and our current touch point.
    float x =  touch.x - viewCenter.x;
    float y = touch.y - viewCenter.y;
    float theta = (x >= 0) ? atan(y/x) : (atan(y/x) - M_PI);
    
    // Now that we know the angle, determine the point for the cirlce by using our radius.
    CGFloat newX = radius * cosf(theta) + viewCenter.x;
    CGFloat newY = radius * sinf(theta) + viewCenter.y;
    CGPoint newPoint = CGPointMake(newX, newY);
    return newPoint;
}

@end
