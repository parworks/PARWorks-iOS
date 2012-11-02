//
//  HNAppDelegate.h
//  HackNash
//
//  Created by Demetri Miller on 10/12/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HNViewController;

typedef void(^GraffitiRetrievalBlock)(UIImage *image);

@interface HNAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) HNViewController *viewController;

- (void)saveGraffiti:(UIImage*)img forSite:(NSString*)sitename;
- (void)getGraffitiForSite:(NSString*)sitename withCompletionBlock:(GraffitiRetrievalBlock)block;

@end
