//
//  ARSiteImage.h
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


#import <Foundation/Foundation.h>
#import "GridCellView.h"

@class ARSite;

@interface ARSiteImage : NSObject <GridCellViewDataProvider>
{
    NSDictionary * _dict;
}

@property (nonatomic, weak) ARSite * site;
@property (nonatomic, assign) BackendResponse response;

// ========================
// @name Lifecycle
// ========================

/** Creates an ARSiteImage from a dictionary of data returned from the AR server.

 @param dict A dictionary of JSON key-value pairs that was returned from the server.
 @return A newly initialized ARSiteImage instance
*/
- (id)initWithDictionary:(NSDictionary*)dict;

/** Creates an ARSiteImage and sends it to the server in the current site.
 
 @param site A site to add the image to.
 @param img An image captured at the site.
 @return A newly initialized ARSiteImage instance
 */

- (id)initWithSite:(ARSite*)site andImage:(UIImage*)img;


/**
  @return The identifier of the ARSiteImage
*/
- (NSString*)identifier;

/** 
  @return The list of all the overlays that have been made on this site. 
*/
- (NSArray*)overlays;

/** ARSiteImages can be displayed at a variety of sizes. This method returns an URL
  that can be used to load the ARSiteImage at a particular size. Applications should
  cache site images themselves.

  @param size The desired maxmimum dimension of the photo.
  
  @return An NSURL that can be used to request the image of this size.
*/
- (NSURL *)urlForSize:(int)size;


@end
