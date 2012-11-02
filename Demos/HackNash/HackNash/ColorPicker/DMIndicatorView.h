//
//  DMIndicatorView.h
//  DMColorPicker
//
//  Created by Demetri Miller on 10/28/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMIndicatorView : UIView

@property(nonatomic, strong) UIColor *color;
@property(nonatomic, assign) CGPoint normalizedValue;

@end