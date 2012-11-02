//
//  HNSprayCanLoadingView.h
//  Graffiti
//
//  Created by Demetri Miller on 10/14/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Layout.h"

@interface HNGraffitiLoadingView : UIView
{
    AVAudioPlayer *_player;
    UIView *_dimView;
    UIImageView *_sprayCan;
}

- (void)startAnimating;
- (void)stopAnimating;

@end
