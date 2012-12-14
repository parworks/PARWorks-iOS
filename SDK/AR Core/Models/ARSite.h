//
//  ARSite.h
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
#import "ARAugmentedPhoto.h"
#import "AROverlay.h"

typedef enum ARSiteStatus {
    ARSiteStatusUnknown = -1,
    ARSiteStatusNotProcessed = 0,
    ARSiteStatusProcessing = 1,
    ARSiteStatusProcessingFailed = 2,
    ARSiteStatusProcessed = 3,
    ARSiteStatusCreating = 4
} ARSiteStatus;
    
@interface ARSite : NSObject <NSCoding>
{
    ASIHTTPRequest * _imageReq;
    ASIHTTPRequest * _overlaysReq;
}

@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSMutableArray * images;
@property (nonatomic, strong) NSMutableArray * augmentedPhotos;
@property (nonatomic, strong) NSMutableArray * overlays;
@property (nonatomic, assign) ARSiteStatus status;
@property (nonatomic, assign) BOOL invalid;
@property (nonatomic, readonly) int summaryImageCount;
@property (nonatomic, readonly) int summaryOverlayCount;


// ========================
// @name Lifecycle
// ========================

/** Creates a new site using the given site identifier

 @param ident - The identifier of the site — should already exist on the server.

 @return A newly initialized ARSite instance
 */
- (id)initWithIdentifier:(NSString*)ident;

/** Creates a new site using a summary entry returned by the REQ_SITE_LIST_ALL endpoint
 
 @param dict - The summary entry used to create the site object
 
 @return A newly initialized ARSite instance
 */
- (id)initWithSummaryDictionary:(NSDictionary *)dict;

// ========================
// @name Site Information
// ========================

/** Queries for the status of the site asynchronously. */
- (void)checkStatus;


/** Returns a human-readable description of the site. Currently this returns the
  number of images in the site.

 @return Human-readable information about this site.
 */
- (NSString*)description;

/** Returns an array of the template images of this site. Generally there are 25
  to 30 images. If the images have not yet been fetched from the server, this method
  begins fetching the images and returns nil. When the images have been downloaded,
  the ARSite object will send a NOTIF_SITE_UPDATED message, allowing the client to 
  reload any view that is dependent on this data.

 @return NSArray of ARSiteImage objects, or nil if the images have not been loaded.
 */
- (NSMutableArray*)images;

/** Used to add a brand new image to the base images for the site. Will be submitted
to the server and added to the base images collection.

  @param img The image to add to the base images set. Will be synced to the server 
  asynchronously.

*/
- (void)addImage:(UIImage*)img;

/** Begins the process of processing base images added to the site. Listen for 
NOTIF_SITE_UPDATED to receive notifications when the site is ready. 
*/
- (void)processBaseImages;

/** Destroys the local copy of the site's base images and fetches them from the 
server again.
*/
- (void)invalidateImages;

/**
  @return true if the ARSite is still fetching it's images from the server.
*/
- (BOOL)isFetchingImages;

/** Returns an array of the overlays available at this site. If the overlays have
  not been loaded, this function initiates a request for the overlays. When overlays
  are downloaded, a NOTIF_SITE_UPDATES notification will be sent, allowing the client
  to reload any view that depends on this data.

  @return NSArray of AROverlay objects, or nil if overlays have not been loaded.
*/
- (NSArray*)overlays;

/**
  Adds an overlay to the overlays array cached locally. Does not save the overlay
  to the server. You must call [overlay save].

  @param ar The overlay to add to the site.
*/
- (void)addOverlay:(AROverlay*)ar;

/** 
  Deletes an overlay from the overlays array and also triggers an API call to delete the 
  overlay if it has been saved on the server.
 
 @param ar The overlay to remove from the site.
*/
- (void)deleteOverlay:(AROverlay*)ar;


// ========================
// @name Augmenting Images
// ========================

/** This method uploads the provided image to the server for processing. During 
  processing, only this ARSite will be scanned for appropriate overlays. This method
  returns an ARAugmentedPhoto immediately, an an NOTIF_AUGMENTED_PHOTO_UPDATED notification
  will be sent with the ARAugmentedPhoto as the notification object when the 
  results of augmentation have been received.

 @param image The image to be augmented.

 @return An ARAugmentedPhoto object that represents the augmented image.
*/
- (ARAugmentedPhoto*)augmentImage:(UIImage*)image;

/** Removes all the augmented photos stored with this site.
*/
- (void)removeAllAugmentedPhotos;



@end
