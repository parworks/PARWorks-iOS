//
//  HNGraffitiView.h
//  Graffiti
//
//  Created by Demetri Miller on 10/13/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNSprayView.h"

@class SimplePaintView;

@interface HNGraffitiView : UIView <HNSprayViewDelegate>

@property(nonatomic, strong) UIImageView *graffitiView;
@property(nonatomic, strong) SimplePaintView *graffitiMask;
@property(nonatomic, strong) HNSprayView *sprayView;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void)reveal;
@end
