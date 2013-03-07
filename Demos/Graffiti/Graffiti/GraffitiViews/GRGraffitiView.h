//
//  GRGraffitiView.h
//  Graffiti
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
#import "AROverlayView.h"
#import "GRSprayView.h"

@class SimplePaintView;
@class GRViewController;

@interface GRGraffitiView : AROverlayView <GRSprayViewDelegate>

@property(nonatomic, weak) GRViewController * controller;
@property(nonatomic, strong) SimplePaintView *backgroundView;
@property(nonatomic, strong) SimplePaintView *graffitiMask;
@property(nonatomic, strong) GRSprayView *sprayView;

- (void)reveal;
- (void)revealWithRandomType;
- (void)revealWithType:(SprayViewRevealType)type;

@end
