//
//  AROvelayViewFactory.m
//  ViewerDemo
//
//  Created by Demetri Miller on 1/29/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlay.h"
#import "AROverlayView.h"
#import "AROvelayViewFactory.h"

@implementation AROvelayViewFactory

+ (AROverlayView *)overlayViewWithOverlay:(AROverlay *)overlay
{
    AROverlayView *view;
    switch (overlay.contentType) {
        case AROverlayContentType_URL:
            break;
        case AROverlayContentType_Video:
            break;
        case AROverlayContentType_Image:
            break;
        case AROverlayContentType_Audio:
            break;
        case AROverlayContentType_Text:
        default:
            break;
    }
    
    return view;
    
}

@end
