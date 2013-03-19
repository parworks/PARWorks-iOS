//
//  ARAugmentedView.h
//  PAR Works iOS SDK
//
//  Copyright 2013 PAR Works, Inc.
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


@class ARAugmentedPhoto;
@class ARLoadingView;
@class AROverlay;
@class AROverlayOutlineView;
@class AROverlayView;
@class ARTotalAugmentedImagesView;

#define NOTIF_PRESENT_NAVCONTROLLER_FULLSCREEN @"NOTIF_PRESENT_NAVCONTROLLER_FULLSCREEN"
#define NOTIF_DISMISS_NAVCONTROLLER_FULLSCREEN @"NOTIF_DISMISS_NAVCONTROLLER_FULLSCREEN"

/** 
    This protocol provides a way for users to supply their own
    custom overlay view subclasses for the augmented view to display.
 */
@protocol ARAugmentedViewDelegate <NSObject>
@optional

/** Asks the delegate for an overlay view based on the overlay object passed.
    @param overlay - The overlay model object that should back the overlay view.
    @return A newly initialized AROverlayView for display. 
 */
- (AROverlayView *)overlayViewForOverlay:(AROverlay *)overlay;

- (AROverlayOutlineView *)outlineViewForOverlay:(AROverlay *)overlay;
@end


/**
    This UIView subclass is the view used for displaying the final
    result of a client-submitted photo that has been augmented by our 
    servers.
 */
@interface ARAugmentedView : UIControl
{
    AROverlayView *_focusedOverlayView;    
    BOOL _overlayZoomed;    
}

/// The photo model read used by this class for displaying the augmented photo.
@property(nonatomic, strong) ARAugmentedPhoto * augmentedPhoto;

@property(nonatomic, strong) ARTotalAugmentedImagesView *totalAugmentedImagesView;

/// A container for all overlay views being displayed in the view.
@property(nonatomic, strong, readonly) NSMutableArray *overlayViews;

/// A container for all the outline views being displayed in the view.
@property(nonatomic, strong, readonly) NSMutableArray *outlineViews;

/// A container for all the outline views being displayed in the view.
@property(nonatomic, strong, readonly) NSMutableArray *overlayTitleViews;

/// The image view that displays the image taken by the client.
@property(nonatomic, strong) UIImageView * overlayImageView;

/// The content mode to use for the overlayImageView.
@property(nonatomic, assign) UIViewContentMode overlayImageViewContentMode;

/// The scale factor to apply to overlays to have them fit correctly in the
/// scaled augmented view.
@property(nonatomic, assign) CGFloat overlayScaleFactor;

/// The origin of the loading view. If none set then defaults to center of view
@property(nonatomic, assign) CGPoint loadingViewPoint;

/// The view will only display outline views. AROverlayViews are not displayed. Defaults to NO.
@property(nonatomic, assign) BOOL showOutlineViewsOnly;

/// Tells the view whether or not it should animate the drawing of outline views. Defaults to YES.
@property(nonatomic, assign) BOOL animateOutlineViewDrawing;

/// The delegate for the augmented view.
@property(nonatomic, weak) IBOutlet id<ARAugmentedViewDelegate> delegate;

// The loading view that displays during loading
@property(nonatomic, strong) ARLoadingView *loadingView;

- (void)setVisibile:(BOOL)visible forOverlayViewsWithName:(NSString *)name;

/// Posts notification to present a navigation controller fullscreen
- (void)presentFullscreenNavigationController:(UINavigationController*)controller;

@end

