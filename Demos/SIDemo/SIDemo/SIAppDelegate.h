//
//  SIAppDelegate.h
//  SIDemo
//
//  Created by Demetri Miller on 9/30/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SIViewController;

@interface SIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SIViewController *viewController;

@end
