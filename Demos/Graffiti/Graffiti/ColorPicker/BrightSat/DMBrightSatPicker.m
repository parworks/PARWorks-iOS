//
//  DMBrightSatPicker.m
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

#import "AROverlayBuilderView.h"
#import "DMColorPickerConstants.h"
#import "DMBrightSatPicker.h"
#import "DMIndicatorView.h"
#import "InfHSBSupport.h"
#import "UIView+Layout.h"


@implementation DMBrightSatPicker


#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.contentsScale = [UIScreen mainScreen].scale;
    shape.backgroundColor = [UIColor clearColor].CGColor;
    shape.strokeColor = [UIColor whiteColor].CGColor;
    shape.fillColor = [UIColor clearColor].CGColor;
    shape.lineWidth = 2.0;
    shape.frame = self.bounds;
    shape.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    [self.layer addSublayer:shape];
    
    self.indicator = [[DMIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kDMColorPickerIndicatorRadius*2, kDMColorPickerIndicatorRadius*2)];
    [self addSubview:_indicator];
    
    [self addTarget:self action:@selector(handleTouch:forEvent:) forControlEvents:UIControlEventTouchDragEnter|UIControlEventTouchDown|UIControlEventTouchDragInside];
    self.multipleTouchEnabled = NO;
    
    self.hue = 0.5;
    [self setNeedsDisplay];
}


#pragma mark - User Interaction
- (void)handleTouch:(id)sender forEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self];
    [self handleTouchAtPoint:p];
}

- (void)handleTouchAtPoint:(CGPoint)p
{
    // Make sure the location of the indicator is bounded inside the view.
    CGPoint center;
    CGFloat inset = 0;
    center.x = pin(inset, p.x, self.width-inset);
    center.y = pin(inset, p.y, self.height-inset);
    _indicator.center = center;
    
    center.x = (p.x - inset)/(self.width - 2 * inset);
    center.y = (p.y - inset)/(self.height - 2 * inset);
    center.x = pin(0, center.x, 1);
    center.y = 1 - pin(0, center.y, 1);
    _brightnessPoint = center;
    [self updateIndicatorColorWithCurrentHue];
    
    if (_delegate && [_delegate respondsToSelector:@selector(brightSatPickerChanged)]) {
        [_delegate brightSatPickerChanged];
    }
}


#pragma mark - Drawing
- (void)updateContent
{
	CGImageRef imageRef = createSaturationBrightnessSquareContentImageWithHue(_hue * 360);
    self.layer.contents = (__bridge id)imageRef;
	_image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
}

- (void)updateIndicatorColorWithCurrentHue
{
    _indicator.color = [UIColor colorWithHue:_hue saturation:_brightnessPoint.x brightness:_brightnessPoint.y alpha:1.0];
}


#pragma mark - Getters/Setters
- (void)setHue:(float)hue
{
    _hue = hue;
    [self updateContent];
    [self updateIndicatorColorWithCurrentHue];
}

@end
