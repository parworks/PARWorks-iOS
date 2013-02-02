//
//  AROverlayOutlineView.h
//  ViewerDemo
//
//  Created by Demetri Miller on 1/31/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AROverlay;

@interface AROverlayOutlineView : UIControl
{
    AROverlay *_overlay;
    CGFloat _overlayScaleFactor;

    NSArray *_scaledOutlinePoints;
    NSArray *_animationDurations;
    NSInteger _animationIndex;
}

- (id)initWithOverlay:(AROverlay *)overlay scaleFactor:(CGFloat)scaleFactor;
- (void)drawAnimated:(BOOL)animated;

@end
