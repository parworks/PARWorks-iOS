//
//  SprayView.m
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


#import "GRSprayView.h"
#import "UIImageView+AnimationAdditions.h"

@implementation GRSprayView


#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame animatedRevealImageFormat:(NSString *)format delegate:(id<GRSprayViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate;
        _revealImage = [[UIImageView alloc] initWithImageSeries:format];
        _revealImage.layer.shadowColor = [UIColor blackColor].CGColor;
        _revealImage.layer.shadowOffset = CGSizeMake(0, 0);
        _revealImage.layer.shadowOpacity = 0.5;
        _revealImage.layer.shadowRadius = 4.0;
        
        _revealImage.animationRepeatCount = INT_MAX;
        [self addSubview:_revealImage];
        
        UIImageView *sprayCan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spray_can_with_spray.png"]];
        sprayCan.x = _revealImage.width - 20;
        sprayCan.y = 15;
        [_revealImage addSubview:sprayCan];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"spray_painting" ofType:@"mp3"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        _player = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [_player prepareToPlay];
    }
    return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [_player stop];
    _revealImage.hidden = YES;
    [_revealTimer invalidate];
    _revealTimer = nil;
    [_revealImage stopAnimating];
    
    [_delegate sprayViewAnimationEnded];
}


#pragma mark - Revealing
- (void)updateStamp
{
//    NSLog(@"%@", NSStringFromCGPoint([_revealImage.layer.presentationLayer position]));
    if (_delegate && [_delegate respondsToSelector:@selector(sprayViewPositionChanged:)]) {
        [_delegate sprayViewPositionChanged:[((CALayer *)_revealImage.layer.presentationLayer) position]];
    }
}

- (void)revealWithRevealType:(SprayViewRevealType)type
{
    [_player play];
    _revealImage.hidden = NO;
    [_revealTimer invalidate];
    _revealTimer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(updateStamp) userInfo:nil repeats:YES];
    
    UIBezierPath *path = [self pathForRevealType:type];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    anim.duration = 2.0;
    anim.fillMode = kCAFillModeForwards;
    anim.rotationMode = nil;
    anim.path = path.CGPath;
    anim.delegate = self;
    [_revealImage.layer addAnimation:anim forKey:nil];
    _revealImage.center = path.currentPoint;
    [_revealImage startAnimating];
}

- (UIBezierPath *)pathForRevealType:(SprayViewRevealType)type
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat step = 20;
    switch (type) {
        case SprayViewRevealType_TopBottom: {
            CGFloat yOffset = 0;
            [path moveToPoint:CGPointMake(0, 0)];
            while (yOffset < self.height) {
                yOffset += step;
                [path addLineToPoint:CGPointMake(self.width, yOffset)];
                yOffset += step;
                [path addLineToPoint:CGPointMake(0, yOffset)];
            }
            break;
        }
        case SprayViewRevealType_LeftRight: {
            CGFloat xOffset = 0;
            [path moveToPoint:CGPointMake(0, 0)];
            while (xOffset < self.width) {
                xOffset += step;
                [path addLineToPoint:CGPointMake(xOffset, self.height)];
                xOffset += step;
                [path addLineToPoint:CGPointMake(xOffset, 0)];
            }
            break;
        }
            
        case SprayViewRevealType_Diagonal: {
            CGFloat xOffset = 0;
            CGFloat yOffset = 0;
            [path moveToPoint:CGPointMake(0, 0)];
            while (xOffset < self.width || yOffset < self.height) {
                xOffset += step;
                [path addLineToPoint:CGPointMake(MIN(xOffset, self.width), 0)];
                [path addLineToPoint:CGPointMake(0, MIN(yOffset, self.height))];
                yOffset += step;
            }
            
            xOffset = 0;
            yOffset = 0;
            
            while (xOffset < (self.width*2) || yOffset < (self.height*2)) {
                xOffset += step;
                [path addLineToPoint:CGPointMake(MIN(xOffset, self.width), self.height)];
                [path addLineToPoint:CGPointMake(self.width, MIN(yOffset, self.height))];
                yOffset += step;
            }
            break;
        }
        default:
            break;
    }
    return path;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
