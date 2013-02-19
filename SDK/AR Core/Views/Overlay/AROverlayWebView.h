//
//  AROverlayURLView.h
//  ViewerDemo
//
//  Created by Demetri Miller on 1/30/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayView.h"
#import "PVLoadingView.h"

@interface AROverlayWebView : AROverlayView <AROverlayViewAnimationDelegate, UIWebViewDelegate>{
    UIWebView *_webView;
    PVLoadingView *_loadingView;
}

@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) PVLoadingView *loadingView;

@end
