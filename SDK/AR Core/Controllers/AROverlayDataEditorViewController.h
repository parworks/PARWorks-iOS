//
//  AROverlayDataEditorViewController.h
//  PARWorks iOS
//
//  Created by Demetri Miller on 12/12/12.
//  Copyright (c) 2012 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AROverlay.h"

@interface AROverlayDataEditorViewController : UIViewController
{
    __strong AROverlay *_overlay;
}

@property(nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *metadataLabel;
@property(nonatomic, weak) IBOutlet UITextField *nameField;
@property(nonatomic, weak) IBOutlet UITextView *metadataTextView;

/// Lifecycle
- (id)initWithOverlay:(AROverlay *)overlay;

/// User Interaction
- (IBAction)doneTapped:(id)sender;
@end
