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
#import "ARAugmentedPhoto.h"
#import "AROverlayView.h"

@class AROverlay;

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
@end


/**
    This UIView subclass is the view used for displaying the final
    result of a client-submitted photo that has been augmented by our 
    servers.
 
    Developers using this class should use the custom init method which
    takes as arguments the image submitted and also a 2D array of points for
    the overlays that should be drawn.
 */
@interface ARAugmentedView : UIView
{
    AROverlayView *_focusedView;
    BOOL _overlayZoomed;
}

/// The photo model read used by this class for displaying the augmented photo.
@property(nonatomic, strong) ARAugmentedPhoto * augmentedPhoto;

/// A container for all overlay views being displayed in the view.
@property(nonatomic, strong, readonly) NSMutableArray *overlayViews;

/// The image view that displays the image taken by the client.
@property(nonatomic, strong) UIImageView * overlayImageView;

/// The scale factor to apply to overlays to have them fit correctly in the
/// scaled augmented view.
@property(nonatomic, assign) CGFloat overlayScaleFactor;

/// The delegate for the augmented view.
@property(nonatomic, weak) IBOutlet id<ARAugmentedViewDelegate> delegate;

@end

