//
//  ARWebViewController.h
//  AR Core
//
//  Created by Grayson Sharpe on 2/1/13.
//  Copyright (c) 2013 Foundry 376, LLC. All rights reserved.
//

#import "PVLoadingView.h"

@interface ARWebViewController : UIViewController

@property (nonatomic, strong) NSString *sTitle;
@property (nonatomic, strong) NSString *sUrl;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnBack;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnForward;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnRefresh;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *btnStop;
@property (nonatomic, strong) PVLoadingView *loadingView;

@end
