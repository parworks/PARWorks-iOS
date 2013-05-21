//
//  AROverlayCreatorViewController.m
//  PAR Works iOS SDK
//
//  Copyright 2013 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "AROverlayCreatorViewController.h"
#import "AROverlayDataEditorViewController.h"
#import "NSBundle+ARCoreResources.h"
#import "UIImage+ARCoreResources.h"


@implementation AROverlayCreatorViewController
{
    BOOL _isFirstLoad;
}

#pragma mark - Lifecycle

- (id)initWithSiteImage:(ARSiteImage*)s
{
    NSString *nibName = NSStringFromClass([AROverlayCreatorViewController class]);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        nibName = [nibName stringByAppendingString:@"_iPhone"];
    } else {
        nibName = [nibName stringByAppendingString:@"_iPad"];
    }

    self = [super initWithNibName:nibName bundle:[NSBundle arCoreResourcesBundle]];
    if (self) {
        _siteImage = s;
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
        [_overlayBuilderView setSiteImage: _siteImage];
        _overlayBuilderView.delegate = self;
        _isFirstLoad = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NOTIF_SITE_UPDATED object: _siteImage.site];
    [self update];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)update
{
    AROverlay * overlay = [[_siteImage overlays] lastObject];

    [_overlayBuilderView setNeedsDisplay];
    
    _saveButton.enabled = (overlay.points.count >= 3) && ([overlay isSaved] == NO);
    _undoButton.enabled = (overlay.points.count >= 1) && ([overlay isSaved] == NO);
    _deleteButton.enabled = (overlay.points.count >= 1) && ([overlay isSaved] == NO);
}


#pragma mark - Convenience

- (void)showOverlayDataEditorAnimated:(BOOL)animated
{
    AROverlayDataEditorViewController *vc = [[AROverlayDataEditorViewController alloc] initWithOverlay:[_overlayBuilderView currentOverlay]];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - ARMagViewDelegate

- (void)didUpdatePointWithOverlay:(AROverlay *)overlay
{
    [self update];
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
    if (frame.origin.y < _overlayBuilderView.frame.size.height) {
        frame.origin.y = _overlayBuilderView.frame.size.height;
        _toggleToolbarButton.image = [UIImage arCoreImageNamed:@"toolbar_show.png"];
    } else {
        frame.origin.y = _overlayBuilderView.frame.size.height - frame.size.height;
        _toggleToolbarButton.image = [UIImage arCoreImageNamed:@"toolbar_hide.png"];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _toolbar.frame = frame;
    } completion:^(BOOL finished) {
        _isAnimating = NO;
    }];
}

- (IBAction)deleteOverlayTapped:(id)sender
{
    AROverlay * overlay = [[_siteImage overlays] lastObject];
    
    if ((overlay.points.count > 0) && (![overlay isSaved])) {
        [_siteImage.site deleteOverlay: overlay];
        [self update];
    }
}

- (IBAction)undoTapped:(id)sender
{
    AROverlay * overlay = [[_siteImage overlays] lastObject];
    
    if ((overlay.points.count > 0) && (![overlay isSaved])) {
        [overlay.points removeLastObject];
        [self update];
    }
}

- (IBAction)doneTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveTapped:(id)sender
{
    [self showOverlayDataEditorAnimated:YES];
}

- (void)viewDidUnload {
    [self setUndoButton:nil];
    [self setDeleteButton:nil];
    [super viewDidUnload];
}
@end
