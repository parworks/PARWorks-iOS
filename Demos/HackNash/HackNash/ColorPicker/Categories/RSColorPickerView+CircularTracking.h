//
//  RSColorPickerView+CircularTracking.h
//  RSColorPicker
//
//  Created by Demetri Miller on 10/22/12.
//  Copyright (c) 2012 Freelance Web Developer. All rights reserved.
//

#import "RSColorPickerView.h"

@interface RSColorPickerView (CircularTracking)

- (CGPoint)circularPointForTouchPoint:(CGPoint)touch withRadius:(CGFloat)radius;

@end
