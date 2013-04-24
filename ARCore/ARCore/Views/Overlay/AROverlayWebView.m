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
        _webView.delegate = self;
        [self addSubview:_webView];
        _webView.alpha = 0.0;
    }
    
    if(!_loadingView){
        self.loadingView = [[ARLoadingView alloc] initWithFrame: CGRectMake(0, 0, 36, 36)];
        _loadingView.center = _webView.center;
        [_loadingView setLoadingViewStyle:ARLoadingViewStyleBlack];
        [self addSubview:_loadingView];
        _loadingView.alpha = 0.0;
    }
    
    __weak AROverlayWebView * weakSelf = self;
    [self animateBounceFocusWithParent:parent centeredBlock:^{
        if(overlayView.overlay.contentSize == AROverlayContentSize_Fullscreen){
            ARWebViewController *webViewController = [[ARWebViewController alloc] initWithNibName:@"ARCore.bundle/ARWebViewController" bundle:nil];
            webViewController.sUrl = overlayView.overlay.contentProvider;
            webViewController.sTitle = overlayView.overlay.name;
            [parent presentFullscreenNavigationController:[[UINavigationController alloc] initWithRootViewController:webViewController]];
            weakSelf.webView.alpha = 0.0;
        }
        else{
            weakSelf.webView.alpha = 1.0;
            [self.layer setBorderColor: [[UIColor colorWithWhite:0.25 alpha:1] CGColor]];
            [self.layer setBorderWidth: 3];
        }
    } complete:^{
        [self focusOverlayViewCompleted:weakSelf];
    }];
}

- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    __weak AROverlayWebView * weakSelf = self;
    [self animateBounceUnfocusWithParent:parent uncenteredBlock:^{
        weakSelf.webView.alpha = 0.0;
        weakSelf.loadingView.alpha = 0.0;
        [weakSelf.loadingView stopAnimating];
        [self.layer setBorderColor: [[UIColor clearColor] CGColor]];
    } complete:nil];
}

- (void)focusOverlayViewCompleted:(AROverlayWebView*)overlayWebView{
    NSURL *url = [NSURL URLWithString:overlayWebView.overlay.contentProvider];
    if (![overlayWebView.webView request])
        [overlayWebView.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [_loadingView startAnimating];
    [UIView transitionWithView:nil duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        _loadingView.alpha = 1.0;
    } completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [UIView transitionWithView:nil duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        _loadingView.alpha = 0.0;    
    } completion:^(BOOL finished){
        [_loadingView stopAnimating];
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [UIView transitionWithView:nil duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        _loadingView.alpha = 0.0;
    } completion:^(BOOL finished){
        [_loadingView stopAnimating];
    }];
}

@end
