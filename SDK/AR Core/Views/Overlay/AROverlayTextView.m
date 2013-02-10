//
//  AROverlayTextView.m
//  ViewerDemo
//
//  Created by Demetri Miller on 2/2/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayTextView.h"

@implementation AROverlayTextView

- (id)initWithOverlay:(AROverlay *)overlay
{
    self = [super initWithOverlay:overlay];
    if (self) {
       
    }
    return self;
}

- (void)focusOverlayViewCompleted:(AROverlayWebView*)overlayWebView{
    NSString *html = [NSString stringWithFormat:@"<html><head><title>%@</title></head><body><p>%@</p></body></html>", overlayWebView.overlay.name, overlayWebView.overlay.contentProvider];
    [overlayWebView.webView loadHTMLString:html baseURL:nil];
}

@end
