//
//  AROverlayOutlineView.h
//  ViewerDemo
//
//  Created by Demetri Miller on 1/31/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AROverlay;
@class ARAugmentedView;

@interface AROverlayOutlineView : UIControl
{
    AROverlay *_overlay;

    NSArray * _scaledOutlinePoints;
    UIBezierPath * _scaledPath;
    NSArray * _animationDurations;
    NSInteger _animationIndex;
}

- (id)initWithOverlay:(AROverlay *)overlay;
- (void)layoutWithinParent:(ARAugmentedView *)parent;
- (void)drawAnimated:(BOOL)animated;

@end
