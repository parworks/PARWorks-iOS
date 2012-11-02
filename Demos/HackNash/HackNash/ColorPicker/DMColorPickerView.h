//
//  DMColorPickerView.h
//  DMColorPicker
//
//  Created by Demetri Miller on 10/28/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DMBrightSatPicker.h"
#import "RSColorPickerView.h"

@class DMColorPickerMask;
@class DMColorPickerView;

@interface DMColorPickerView : UIView  <DMBrightSatPickerDelegate, RSColorPickerViewDelegate>
{
    DMBrightSatPicker   *_brightSatPicker;
    RSColorPickerView   *_huePicker;
    DMColorPickerMask   *_hueMask;
}

@property(nonatomic, readonly) UIColor *currentColor;

@end
