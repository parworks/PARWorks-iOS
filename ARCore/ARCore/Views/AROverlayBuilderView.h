//
//  AROverlayBuilderView.h
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
#import "AROverlay.h"
#import "AROverlayBuilderAnnotationView.h"
#import "CachedImageView.h"

@class ARMagnifiedLensView;



@protocol ARMagViewDelegate <NSObject>
@optional
- (void)didUpdatePointWithOverlay:(AROverlay *)overlay;
- (void)didDoubleTapOverlay:(AROverlay*)overlay;
@end



@interface AROverlayBuilderView : UIControl <AROverlayBuilderAnnotationViewDelegate>
{
    ARSiteImage * _siteImage;
    
    int _pointIndex;
    int _overlayIndex;
    
    NSTimeInterval _lastInsideTouchTimestamp;
    AROverlay * _lastInteractedOverlay;
}

@property(nonatomic, strong) CachedImageView *imageView;
@property(nonatomic, assign) int maxPointsPerOverlay;
@property(nonatomic, strong) AROverlayBuilderAnnotationView * annotationView;
@property(nonatomic, strong) ARMagnifiedLensView *lensView;
@property(nonatomic, weak) id<ARMagViewDelegate> delegate;

float pin(float minValue, float value, float maxValue);

- (id)initWithFrame:(CGRect)frame;
- (void)setSiteImage:(ARSiteImage*)siteImage;

- (AROverlay *)lastInteractedOverlay;

@end



@interface ARMagnifiedLensView : UIView
{
    CGLayerRef _cacheLayer;
}

@property(nonatomic, weak) UIImageView *fullImageView;
@property(nonatomic, assign) CGPoint currentZoomPoint;

- (id)initWithFrame:(CGRect)frame zoomableImageView:(UIImageView *)image;

@end