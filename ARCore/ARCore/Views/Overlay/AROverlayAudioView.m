//
//  AROverlayAudioView.m
//  ViewerDemo
//
//  Created by Demetri Miller on 2/2/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayAudioView.h"

@implementation AROverlayAudioView

- (id)initWithOverlay:(AROverlay *)overlay
{
    self = [super initWithOverlay:overlay];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [_player.view setBackgroundColor:[UIColor clearColor]];
        [_player.view setFrame:self.bounds];
        
        self.animDelegate = self;
    }
    return self;
}

@end
