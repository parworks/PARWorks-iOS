//
//  AROverlayURLView.h
//  ViewerDemo
//
//  Created by Demetri Miller on 1/30/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayView.h"
#import "ARLoadingView.h"

typedef void (^VoidBlock)();

@interface AROverlayWebView : AROverlayView <AROverlayViewAnimationDelegate, UIWebViewDelegate>{
    UIWebView *_webView;
    ARLoadingView *_loadingView;
    UIButton *_closeButton;
}

@property(nonatomic, assign) Class focusControllerClass;
@property(nonatomic, strong) VoidBlock focusWebLoadCompleteBlock;

@property(nonatomic, strong) UIWebView * webView;
@property(nonatomic, strong) ARLoadingView *loadingView;
@property(nonatomic, strong) UIButton *closeButton;

- (void)focusOverlayViewCompleted:(AROverlayWebView*)overlayWebView;

@end
