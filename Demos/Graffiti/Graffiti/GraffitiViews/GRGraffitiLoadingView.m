//
//  GRSprayCanLoadingView.m
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


#import "GRGraffitiLoadingView.h"

@implementation GRGraffitiLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        _sprayCan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spray_can.png"]];
        _sprayCan.transform = CGAffineTransformMakeRotation(-M_PI_2);
        _sprayCan.alpha = 0.0;
        [self addSubview:_sprayCan];
        
        _dimView = [[UIView alloc] initWithFrame:self.bounds];
        _dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _dimView.backgroundColor = [UIColor blackColor];
        _dimView.alpha = 0.0;
        [self addSubview:_dimView];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"spray_can_shake" ofType:@"mp3"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        _player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        _player.numberOfLoops = INT_MAX;
        [_player prepareToPlay];
    }
    return self;
}


#pragma mark - Animations
- (UIBezierPath *)animationPath
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(3*self.width/4, self.height/4)];
    [path addCurveToPoint:CGPointMake(3*self.width/4, 3*self.height/4)
            controlPoint1:CGPointMake(3*self.width/4 - 20, self.height/2)
            controlPoint2:CGPointMake(3*self.width/4 - 20, self.height/2)];
    return path;
}

- (void)startAnimating
{
    [UIView animateWithDuration:0.5 animations:^{
        _dimView.alpha = 0.3;
        _sprayCan.alpha = 1.0;
    }];
    
    _sprayCan.hidden = NO;
    [_player play];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    anim.repeatCount = INT_MAX;
    anim.repeatDuration = INT_MAX;
    anim.autoreverses = YES;
    anim.duration = 0.20;
    anim.rotationMode = kCAAnimationRotateAuto;
    anim.path = [self animationPath].CGPath;
    [_sprayCan.layer addAnimation:anim forKey:nil];
}

- (void)stopAnimating
{
    [UIView animateWithDuration:0.25 animations:^{
        _dimView.alpha = 0.0;
        _sprayCan.alpha = 0.0;
    }];
    
    [_sprayCan.layer removeAllAnimations];
    [_player stop];
}


@end
