//
//  ViewController.m
//  MagView
//
//  Created by Demetri Miller on 11/27/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "ARMagView.h"
#import "AROverlayCreatorViewController.h"

@interface AROverlayCreatorViewController ()

@end

@implementation AROverlayCreatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isToolbarAnimating = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [_magView setImage:[UIImage imageNamed:@"picture.JPG"]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - User Interaction
- (IBAction)toggleToolbarTapped:(id)sender
{
    if (_isToolbarAnimating) {
        return;
    } else {
        _isToolbarAnimating = YES;
    }
    
    CGRect frame = _toolbar.frame;
    if (frame.origin.y < self.view.frame.size.height) {
        frame.origin.y = self.view.frame.size.height;
        _toggleToolbarButton.title = @"Show";
    } else {
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        _toggleToolbarButton.title = @"Hide";
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _toolbar.frame = frame;
    } completion:^(BOOL finished) {
        _isToolbarAnimating = NO;
    }];
}

- (IBAction)deleteOverlaysTapped:(id)sender
{
    [_magView.pointOverlay clearPoints];
    [_magView setNeedsDisplay];
}

- (IBAction)undoTapped:(id)sender
{
    [_magView.pointOverlay removeLastPoint];
    [_magView setNeedsDisplay];
}

- (IBAction)doneTapped:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
