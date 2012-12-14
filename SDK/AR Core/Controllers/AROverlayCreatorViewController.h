//
//  ViewController.h
//  MagView
//
//  Created by Demetri Miller on 11/27/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AROverlayBuilderView.h"

@interface AROverlayCreatorViewController : UIViewController <ARMagViewDelegate>
{
    ARSiteImage * _siteImage;
    BOOL    _isAnimating;
}

@property(nonatomic, weak) IBOutlet AROverlayBuilderView * overlayBuilderView;

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
@end

