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
@class HNViewController;

@interface HNGraffitiView : AROverlayView <HNSprayViewDelegate, AROverlayViewAnimationDelegate>

@property(nonatomic, weak) HNViewController * controller;
@property(nonatomic, strong) SimplePaintView *backgroundView;
@property(nonatomic, strong) SimplePaintView *graffitiMask;
@property(nonatomic, strong) HNSprayView *sprayView;

- (void)reveal;
- (void)revealWithRandomType;
- (void)revealWithType:(SprayViewRevealType)type;

@end
