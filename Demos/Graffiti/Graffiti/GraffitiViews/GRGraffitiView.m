//
//  GRGraffitiView.m
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


#import "ARAugmentedView.h"
#import "AROverlayUtil.h"
#import "GRGraffitiView.h"
#import "SimplePaintView.h"
#import "GRViewController.h"

static BOOL _animating = NO;

@implementation GRGraffitiView

- (id)initWithOverlay:(AROverlay *)model
{
    self = [super initWithOverlay:model];
    if (self) {
        self.backgroundView = [[SimplePaintView alloc] initWithFrame:self.bounds];
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    srand(time(0));
    self.sprayView = [[GRSprayView alloc] initWithFrame:self.bounds animatedRevealImageFormat:@"spray_%d.png" delegate:self];
    [self addSubview:_sprayView];
    _sprayView.hidden = YES;
    
    self.graffitiMask = [[SimplePaintView alloc] initWithFrame:self.bounds];
    _graffitiMask.backgroundColor = [UIColor clearColor];
    _backgroundView.layer.mask = _graffitiMask.layer;
    [self addSubview:_backgroundView];
    
    _graffitiMask.userInteractionEnabled = NO;
    _backgroundView.userInteractionEnabled = NO;
    _sprayView.userInteractionEnabled = NO;
}

- (void)dealloc
{
    
}

- (void)reveal
{
    [self revealWithType:SprayViewRevealType_TopBottom];
}

- (void)revealWithRandomType
{
    // Poor man's way of forcing views to reveal one at a time.
    if (_animating) {
        [self performSelector:@selector(revealWithRandomType) withObject:nil afterDelay:1.0];
    } else {
        // Unlock will occur in the animation end delegate.
        _animating = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self revealWithType:rand()%SprayViewRevealTypeCount];
    }
}

- (void)revealWithType:(SprayViewRevealType)type
{
    _sprayView.hidden = NO;
    [self bringSubviewToFront:_sprayView];
    [_sprayView revealWithRevealType:type];
}

#pragma mark - GRSprayViewDelegate

- (void)sprayViewPositionChanged:(CGPoint)position
{
    [_graffitiMask strokedToPoint:position];
}

- (void)sprayViewAnimationEnded
{
    _backgroundView.layer.mask = nil;
    _animating = NO;
}

@end
