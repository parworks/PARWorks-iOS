//
//  AROverlay.h
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
#import "ARSiteImage.h"

@class ARSite;

typedef enum {
    AROverlayBoundaryType_Hidden = 0,
    AROverlayBoundaryType_Dashed,
    AROverlayBoundaryType_Solid
} AROverlayBoundaryType;

typedef enum {
    AROverlayContentType_URL = 0,
    AROverlayContentType_Video,
    AROverlayContentType_Image,
    AROverlayContentType_Audio,
    AROverlayContentType_Text
} AROverlayContentType;

typedef enum {
    AROverlayContentSize_Small = 0,
    AROverlayContentSize_Medium,
    AROverlayContentSize_Large,
    AROverlayContentSize_Large_Left,
    AROverlayContentSize_Fullscreen_No_Modal,
    AROverlayContentSize_Fullscreen
} AROverlayContentSize;

typedef enum {
    AROverlayCoverType_Hidden = 0,
    AROverlayCoverType_Image,
    AROverlayCoverType_Centroid,
    AROverlayCoverType_Regular
} AROverlayCoverType;

@interface AROverlay : NSObject <NSCoding>
{
}

@property (nonatomic, strong) NSString * ID;
@property (nonatomic, strong) NSString * siteImageIdentifier;
@property (nonatomic, strong) NSString * nonsiteImageURL;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSMutableArray * points;

@property (nonatomic, strong) NSString * accuracy;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) BOOL processed;

@property (nonatomic, assign) AROverlayBoundaryType boundaryType;
@property (nonatomic, strong) UIColor               * boundaryColor;

@property (nonatomic, assign) AROverlayContentType  contentType;
@property (nonatomic, assign) AROverlayContentSize  contentSize;
@property (nonatomic, strong) NSString              * contentProvider;

@property (nonatomic, assign) AROverlayCoverType coverType;
@property (nonatomic, assign) NSInteger          coverTransparency;
@property (nonatomic, assign) CGSize             centroidOffset;
@property (nonatomic, assign) BOOL               centroidPulse;
@property (nonatomic, assign) BOOL               showTitle;
@property (nonatomic, strong) UIColor            * coverColor;
@property (nonatomic, strong) NSString           * coverProvider;

@property (nonatomic, weak) ARSite * site;

// ========================
// @name Lifecycle
// ========================

- (id)initWithSiteImage:(ARSiteImage *)s;

/** Creates a new AROverlay object using JSON data provided by the server.

 @param dict - A dictionary of key-value pairs provided by the server.
 @return A newly initialized AROverlay instance
 */
- (id)initWithDictionary:(NSDictionary*)dict;

/** Creates a new AROverlay object using change detection JSON data provided by the server.
 
 @param dict - An 'instance' dictionary containing the values provided from the change detection endpoint. 
 @return A newly initialized AROverlay instance
 */
- (id)initWithChangeDetectionDictionary:(NSDictionary*)instanceDictionary overlayId: (NSString*)id objectLabel: (NSString*) label;

/** Initializes the points array using the vertex data in the object's _dict.
*/
- (void)setupPointsFromDictionary:(NSDictionary*)dict;

/** Updates the overlay with the contents in the dictionary */
- (void)updatePropertiesWithDictionary:(NSDictionary *)dict;

- (NSMutableDictionary *)jsonRepresentation;

- (void)save;

- (void)save:(BOOL)toStagingOverlays;

- (BOOL)isSaved;

- (BOOL)isEqual:(id)object;

#pragma mark Adding Points to the Overlay

- (void)addPointWithX:(float)x andY:(float)y;

- (void)removeLastPoint;

@end
