//
//  AROverlayDataEditorViewController.h
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
