//
//  DMBrightSatPicker.h
//  DMColorPicker
//
//  Created by Demetri Miller on 10/25/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMIndicatorView;

@protocol DMBrightSatPickerDelegate <NSObject>
@optional
- (void)brightSatPickerChanged;

@end

/** This view is a square that displays the brightness and saturation fields for a given hue.
    The view also provides touch tracking for changing the brightness and saturation.
 */
@interface DMBrightSatPicker : UIControl
{
    DMIndicatorView *_indicator;
    UIImage *_image;
}

@property(nonatomic, strong) DMIndicatorView *indicator;
@property(nonatomic, assign) CGPoint brightnessPoint;
@property(nonatomic, assign) float hue;

@property(nonatomic, weak) id<DMBrightSatPickerDelegate>delegate;

- (void)handleTouchAtPoint:(CGPoint)p;

@end