//
//  RSColorPickerView+CircularTracking.m
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
