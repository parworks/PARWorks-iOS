//
//  ViewController.m
//  ViewerDemo
//
//  Created by Demetri Miller on 1/26/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//


#import "ViewController.h"
#import "AROverlayViewFactory.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ARAugmentedView *augView = [[ARAugmentedView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    augView.delegate = self;
    augView.showOutlineViewsOnly = YES;
    augView.shouldAnimateOutlineViewDrawing = NO;
    
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *imagePath = [NSBundle pathForResource:@"overlay_spec_example_1" ofType:@"jpg" inDirectory:bundlePath];
    NSString *pmPath = [NSBundle pathForResource:@"overlay_spec_example_1" ofType:@"pm" inDirectory:bundlePath];
    ARAugmentedPhoto *augPhoto = [[ARAugmentedPhoto alloc] initWithImageFile:imagePath andPMFile:pmPath];
    augView.augmentedPhoto = augPhoto;
    [self.view addSubview:augView];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
