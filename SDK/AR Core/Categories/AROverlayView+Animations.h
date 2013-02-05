//
//  AROverlayView+Animations.h
//  ViewerDemo
//
//  Created by Demetri Miller on 1/31/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayView.h"

@class ARAugmentedView;

typedef void(^AROverlayViewAnimationFocusCenter)(void);
typedef void(^AROverlayViewAnimationUnfocusCenter)(void);
typedef void(^AROverlayViewAnimationFocusCompletion)(void);

@interface AROverlayView (Animations)

/** Standard bounce effect used for showing an AROverlayView's content view.
 @param parent The parent view owning the overlay view.
 @param centered Block that is called once the view has been moved to the center of the view.
 @param complete Block that is called once the animation has completed.
 */
- (void)animateBounceFocusWithParent:(ARAugmentedView *)parent
                       centeredBlock:(AROverlayViewAnimationFocusCenter)centered
                            complete:(AROverlayViewAnimationFocusCompletion)complete;


/** Standard bounce effect used for showing an AROverlayView's content view.
 @param parent The parent view owning the overlay view.
 @param uncentered Block that is called once the view has been moved to the center of the view.
        Called inside an animation block.
 @param complete Block that is called once the animation has completed.
 */
- (void)animateBounceUnfocusWithParent:(ARAugmentedView *)parent
                       uncenteredBlock:(AROverlayViewAnimationUnfocusCenter)uncentered
                              complete:(AROverlayViewAnimationFocusCompletion)complete;

@end
