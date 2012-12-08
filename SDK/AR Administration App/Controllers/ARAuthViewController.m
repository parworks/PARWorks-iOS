//
//  ARAuthViewController.m
//  PARWorks iOS
//
//  Created by Ben Gotow on 11/18/12.
//  Copyright (c) 2012 Ben Gotow. All rights reserved.
//

#import "ARAuthViewController.h"
#import "UIViewAdditions.h"
#import "ASIHTTPRequest.h"
#import "ARManager.h"
#import "ASIHTTPRequest+JSONAdditions.h"
#import "ARAppDelegate.h"

@implementation ARAuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_loginButton setEnabled: NO];
    [_registerButton setEnabled: NO];
    [_registerView setAlpha: 0];
    [_registerView setUserInteractionEnabled: NO];
    
    [_loginEmailField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setRegisterEmailField:nil];
    [self setRegisterPasswordField:nil];
    [self setRegisterPasswordConfirmField:nil];
    [self setRegisterView:nil];
    [self setLoginView:nil];
    [self setLoginButton:nil];
    [self setLoginEmailField:nil];
    [self setLoginPasswordField:nil];
    [self setRegisterButton:nil];
    [super viewDidUnload];
}

- (IBAction)createAccount:(id)sender
{
    NSString * msg = nil;
    
    if (![[_registerPasswordConfirmField text] isEqualToString: [_registerPasswordField text]])
        msg = @"Please make sure your passwords match.";
    if ([[_registerEmailField text] rangeOfString:@"@"].location == NSNotFound)
        msg = @"Please provide a valid email address!";
    
    if (msg ){
        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [a show];

    } else {
        [_registerButton setTitle:@"Working..." forState:UIControlStateNormal];
        [_registerButton setEnabled: NO];
        
        // create the full request path
        NSString * scheme = @"https";
        #ifdef DEBUG
        scheme = @"http";
        #endif

        NSURL * url =  [NSURL URLWithString: [NSString stringWithFormat: @"%@://portal.parworksapi.com/ar/mars/user/account/create?email=%@&password=%@", scheme, [_registerEmailField text], [_registerPasswordField text]]];
        ASIHTTPRequest * req = [[ASIHTTPRequest alloc] initWithURL: url];
        ASIHTTPRequest * __weak weak = req;
        
        [req setCompletionBlock: ^(void) {
            [_registerButton setTitle:@"Create Account" forState:UIControlStateNormal];
            [_registerButton setEnabled: YES];

            NSString * msg = nil;
            NSDictionary * json = [weak responseJSON];
            if ([json isKindOfClass: [NSError class]])
                msg = @"The server responded but the response was not valid JSON.";
            
            if ([[json objectForKey: @"success"] boolValue] == YES) {
                ARAppDelegate * d = (ARAppDelegate*)[[UIApplication sharedApplication] delegate];
                [d setAPIKey: [json objectForKey:@"apikey"] andSecret:[json objectForKey:@"secretkey"]];
                [self dismissModalViewControllerAnimated: YES];
            } else {
                msg = [json objectForKey:@"reason"];
            }
            
            if (msg) {
                UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [a show];
            }
        }];
        
        [req setFailedBlock: ^(void) {
            [self requestFailed: weak];
        }];
        [req startAsynchronous];
    }
}
         
- (void)requestFailed:(ASIHTTPRequest *)req
{
    [_registerButton setTitle:@"Create Account" forState:UIControlStateNormal];
    [_registerButton setEnabled: YES];
    [_loginButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [_loginButton setEnabled: YES];

    NSString * msg = [NSString stringWithFormat: @"Sorry, we weren't able to reach the PARWorks API. HTTP Response %d", [req responseStatusCode]];
    UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [a show];
}

- (IBAction)login:(id)sender
{
    [_loginButton setTitle:@"Working..." forState:UIControlStateNormal];
    [_loginButton setEnabled: NO];

    // create the full request path
    NSString * scheme = @"https";
    #ifdef DEBUG
        scheme = @"http";
    #endif

    NSURL * url =  [NSURL URLWithString: [NSString stringWithFormat: @"%@://portal.parworksapi.com/ar/mars/user/account/getkey?email=%@&password=%@", scheme, [_loginEmailField text], [_loginPasswordField text]]];
    ASIHTTPRequest * req = [[ASIHTTPRequest alloc] initWithURL: url];
    ASIHTTPRequest * __weak weak = req;

    [req setCompletionBlock: ^(void) {
        [_loginButton setTitle:@"Sign In" forState:UIControlStateNormal];
        [_loginButton setEnabled: YES];

        NSString * msg = nil;
        NSDictionary * json = [weak responseJSON];
        if ([json isKindOfClass: [NSError class]])
            msg = @"The server responded but the response was not valid JSON.";
        
        if ([[json objectForKey: @"success"] boolValue] == YES) {
            ARAppDelegate * d = (ARAppDelegate*)[[UIApplication sharedApplication] delegate];
            [d setAPIKey: [json objectForKey:@"apikey"] andSecret:[json objectForKey:@"secretkey"]];
            [self dismissModalViewControllerAnimated: YES];
        } else {
            msg = @"Please check your email address and password.";
        }

        if (msg) {
            UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [a show];
        }
    }];
    [req setFailedBlock: ^(void) {
        [self requestFailed: weak];
    }];
    [req startAsynchronous];
}

- (IBAction)switchToRegistration:(id)sender
{
    [_registerView setUserInteractionEnabled: YES];
    [_loginView setUserInteractionEnabled: NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    [_loginView shiftFrame: CGPointMake(0, 15)];
    [_loginView setAlpha: 0];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay: 0.3];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    [_registerView shiftFrame: CGPointMake(0, -15)];
    [_registerView setAlpha: 1];
    [UIView commitAnimations];
    
    [_registerEmailField becomeFirstResponder];
}

- (IBAction)cancelRegistration:(id)sender
{
    [_registerView setUserInteractionEnabled: NO];
    [_loginView setUserInteractionEnabled: YES];
   
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    [_registerView shiftFrame: CGPointMake(0, 15)];
    [_registerView setAlpha: 0];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay: 0.3];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    [_loginView shiftFrame: CGPointMake(0, -15)];
    [_loginView setAlpha: 1];
    [UIView commitAnimations];

    [_loginEmailField becomeFirstResponder];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelectorOnMainThread:@selector(enableButtons) withObject:nil waitUntilDone:NO];
    return YES;
}

- (void)enableButtons
{
    [_loginButton setEnabled: (([[_loginEmailField text] length] > 0) && ([[_loginPasswordField text] length] > 0))];
    [_registerButton setEnabled: (([[_registerPasswordField text] length] > 0) && ([[_registerPasswordConfirmField text] length] > 0) && ([[_registerEmailField text] length] > 0))];
}

@end
