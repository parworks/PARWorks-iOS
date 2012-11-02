//
//  ARAppDelegate.m
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


#import "ARAppDelegate.h"
#import "ARSitesViewController.h"
#import "ARAugmentedPhotosViewController.h"
#import "ARManager.h"

#define SITES_PATH  [@"~/Documents/Sites.plist" stringByExpandingTildeInPath]


@implementation ARAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup the ARManager
    [[ARManager shared] setApiKey:@"1296e04a-224d-4840-8b31-3ad763fdc383" andSecret: @"28924d84-6b0d-43ce-8e35-20854548fd19"];
    [[ARManager shared] setLocationEnabled: YES];
    
    // load data
    _savesState = YES;
    _sites = [NSKeyedUnarchiver unarchiveObjectWithFile: SITES_PATH];
    if (!_sites)
        _sites = [NSMutableArray array];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Add checks to save state
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:NOTIF_AUGMENTED_PHOTO_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:NOTIF_SITE_UPDATED object:nil];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    // Override point for customization after application launch.
    self.tabController = [[UITabBarController alloc] init];
    
    ARSitesViewController * sites = [[ARSitesViewController alloc] initWithNibName:@"ARSitesViewController" bundle:nil];
    ARAugmentedPhotosViewController * augmented = [[ARAugmentedPhotosViewController alloc] init];
    NSArray * vcs = @[sites, augmented];
    NSMutableArray * ncs = [NSMutableArray array];
    
    for (UIViewController * vc in vcs)
        [ncs addObject: [[UINavigationController alloc] initWithRootViewController: vc]];
    
    self.tabController.viewControllers = ncs;
    
    self.window.rootViewController = self.tabController;
    [self.window makeKeyAndVisible];
    return YES;
}


#pragma mark -
#pragma mark Local Data Storage

- (BOOL)savesState
{
    return _savesState;
}

- (void)setSavesState:(BOOL)s
{
    _savesState = s;
    if (!_savesState) {
        [[NSFileManager defaultManager] removeItemAtPath: SITES_PATH error: nil];
    }
}

- (NSArray*)sites
{
    return _sites;
}

- (void)addSite:(ARSite*)site
{
    [_sites addObject: site];
    [self save];
}

- (void)removeSite:(ARSite *)site
{
    [_sites removeObject:site];
    [self save];
}

- (void)save
{
    if (_savesState && !_saveTriggered)
        [self performSelectorOnMainThread:@selector(saveDeferred) withObject:nil waitUntilDone:NO];
}

- (void)saveDeferred
{
    if (_saveTriggered)
        [NSKeyedArchiver archiveRootObject:_sites toFile: SITES_PATH];
    _saveTriggered = NO;
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
