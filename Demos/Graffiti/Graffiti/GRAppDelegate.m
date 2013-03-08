//
//  GRAppDelegate.m
//  Graffiti
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


#import "GRAppDelegate.h"
#import "GRHomeViewController.h"
#import "ARManager.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "GRViewController.h"

@implementation GRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[ARManager shared] setApiKey:@"1296e04a-224d-4840-8b31-3ad763fdc383" andSecret: @"28924d84-6b0d-43ce-8e35-20854548fd19"];
    [[ARManager shared] setLocationEnabled:YES];
    
    // Override point for customization after application launch.
    self.viewController = [[GRHomeViewController alloc] initWithNibName:@"GRHomeViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)saveGraffiti:(UIImage*)img forOverlay:(AROverlay*)overlay
{
    NSString * identifier = [NSString stringWithFormat: @"%@-%@", overlay.site.identifier, overlay.name];
    ASIFormDataRequest * f = [ASIFormDataRequest requestWithURL: [NSURL URLWithString: @"http://foundry376.com/hdar/site_graffiti.php"]];
    [f addData:UIImagePNGRepresentation(img) withFileName:@"img.png" andContentType:@"image/png" forKey:@"img"];
    [f addPostValue:identifier forKey: @"identifier"];
    [f startAsynchronous];
}

- (void)getGraffitiForOverlay:(AROverlay*)overlay withCompletionBlock:(GraffitiRetrievalBlock)block
{
    NSString * identifier = [[NSString stringWithFormat: @"%@-%@", overlay.site.identifier, overlay.name] stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    ASIHTTPRequest * req = [ASIHTTPRequest requestWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://www.foundry376.com/hdar/site_graffiti.php?identifier=%@", identifier]]];
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
