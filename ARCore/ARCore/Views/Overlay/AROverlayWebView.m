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
#import "NSBundle+ARCoreResources.h"

@implementation AROverlayWebView

- (id)initWithOverlay:(AROverlay *)overlay
{
    self = [super initWithOverlay:overlay];
    if (self) {
        self.animDelegate = self;
    }
    return self;
}


#pragma mark - Accessors
- (UIWebView *)webView
{
    if(!_webView){
        _webView = [[UIWebView alloc] initWithFrame:self.bounds];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _webView.opaque = NO;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.scrollEnabled = YES;
        _webView.scrollView.bounces = YES;
        _webView.delegate = self;
        [self addSubview:_webView];
    }
    return _webView;
}

- (UIButton *)closeButton
{
    if(!_closeButton){
        //For GM Demo, I changed closeButton from X to full screen invisible button
        self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 45.0, 5.0, 40.0, 40.0)];
        //        self.closeButton = [[UIButton alloc] initWithFrame:self.bounds];
        [_closeButton setBackgroundColor:[UIColor clearColor]];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"Button_Close-Overlay.png"] forState:UIControlStateNormal];
        [self addSubview:_closeButton];
    }
    return _closeButton;
}

- (ARLoadingView *)loadingView
{
    if(!_loadingView){
        self.loadingView = [[ARLoadingView alloc] initWithFrame: CGRectMake(0, 0, 36, 36)];
        [_loadingView setBackgroundColor: [UIColor clearColor]];
        _loadingView.center = _webView.center;
        [_loadingView setLoadingViewStyle:ARLoadingViewStyleWhite];
        [self addSubview:_loadingView];
    }
    return _loadingView;
}


#pragma mark - AROverlayViewAnimationDelegate
- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    // Property accessor triggers lazy loading
    self.webView.alpha = 0;
    self.loadingView.alpha = 0;
    self.closeButton.alpha = 0.0;
    [_closeButton addTarget:parent action:@selector(overlayTapped:) forControlEvents:UIControlEventTouchUpInside];

    __weak AROverlayWebView * weakSelf = self;
    [self animateBounceFocusWithParent:parent centeredBlock:^{
        if(overlayView.overlay.contentSize == AROverlayContentSize_Fullscreen){
            ARWebViewController *webViewController = [[ARWebViewController alloc] initWithNibName:@"ARWebViewController" bundle:[NSBundle arCoreResourcesBundle]];
            webViewController.sUrl = overlayView.overlay.contentProvider;
            webViewController.sTitle = overlayView.overlay.name;
            [parent presentFullscreenNavigationController:[[UINavigationController alloc] initWithRootViewController:webViewController]];
            weakSelf.webView.alpha = 0.0;
        }
        else{
            weakSelf.webView.alpha = 1.0;
        }
    } complete:^{
        [self focusOverlayViewCompleted:weakSelf];        
    }];
}

- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    __weak AROverlayWebView * weakSelf = self;

    [_closeButton removeTarget:parent action:@selector(overlayTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self animateBounceUnfocusWithParent:parent uncenteredBlock:^{
        weakSelf.webView.alpha = 0.0;
        weakSelf.loadingView.alpha = 0.0;
        weakSelf.closeButton.alpha = 0.0;
        [weakSelf.loadingView stopAnimating];
        [self.layer setBorderColor: [[UIColor clearColor] CGColor]];
    } complete:nil];
}

- (void)focusOverlayViewCompleted:(AROverlayWebView*)overlayWebView{
    NSURL *url = [NSURL URLWithString:overlayWebView.overlay.contentProvider];
    if (![overlayWebView.webView request]){
        [overlayWebView.webView setScalesPageToFit:YES];
        [overlayWebView.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    [UIView transitionWithView:nil duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        if(![overlayWebView.webView isLoading])
            _closeButton.alpha = 1.0;
    } completion:nil];
}


#pragma mark - UIWebViewDelegate
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
        _closeButton.alpha = 1.0;
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
