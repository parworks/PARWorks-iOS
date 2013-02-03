//
//  AROvelayViewFactory.m
//  ViewerDemo
//
//  Created by Demetri Miller on 1/29/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlay.h"
#import "AROverlayAudioView.h"
#import "AROverlayImageView.h"
#import "AROverlayTextView.h"
#import "AROverlayVideoView.h"
#import "AROverlayView.h"
#import "AROverlayViewFactory.h"
#import "AROverlayWebView.h"

@implementation AROverlayViewFactory

+ (AROverlayView *)viewWithOverlay:(AROverlay *)overlay
{
    AROverlayView *view;
    switch (overlay.contentType) {
        case AROverlayContentType_URL:
            view = [[AROverlayWebView alloc] initWithOverlay:overlay];
            break;
        case AROverlayContentType_Video:
            view = [[AROverlayVideoView alloc] initWithOverlay:overlay];
            break;
        case AROverlayContentType_Image:
            view = [[AROverlayImageView alloc] initWithOverlay:overlay];
            break;
        case AROverlayContentType_Audio:
            view = [[AROverlayAudioView alloc] initWithOverlay:overlay];
            break;
        case AROverlayContentType_Text:
            view = [[AROverlayTextView alloc] initWithOverlay:overlay];
            break;
        default:
            break;
    }
    
    return view;
    
}

@end
