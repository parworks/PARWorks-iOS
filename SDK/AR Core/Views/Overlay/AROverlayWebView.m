//
//  AROverlayURLView.m
//  ViewerDemo
//
//  Created by Demetri Miller on 1/30/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayWebView.h"
#import "AROverlayView+Animations.h"

@implementation AROverlayWebView

- (id)initWithOverlay:(AROverlay *)overlay
{
    self = [super initWithOverlay:overlay];
    if (self) {
        self.webView = [[UIWebView alloc] initWithFrame:self.bounds];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_webView];
        _webView.alpha = 0.0;
        
        self.animDelegate = self;
    }
    return self;
}


#pragma mark - AROverlayViewAnimationDelegate
- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    __weak AROverlayWebView * weakSelf = self;
    [self animateBounceFocusWithParent:parent centeredBlock:^{
        weakSelf.webView.alpha = 1.0;
    } complete:^{
        NSURL *url = [NSURL URLWithString:weakSelf.overlay.contentProvider];
        [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }];
}

- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    __weak AROverlayWebView * weakSelf = self;
    [self animateBounceUnfocusWithParent:parent uncenteredBlock:^{
        weakSelf.webView.alpha = 0.0;
    } complete:nil];
}

@end
