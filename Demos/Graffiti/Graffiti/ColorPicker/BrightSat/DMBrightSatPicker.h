//
//  DMBrightSatPicker.h
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