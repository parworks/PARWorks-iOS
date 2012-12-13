//
//  ViewController.h
//  MagView
//
//  Created by Demetri Miller on 11/27/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARMagView;

@interface AROverlayCreatorViewController : UIViewController
{
    BOOL _isToolbarAnimating;
}

@property(nonatomic, weak) IBOutlet ARMagView *magView;

@property(nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *toggleToolbarButton;

- (IBAction)toggleToolbarTapped:(id)sender;
- (IBAction)deleteOverlaysTapped:(id)sender;
- (IBAction)undoTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;
@end

