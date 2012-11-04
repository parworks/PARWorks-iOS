//
//  RSColorPickerView.h
//  RSColorPicker
//
//  Created by Ryan Sullivan on 8/12/11.
//  Copyright 2011 Freelance Web Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ANImageBitmapRep.h"
#import "DMBrightSatPicker.h"

@class DMColorPickerMask;
@class RSColorPickerView;

@protocol RSColorPickerViewDelegate <NSObject>
@required
-(void)colorPickerDidChangeSelection:(RSColorPickerView*)cp;
@end



@interface RSColorPickerView : UIView
{
	ANImageBitmapRep *_rep;
	
    DMIndicatorView *_indicator;
	CGPoint _selection;
	DMColorPickerMask *_mask;
    
	BOOL _badTouch;
	BOOL _bitmapNeedsUpdate;
}

@property(nonatomic, assign) CGFloat brightness;
@property(nonatomic, assign) BOOL cropToCircle;
@property(nonatomic, weak) id<RSColorPickerViewDelegate> delegate;

- (UIColor*)selectionColor;
- (CGPoint)selection;
- (void)setSelectionColor:(UIColor *)selectionColor;

/**
 * Hue, saturation and briteness of the selected point
 * @Reference: Taken From ars/uicolor-utilities 
 * http://github.com/ars/uicolor-utilities
 */

- (void)selectionToHue:(CGFloat *)pH saturation:(CGFloat *)pS brightness:(CGFloat *)pV;
- (UIColor*)colorAtPoint:(CGPoint)point; //Returns UIColor at a point in the RSColorPickerView

@end
