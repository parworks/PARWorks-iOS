//
//  AROverlayVideoView.m
//  ViewerDemo
//
//  Created by Demetri Miller on 2/2/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayVideoView.h"
#import "AROverlayView+Animations.h"

@implementation AROverlayVideoView

- (id)initWithOverlay:(AROverlay *)overlay
{
    self = [super initWithOverlay:overlay];
    if (self) {
        self.player = [[MPMoviePlayerController alloc] initWithContentURL:nil];
        _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_player.view setFrame:self.bounds];
        [self addSubview:_player.view];
        _player.view.alpha = 0.0;
        
        self.animDelegate = self;
    }
    return self;
}


#pragma mark - AROverlayViewAnimationDelegate
- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    __weak AROverlayVideoView * weakSelf = self;
    [self animateBounceFocusWithParent:parent centeredBlock:^{
        weakSelf.player.view.alpha = 1.0;
    } complete:^{
        NSURL *url = [NSURL URLWithString:weakSelf.overlay.contentProvider];        
        [weakSelf.player setContentURL:url];
        [weakSelf.player prepareToPlay];
        [weakSelf.player play];
    }];
}

- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    __weak AROverlayVideoView * weakSelf = self;
    [self animateBounceUnfocusWithParent:parent uncenteredBlock:^{
        [weakSelf.player stop];
        weakSelf.player.view.alpha = 0.0;
    } complete:nil];
}

@end
