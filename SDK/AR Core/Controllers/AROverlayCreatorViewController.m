//
//  ViewController.m
//  MagView
//
//  Created by Demetri Miller on 11/27/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "AROverlayCreatorViewController.h"
#import "AROverlayDataEditorViewController.h"

@interface AROverlayCreatorViewController ()

@end

@implementation AROverlayCreatorViewController
{
    BOOL _isFirstLoad;
}

#pragma mark - Lifecycle
- (id)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:@"AROverlayCreatorViewController" bundle:nil];
    if (self) {
        _image = image;
    }
    return self;
}

- (id)initWithImagePath:(NSString *)path
{
    self = [super initWithNibName:@"AROverlayCreatorViewController" bundle:nil];
    if (self) {
        _imagePath = [path copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isAnimating = NO;
    _isFirstLoad = YES;    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isFirstLoad) {
        if (_imagePath != nil) {
            [_magView.imageView setImagePath:_imagePath];
        } else if (_image != nil) {
            [_magView setImage:_image];
        }
        
        _magView.delegate = self;
        _isFirstLoad = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Convenience
- (void)showOverlayDataEditorAnimated:(BOOL)animated
{
    AROverlayDataEditorViewController *vc = [[AROverlayDataEditorViewController alloc] initWithOverlay:[_magView currentOverlay]];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - ARMagViewDelegate
- (void)didUpdatePointWithOverlay:(AROverlay *)overlay
{
    _saveButton.enabled = (overlay.points.count >= 3);
}

#pragma mark - User Interaction
- (IBAction)toggleToolbarTapped:(id)sender
{
    if (_isAnimating) {
        return;
    } else {
        _isAnimating = YES;
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
        _isAnimating = NO;
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveTapped:(id)sender
{
    [self showOverlayDataEditorAnimated:YES];
}

@end
