//
//  MagView.h
//  MagView
//
//  Created by Demetri Miller on 11/27/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AROverlay.h"
#import "ARPointOverlayView.h"
#import "CachedImageView.h"

@class ARZoomView;



@protocol ARMagViewDelegate <NSObject>
@optional
- (void)didUpdatePointWithOverlay:(AROverlay *)overlay;
@end



@interface ARMagView : UIControl <ARPointOverlayViewDelegate>
{
    UIImage *_image;
    NSString *_imagePath;
}

@property(nonatomic, strong) CachedImageView *imageView;
@property(nonatomic, strong) ARPointOverlayView *pointOverlay;
@property(nonatomic, strong) ARZoomView *zoomView;
@property(nonatomic, weak) id<ARMagViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame imagePath:(NSString *)imagePath;
- (void)setImage:(UIImage *)image;

- (AROverlay *)currentOverlay;

@end



@interface ARZoomView : UIView

@property(nonatomic, weak) UIImageView *fullImageView;
@property(nonatomic, assign) CGPoint currentZoomPoint;

- (id)initWithFrame:(CGRect)frame zoomableImageView:(UIImageView *)image;

@end