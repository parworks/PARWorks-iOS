//
//  MagView.h
//  MagView
//
//  Created by Demetri Miller on 11/27/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARPointOverlayView.h"

@class ARZoomView;

@interface ARMagView : UIControl
{
    UIImage *_image;
}

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) ARPointOverlayView *pointOverlay;
@property(nonatomic, strong) ARZoomView *zoomView;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void)setImage:(UIImage *)image;

@end



@interface ARZoomView : UIView

@property(nonatomic, weak) UIImageView *fullImageView;
@property(nonatomic, assign) CGPoint currentZoomPoint;

- (id)initWithFrame:(CGRect)frame zoomableImageView:(UIImageView *)image;

@end