//
//  DMViewController.m
//  Graffiti
//
//  Created by Demetri Miller on 10/12/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "DMViewController.h"
#import "HNGraffitiView.h"
#import "HNSprayCanLoadingView.h"
#import "HNSprayView.h"

@interface DMViewController ()

@end

@implementation DMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _iv = [[HNGraffitiView alloc] initWithFrame:CGRectInset(self.view.bounds, 20, 20) image:[UIImage imageNamed:@"img.png"]];
    [self.view addSubview:_iv];
    _iv.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);

    _loadingView = [[HNSprayCanLoadingView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_loadingView];
    
    [self.view bringSubviewToFront:_btn];
    [self.view bringSubviewToFront:_loadButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reveal:(id)sender
{
    [_iv reveal];
}

BOOL on = YES;
- (IBAction)showLoadingView:(id)sender
{
    if (on) {
        [_loadingView startAnimation];
    } else {
        [_loadingView stopAnimation];
    }
    on = !on;
}
@end
