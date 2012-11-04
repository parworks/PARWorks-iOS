//
//  ARAppDelegate.h
//  PAR Works iOS SDK
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


#import <UIKit/UIKit.h>
#import "ARSite.h"

@class ARViewController;

@interface ARAppDelegate : UIResponder <UIApplicationDelegate>
{
    NSMutableArray * _sites;
    BOOL _savesState;
    BOOL _saveTriggered;
}

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) UITabBarController * tabController;


// ========================
// @name Local Data Storage
// ========================

/**
 @return YES if the app is currently saving state between launches.
 */
- (BOOL)savesState;

/**  Pass YES if you want to save sites and augmented photos between launches of the app.
 */
- (void)setSavesState:(BOOL)s;

/**
 @return A list of sites that have been added via the addSite: method.
 */
- (NSArray*)sites;

/** Adds a site to the known list. Sites are preserved when the application quits,
 so your application may connect to a third party server, fetch available site names,
 and store them for future reference.
 
 @param A site object to be added to the local store.
 */
- (void)addSite:(ARSite*)site;

/** Removes a site from the known list. Sites are preserved when the application quits,
 so your application may connect to a third party server, fetch available site names,
 and store them for future reference.
 
 @param A site object to be removed from the local store.
 */
- (void)removeSite:(ARSite *)site;
@end
