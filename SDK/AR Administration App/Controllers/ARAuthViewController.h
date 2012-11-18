//
//  ARAuthViewController.h
//  PARWorks iOS
//
//  Created by Ben Gotow on 11/18/12.
//  Copyright (c) 2012 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARAuthViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UITextField *loginEmailField;
@property (weak, nonatomic) IBOutlet UITextField *loginPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UITextField *registerEmailField;
@property (weak, nonatomic) IBOutlet UITextField *registerPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *registerPasswordConfirmField;

- (IBAction)createAccount:(id)sender;
- (IBAction)login:(id)sender;

- (IBAction)switchToRegistration:(id)sender;
- (IBAction)cancelRegistration:(id)sender;

@end
