//
//  UIModalSaveView.m
//  PARWorks iOS SDK
//
//  Copyright 2012 PAR Works, Inc.
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


#import "UIAlertInputView.h"


@implementation UIAlertInputView

@synthesize field;
@synthesize inputDelegate;

- (id)initWithDelegate:(id)delegate andTitle:(NSString*)title andDefaultValue:(NSString*)defaultValue
{
    if (self = [super initWithTitle:title message:@"/r/r" delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",nil]){
        CGRect frame = CGRectMake(12,45,260,26);
        
        field = [[UITextField alloc] initWithFrame: frame];
        [field setBackgroundColor:[UIColor whiteColor]];
        [field setAutocapitalizationType: UITextAutocapitalizationTypeNone];
        [field setAutocorrectionType: UITextAutocorrectionTypeNo];
        [field setBorderStyle: UITextBorderStyleBezel];
        [field setKeyboardAppearance: UIKeyboardAppearanceAlert];
        [field setFont: [UIFont systemFontOfSize:18]];
        [field setText: defaultValue];
        [field setClearsOnBeginEditing: NO];
        [field setDelegate: self];
        [self addSubview: field];
        [field becomeFirstResponder];
        
        self.inputDelegate = delegate;
        self.cancelButtonIndex = 0;
    }
    return self;
}


- (NSString*)textValue
{
    return [field text];
}

-(void)alertView:(UIAlertInputView*)view clickedButtonAtIndex:(int)buttonIndex
{
    [inputDelegate alertInputView:view clickedButtonAtIndex:buttonIndex];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect  r = [self frame];
    
    r.origin.y -= r.size.height /2;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.5];
    [UIView setAnimationsEnabled: YES];
    [self setFrame: r];
    [UIView commitAnimations];
    
    [field setClearsOnBeginEditing: NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect  r = [self frame];
    
    r.origin.y += r.size.height /2;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.5];
    [UIView setAnimationsEnabled: YES];
    [self setFrame: r];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [inputDelegate alertInputView:self clickedButtonAtIndex:1];
    [self dismissWithClickedButtonIndex:1 animated: YES];
    return YES;
}

@end
