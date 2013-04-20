//
//  AROverlayImageView.h
//  ViewerDemo
//
//  Created by Demetri Miller on 2/2/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayView.h"

@interface AROverlayImageView : AROverlayView <AROverlayViewAnimationDelegate>

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIActivityIndicatorView *activity;

@end
