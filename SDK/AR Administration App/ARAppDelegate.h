//
//  ARAppDelegate.h
//  PAR Works iOS SDK
//
//  Copyright 2013 PAR Works, Inc.
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

#define SITES_PATH  [@"~/Documents/Sites.plist" stringByExpandingTildeInPath]

#define PARWORKS_API_KEY @"1296e04a-224d-4840-8b31-3ad763fdc383"
#define PARWORKS_API_SECRET @"28924d84-6b0d-43ce-8e35-20854548fd19"



@class ARViewController;

@interface ARAppDelegate : UIResponder <UIApplicationDelegate>
{
    NSMutableArray * _sites;
    NSTimer * _refreshTimer;
    BOOL _saveTriggered;
    BOOL _isRefreshing;
}

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) UITabBarController * tabController;

- (void)setAPIKey:(NSString*)key andSecret:(NSString*)secret;
- (void)authenticate;


// ========================
// @name Local Data Storage
// ========================

/**
 @return A list of sites that have been added via the addSite: method.
 */
- (NSArray*)sites;

- (void)loadSavedSites;
- (void)refreshSites;
- (BOOL)refreshingSites;

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
