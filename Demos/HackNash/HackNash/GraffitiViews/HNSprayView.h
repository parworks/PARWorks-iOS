//
//  SprayView.h
//  Graffiti
//
//  Created by Demetri Miller on 10/12/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SprayViewRevealType_TopBottom = 0,
    SprayViewRevealType_LeftRight,
    SprayViewRevealType_Diagonal,
    SprayViewRevealTypeCount
} SprayViewRevealType;


@protocol HNSprayViewDelegate <NSObject>

- (void)sprayViewPositionChanged:(CGPoint)position;
- (void)sprayViewAnimationEnded;
@end


@interface HNSprayView : UIView
{
    UIImageView     *_revealImage;
    NSTimer         *_revealTimer;
    AVAudioPlayer   *_player;
    
    __weak id<HNSprayViewDelegate> _delegate;
}

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame animatedRevealImageFormat:(NSString *)format delegate:(id<HNSprayViewDelegate>)delegate;

#pragma mark - Revealing
- (void)revealWithRevealType:(SprayViewRevealType)type;

@end
