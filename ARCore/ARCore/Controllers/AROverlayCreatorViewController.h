//
//  AROverlayCreatorViewController.h
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
#import "AROverlayBuilderView.h"

@interface AROverlayCreatorViewController : UIViewController <ARMagViewDelegate>
{
    BOOL    _isAnimating;
}

@property(nonatomic, weak) IBOutlet AROverlayBuilderView * overlayBuilderView;

@property(nonatomic, retain) ARSiteImage * siteImage;
@property(nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property(nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *toggleToolbarButton;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *saveButton;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *undoButton;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *deleteButton;

/// Lifecycle
- (id)initWithSiteImage:(ARSiteImage*)s;


/// User Interaction
- (IBAction)toggleToolbarTapped:(id)sender;
- (IBAction)deleteOverlayTapped:(id)sender;
- (IBAction)undoTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;

- (void)update;

@end

