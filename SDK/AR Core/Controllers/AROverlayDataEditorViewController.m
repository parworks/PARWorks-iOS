//
//  AROverlayDataEditorViewController.m
//  PARWorks iOS
//
//  Created by Demetri Miller on 12/12/12.
//  Copyright (c) 2012 Ben Gotow. All rights reserved.
//

#import "AROverlayDataEditorViewController.h"

@interface AROverlayDataEditorViewController ()

@end

@implementation AROverlayDataEditorViewController

- (id)initWithOverlay:(AROverlay *)overlay
{
    self = [super initWithNibName:@"AROverlayDataEditorViewController" bundle:nil];
    if (self) {
        _overlay = overlay;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _metadataTextView.layer.borderColor = [UIColor blackColor].CGColor;
    _metadataTextView.layer.borderWidth = 1.0;
    [_nameField becomeFirstResponder];
    
    _nameField.text = _overlay.ID;
    _metadataTextView.text = _overlay.content;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)doneTapped:(id)sender
{
    _overlay.ID = _nameField.text;
    _overlay.content = _metadataTextView.text;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
