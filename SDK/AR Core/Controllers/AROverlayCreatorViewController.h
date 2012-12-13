//
//  ViewController.h
//  MagView
//
//  Created by Demetri Miller on 11/27/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARMagView.h"

@interface AROverlayCreatorViewController : UIViewController <ARMagViewDelegate>
{
    UIImage *_image;
    NSString *_imagePath;
    BOOL    _isAnimating;
}

@property(nonatomic, weak) IBOutlet ARMagView *magView;

@property(nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *toggleToolbarButton;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *saveButton;

/// Lifecycle
- (id)initWithImage:(UIImage *)image;
- (id)initWithImagePath:(NSString *)path;


/// User Interaction
- (IBAction)toggleToolbarTapped:(id)sender;
- (IBAction)deleteOverlaysTapped:(id)sender;
- (IBAction)undoTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
@end

