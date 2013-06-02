//
//  AROverlayView.h
//  PAR Works iOS SDK
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
#import <QuartzCore/QuartzCore.h>
#import "AROverlay.h"

#define CENTROID_SIZE 30

@class ARAugmentedView;
@class AROverlayView;

// Notification posted when overlay view is focused
#define NOTIF_OVERLAY_VIEW_FOCUSED @"NOTIF_OVERLAY_VIEW_FOCUSED"
#define NOTIF_OVERLAY_VIEW_UNFOCUSED @"NOTIF_OVERLAY_VIEW_UNFOCUSED"

/** There are three main attachment styles used for displaying overlay views.
 
    @param AROverlayAttachmentStyle_Skew - Scales and transforms the overlay points directly onto the augmented view.
    @param AROverlayAttachmentStyle_Bounded - The overlay's frame is the smallest rect containing all overlay points.
    @param AROverlayAttachmentStyle_Centered - The overlay isn't transformed, but centered. (not finished)
 */
typedef enum {
    AROverlayAttachmentStyle_Skew
} AROverlayAttachmentStyle;


/** Animation delegate protocol provides methods that the OverlayView class
    will call when it is told to focus or unfocus itself.
 */
@protocol AROverlayViewAnimationDelegate <NSObject>
@required
/** Called when an overlay should bring itself to focus on the screen
 
    @param overlayView - The overlayView to be focused
    @param parent - The owner of the overlayView. This view is passed so
            the animation delegate can handle any sort of centering or other
            logic that may be needed to make the animation work.
 */
- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent;

/** Called when an overlay should unfocus itself
 
    @param overlayView - The overlayView to be unfocused
    @param parent - The owner of the overlayView. This view is passed so
            the animation delegate can handle any sort of centering or other
            logic that may be needed to make the animation work.
 */
- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent;

@end


@interface AROverlayView : UIControl

@property(nonatomic, weak) UIView *outlineView;
@property(nonatomic, strong) UIView *coverView;


@property(nonatomic, strong) AROverlay *overlay;
@property(nonatomic, assign) AROverlayAttachmentStyle attachmentStyle;
@property(nonatomic, weak) id<AROverlayViewAnimationDelegate> animDelegate;
 
// ========================
// @name Lifecycle
// ========================

/** Creates a new overlay with a frame set to the minimum bounding frame needed by the points.
 
    @param points - The unscaled coordinates for the overlay in its superview.
 */
- (id)initWithPoints:(NSArray *)points;

/** Creates a new overlay with the points passed. 
    
    @param frame - The frame for the view when it has no transforms applied to it.
                    It is recommended to set the frame such that it is smaller than the 
                    bounds of the image that will be displayed.
    @param points - The unscaled coordinates for the overlay in its superview.
 
 */
- (id)initWithFrame:(CGRect)frame points:(NSArray *)points;

/** Creates a new overlay view using the AROverlay provided. 

  @param overlay The overlay that this AROverlayView will display.
*/
- (id)initWithOverlay:(AROverlay*)overlay;


/** Creates a new overlay view using the frame and AROverlay provided.
 @param frame The frame for the view when it has no transform applied.
 @param overlay The overlay that this AROverlayView will display.
 */
- (id)initWithFrame:(CGRect)frame overlay:(AROverlay *)overlay;


// ========================
// @name Styling
// ========================
/** Styles the view according to the AROverlay properties.
 */
- (void)applyOverlayStyles;


// ========================
// @name Presentation
// ========================

/** Focuses the overlay, usually by enlarging it and centering it onscreen with more
content displayed. This function can be replaced in subclasses to perform other behaviors
when an overlay view is clicked.

  @param The ARAugmentedView that the overlay is being presented in.
*/
- (void)focusInParent:(ARAugmentedView *)parent;

/** Unfocuses the overlay, usually returning it to it's state on top of the augmented image.
 This function can be replaced in subclasses to customize the behavior of the overlay view.
 
 @param The ARAugmentedView that the overlay is being presented in.
*/
- (void)unfocusInParent:(ARAugmentedView *)parent;

// ========================
// @name Transforms
// ========================

/** Apply the current overlay attachment style transforming and positioning 
    it as needed.

 @param parent The parent ARAugmentedView that transforms should be applied relative to.
*/

- (void)layoutWithinParent:(ARAugmentedView *)parent;

@end
