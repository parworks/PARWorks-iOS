//
//  DMColorPickerView.m
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


#import "DMColorPickerConstants.h"
#import "DMColorPickerMask.h"
#import "DMColorPickerView.h"
#import "DMIndicatorView.h"
#import "UIColor+Util.h"
#import "UIView+Layout.h"

#define kDMColorPickerHueColor @"kDMColorPickerHueKey"
#define kDMColorPickerBrightSatTouchPoint @"kDMColorPickerBrightSatTouchPoint"

@implementation DMColorPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = self.width/2;
        self.layer.masksToBounds = YES;
        
        CGPoint center = CGPointMake(self.width/2, self.height/2);
        _huePicker = [[RSColorPickerView alloc] initWithFrame:self.bounds];
        _huePicker.delegate = self;
        _huePicker.center = center;
        [self addSubview:_huePicker];
        
        // Dividing by 1.41 (roughly sqrt(2))
        _brightSatPicker = [[DMBrightSatPicker alloc] initWithFrame:CGRectMake(0, 0, (self.width/1.41) - (kDMColorPickerMaskStrokeWidth*2), (self.height/1.41) - (kDMColorPickerMaskStrokeWidth*2))];
        _brightSatPicker.delegate = self;
        _brightSatPicker.center = center;
        [self addSubview:_brightSatPicker];
        [self updateViewForUserDefaults];
    }
    return self;
}

- (UIColor *)currentColor
{
    return _brightSatPicker.indicator.color;
}

#pragma mark - User Defaults
- (void)updateViewForUserDefaults
{
    NSString *colorStr = [[NSUserDefaults standardUserDefaults] objectForKey:kDMColorPickerHueColor];
    NSString *pointStr =[[NSUserDefaults standardUserDefaults] objectForKey:kDMColorPickerBrightSatTouchPoint];
    
    if (!colorStr || !pointStr) {
        [_huePicker setSelectionColor:[UIColor colorWithHue:0.58 saturation:0.92 brightness:0.92 alpha:1.0]];
        [_brightSatPicker handleTouchAtPoint:CGPointMake(self.width, 0)];
    } else {
        [_huePicker setSelectionColor:[UIColor grColorWithString:colorStr]];
        [_brightSatPicker handleTouchAtPoint:CGPointFromString(pointStr)];
    }
}

- (void)saveValuesToUserDefaults
{
    // Save a color
    NSString *colorStr = [[_huePicker selectionColor] stringFromColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorStr forKey:kDMColorPickerHueColor];
    
    NSString *pointStr = NSStringFromCGPoint(_brightSatPicker.indicator.center);
    [[NSUserDefaults standardUserDefaults] setObject:pointStr forKey:kDMColorPickerBrightSatTouchPoint];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Color Picker Delegates
-(void)colorPickerDidChangeSelection:(RSColorPickerView *)cp
{
    CGFloat hue, sat, bri;
    [cp selectionToHue:&hue saturation:&sat brightness:&bri];
    
    _brightSatPicker.hue = hue;
    self.backgroundColor = [UIColor colorWithHue:hue saturation:_brightSatPicker.brightnessPoint.x brightness:_brightSatPicker.brightnessPoint.y alpha:1.0];
    [self saveValuesToUserDefaults];
}

- (void)brightSatPickerChanged
{
    self.backgroundColor = _brightSatPicker.indicator.color;
    [self saveValuesToUserDefaults];
}

@end
