//
//  ARAugmentedPhoto.h
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



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GridCellView.h"
#import "ARConstants.h"

@class ARAugmentedPhoto;
@class ARSite;

typedef void(^ARProcessingCompletionBlock)(ARAugmentedPhoto *augmentedPhoto);

@interface ARAugmentedPhoto : NSObject <GridCellViewDataProvider, NSCoding>
{
    NSTimer * _pollTimer;
}

@property (nonatomic, weak) ARSite * site;
@property (nonatomic, strong) NSMutableArray * overlays;
@property (nonatomic, strong) NSString * imageIdentifier;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, assign) BackendResponse response;
@property (nonatomic, copy) ARProcessingCompletionBlock processingCompletionBlock;

// ========================
// @name Lifecycle
// ========================

/** Initializes a new ARAugmentedPhoto ready for processing. 

 @warning This method should not be called directly. Use methods in the ARManager
 or ARSite classes to create new ARAugmentedPhotos.
 
 @param i - The UIImage that should be augmented.
 
 @return A newly initialized ARAugmentedPhoto instance
 */

- (id)initWithImage:(UIImage*)i;

/** Initializes a new ARAugmentedPhoto that has already been loaded as an image
 and overlay JSON.
 
 @param img The image, potentially a scaled down version
 
 @param scale The scale of the provided image. 1 means the image was originally processed at this size, 
   0.5 means the image is half the size of the original processed image. JSON points will be adjusted.
 
 @param json Information about overlays and camera perspective.
 
 @return A newly initialized ARAugmentedPhoto instance
 */

- (id)initWithScaledImage:(UIImage*)img atScale:(float)scale andOverlayJSON:(NSDictionary*)json;

/** Initializes a new ARAugmentedPhoto that has already been processed and saved
 to disk elsewhere as two separate files.
  
 @param iPath The path to the image file
  
 @param jsonPath The path to the file containing information about overlays
 and camera perspective written in the json file format.
 
 @return A newly initialized ARAugmentedPhoto instance
 */
 
- (id)initWithImageFile:(NSString*)iPath andOverlayJSONFile:(NSString*)jsonPath;


// ========================
// @name Processing
// ========================

/** Begins the processing procedue by uploading the photo to the server, creating
  a new work task, and setting up a timer to periodically check for results. This method
  returns immediately but the process of augmenting an image is asynchrnous. To listen
  for results, implement an NSNotificationCenter observer for the 
  NOTIF_AUGMENTED_PHOTO_UPDATED notification with the ARAugmentedPhoto instance as the 
  notification object.
*/
- (void)process;

/** Processes the JSON response from the server into overlays. 

 @param data The JSON dictionary that you would like to process to populate the overlays array.

*/

- (void)processJSONData:(NSDictionary*)data;

/** Processes the .pm data received from the server or loaded from a file into overlays.

  @param data The string data that you would like to process to populate the overlays array.

  @warning This format is deprecated.
  
  @warning This function may be called directly if you are loading .pm files from disk, 
  but you should consider using the initWithImageFile:andPMFile: method instead.
*/ 
- (void)processPMData:(NSString*)data;

@end
