//
//  ARCameraOverlayTooltip.h
//  ARCore
//
//  Created by Demetri Miller on 2/18/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARCameraOverlayTooltipArrow;

@interface ARCameraOverlayTooltip : UIView

@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) ARCameraOverlayTooltipArrow *arrow;

- (void)updateArrowLocationForDeviceOrientation:(UIDeviceOrientation)orientation;

@end


@interface ARCameraOverlayTooltipArrow : UIView
@property(nonatomic, strong) UIColor *fillColor;
@end