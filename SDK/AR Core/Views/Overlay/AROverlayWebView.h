//
//  AROverlayURLView.h
//  ViewerDemo
//
//  Created by Demetri Miller on 1/30/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayView.h"
#import "ARLoadingView.h"

@interface AROverlayWebView : AROverlayView <AROverlayViewAnimationDelegate, UIWebViewDelegate>{
    UIWebView *_webView;
    ARLoadingView *_loadingView;
}

@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) ARLoadingView *loadingView;

@end
