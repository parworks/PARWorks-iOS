//
//  AROverlayURLView.m
//  ViewerDemo
//
//  Created by Demetri Miller on 1/30/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayWebView.h"
#import "AROverlayView+Animations.h"
#import "ARAugmentedView.h"
#import "ARWebViewController.h"

@implementation AROverlayWebView

- (id)initWithOverlay:(AROverlay *)overlay
{
    self = [super initWithOverlay:overlay];
    if (self) {               
        self.animDelegate = self;
    }
    return self;
}


#pragma mark - AROverlayViewAnimationDelegate
- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    if(!_webView){
        self.webView = [[UIWebView alloc] initWithFrame:self.bounds];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_webView];
        _webView.alpha = 0.0;
    }
    
    __weak AROverlayWebView * weakSelf = self;
    [self animateBounceFocusWithParent:parent centeredBlock:^{
        if(self.overlay.contentSize == AROverlayContentSize_Fullscreen){
            ARWebViewController *webViewController = [[ARWebViewController alloc] initWithNibName:@"ARWebViewController" bundle:nil];
            webViewController.sUrl = overlayView.overlay.contentProvider;
            webViewController.sTitle = overlayView.overlay.name;
            [parent presentFullscreenNavigationController:[[UINavigationController alloc] initWithRootViewController:webViewController]];
            weakSelf.webView.alpha = 0.0;
        }
        else
            weakSelf.webView.alpha = 1.0;
    } complete:^{
        [self focusOverlayViewCompleted:weakSelf];
    }];
}

- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    __weak AROverlayWebView * weakSelf = self;
    [self animateBounceUnfocusWithParent:parent uncenteredBlock:^{
        weakSelf.webView.alpha = 0.0;
    } complete:nil];
}

- (void)focusOverlayViewCompleted:(AROverlayWebView*)overlayWebView{
    NSURL *url = [NSURL URLWithString:overlayWebView.overlay.contentProvider];
    [overlayWebView.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
