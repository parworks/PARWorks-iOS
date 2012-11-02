//
//  HNAppDelegate.m
//  HackNash
//
//  Created by Demetri Miller on 10/12/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "HNAppDelegate.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "HNViewController.h"

@implementation HNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [[ARManager shared] setAppID: @"hacknash"];
    [[ARManager shared] setLocationEnabled:YES];
    
    // Override point for customization after application launch.
    self.viewController = [[HNViewController alloc] initWithNibName:@"HNViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)saveGraffiti:(UIImage*)img forSite:(NSString*)sitename
{
    ASIFormDataRequest * f = [ASIFormDataRequest requestWithURL: [NSURL URLWithString: @"http://foundry376.com/hdar/site_graffiti.php"]];
    [f addData:UIImagePNGRepresentation(img) withFileName:@"img.png" andContentType:@"image/png" forKey:@"img"];
    [f addPostValue:sitename forKey:@"site"];
    [f startAsynchronous];
}

- (void)getGraffitiForSite:(NSString*)sitename withCompletionBlock:(GraffitiRetrievalBlock)block
{
    ASIHTTPRequest * req = [ASIHTTPRequest requestWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://www.foundry376.com/hdar/site_graffiti.php?site=%@", sitename]]];
    ASIHTTPRequest * __weak weak = req;
    
    [req setCompletionBlock: ^(void) {
        if (block) {
            UIImage * i = [UIImage imageWithData: [weak responseData]];
            block(i);
        }
    }];
    
    [req setFailedBlock:^{
        if (block) {
            UIImage * i = [UIImage imageWithData: [weak responseData]];
            block(i);
        }
    }];
    [req startAsynchronous];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
