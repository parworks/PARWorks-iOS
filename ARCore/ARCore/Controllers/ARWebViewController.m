//
//  ARWebViewController.m
//  AR Core
//
//  Created by Grayson Sharpe on 2/1/13.
//  Copyright (c) 2013 Foundry 376, LLC. All rights reserved.
//

#import "ARWebViewController.h"
#import "ARAugmentedView.h"

@interface ARWebViewController ()

@end

@implementation ARWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = _sTitle;
    
    //    if(self.presentedViewController)
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];

    [_loadingView setLoadingViewStyle:ARLoadingViewStyleBlack];
    _loadingView.center = _webView.center;
    
    [_webView setScalesPageToFit:YES];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_sUrl]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_webView stopLoading];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
    [UIView transitionWithView:nil duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        _loadingView.alpha = 1.0;
    } completion:^(BOOL finished){
        [_loadingView startAnimating];
    }];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
    [UIView transitionWithView:nil duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        _loadingView.alpha = 0.0;
    } completion:^(BOOL finished){
        [_loadingView stopAnimating];
    }];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
    [UIView transitionWithView:nil duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        _loadingView.alpha = 0.0;
    } completion:^(BOOL finished){
        [_loadingView stopAnimating];
    }];
}

- (void)updateButtons
{
    _btnForward.enabled = _webView.canGoForward;
    _btnBack.enabled = _webView.canGoBack;
    _btnStop.enabled = _webView.loading;
}

- (void)backButtonPressed{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DISMISS_NAVCONTROLLER_FULLSCREEN object:nil];
    }];
}


@end
