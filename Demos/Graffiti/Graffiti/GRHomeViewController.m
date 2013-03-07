//
//  GRHomeViewController.m
//  Graffiti
//
//  Created by Ben Gotow on 1/8/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "GRCameraOverlayView.h"
#import "GRHomeViewController.h"
#import "GRViewController.h"
#import "UIView+ImageCapture.h"
#import "UIViewController+Transitions.h"

@implementation GRHomeViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createGraffiti:(id)sender
{
}

- (IBAction)scanForGraffiti:(id)sender
{
    GRViewController * scanner = [[GRViewController alloc] init];
    [self presentViewController:scanner animated:YES completion:NULL];
}

@end
