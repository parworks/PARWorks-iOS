//
//  SprayView.h
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

typedef enum {
    SprayViewRevealType_TopBottom = 0,
    SprayViewRevealType_LeftRight,
    SprayViewRevealType_Diagonal,
    SprayViewRevealTypeCount
} SprayViewRevealType;


@protocol GRSprayViewDelegate <NSObject>

- (void)sprayViewPositionChanged:(CGPoint)position;
- (void)sprayViewAnimationEnded;
@end


@interface GRSprayView : UIView
{
    UIImageView     *_revealImage;
    NSTimer         *_revealTimer;
    AVAudioPlayer   *_player;
    
    __weak id<GRSprayViewDelegate> _delegate;
}

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame animatedRevealImageFormat:(NSString *)format delegate:(id<GRSprayViewDelegate>)delegate;

#pragma mark - Revealing
- (void)revealWithRevealType:(SprayViewRevealType)type;

@end
