//
//  AROverlayURLView.h
//  ViewerDemo
//
//  Created by Demetri Miller on 1/30/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayView.h"

@interface AROverlayWebView : AROverlayView <AROverlayViewAnimationDelegate>

@property(nonatomic, strong) UIWebView *webView;

@end
