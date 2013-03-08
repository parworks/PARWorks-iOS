//
//  GRHomeViewController.m
//  Graffiti
//
//  Created by Ben Gotow on 1/8/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "GRAppDelegate.h"
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

    NSString * name = [[NSUserDefaults standardUserDefaults] objectForKey: SITENAME_KEY];
    if (!name)
        name = @"Dollar1";
    
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:SITENAME_KEY];
    [_sitename setText: name];
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
    [[NSUserDefaults standardUserDefaults] setObject:[_sitename text] forKey:SITENAME_KEY];
    GRViewController * scanner = [[GRViewController alloc] init];
    [self presentViewController:scanner animated:YES completion:NULL];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[NSUserDefaults standardUserDefaults] setObject:[textField text] forKey:SITENAME_KEY];
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
