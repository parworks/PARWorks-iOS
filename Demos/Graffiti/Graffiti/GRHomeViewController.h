//
//  GRHomeViewController.h
//  Graffiti
//
//  Created by Ben Gotow on 1/8/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GRCameraOverlayView;

@interface GRHomeViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *sitename;

- (IBAction)createGraffiti:(id)sender;
- (IBAction)scanForGraffiti:(id)sender;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
