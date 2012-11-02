//
//  HNSprayCanLoadingView.h
//  Graffiti
//
//  Created by Demetri Miller on 10/14/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNSprayCanLoadingView : UIView
{
    AVAudioPlayer *_player;
    UIView *_dimView;
    UIImageView *_sprayCan;
}

- (void)startAnimation;
- (void)stopAnimation;

@end
