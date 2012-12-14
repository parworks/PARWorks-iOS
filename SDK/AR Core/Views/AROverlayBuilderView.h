//
//  MagView.h
//  MagView
//
//  Created by Demetri Miller on 11/27/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AROverlay.h"
#import "AROverlayBuilderAnnotationView.h"
#import "CachedImageView.h"

@class ARMagnifiedLensView;



@protocol ARMagViewDelegate <NSObject>
@optional
- (void)didUpdatePointWithOverlay:(AROverlay *)overlay;
@end



@interface AROverlayBuilderView : UIControl <AROverlayBuilderAnnotationViewDelegate>
{
    ARSiteImage * _siteImage;
}

@property(nonatomic, strong) CachedImageView *imageView;
@property(nonatomic, strong) AROverlayBuilderAnnotationView * annotationView;
@property(nonatomic, strong) ARMagnifiedLensView *lensView;
@property(nonatomic, weak) id<ARMagViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)setSiteImage:(ARSiteImage*)siteImage;

- (AROverlay *)currentOverlay;

@end



@interface ARMagnifiedLensView : UIView
{
    CGLayerRef _cacheLayer;
}

@property(nonatomic, weak) UIImageView *fullImageView;
@property(nonatomic, assign) CGPoint currentZoomPoint;

- (id)initWithFrame:(CGRect)frame zoomableImageView:(UIImageView *)image;

@end