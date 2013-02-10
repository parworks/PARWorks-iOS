//
//  AROverlayVideoView.h
//  ViewerDemo
//
//  Created by Demetri Miller on 2/2/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AROverlayVideoView : AROverlayView<AROverlayViewAnimationDelegate>{
    MPMoviePlayerController *_player;
}

@property(nonatomic, strong) MPMoviePlayerController *player;

@end
