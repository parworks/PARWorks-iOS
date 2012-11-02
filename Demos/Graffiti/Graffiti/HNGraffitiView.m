//
//  HNGraffitiView.m
//  Graffiti
//
//  Created by Demetri Miller on 10/13/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "HNGraffitiView.h"
#import "SimplePaintView.h"

@implementation HNGraffitiView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor greenColor].CGColor;
        self.layer.borderWidth = 2.0;
        self.graffitiView = [[UIImageView alloc] initWithImage:image];
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.sprayView = [[HNSprayView alloc] initWithFrame:self.bounds animatedRevealImageFormat:@"spray_%d.png" delegate:self];
    [self addSubview:_sprayView];
    _sprayView.hidden = YES;
    
    self.graffitiMask = [[SimplePaintView alloc] initWithFrame:self.bounds];
    _graffitiMask.backgroundColor = [UIColor clearColor];
    _graffitiView.layer.mask = _graffitiMask.layer;
    [self addSubview:_graffitiView];
}

- (void)reveal
{
    _sprayView.hidden = NO;
    [self bringSubviewToFront:_sprayView];
    [_sprayView revealWithRevealType:SprayViewRevealType_TopBottom];
}


#pragma mark - HNSprayViewDelegate
- (void)sprayViewPositionChanged:(CGPoint)position
{
    [_graffitiMask strokedToPoint:position];
}

@end
