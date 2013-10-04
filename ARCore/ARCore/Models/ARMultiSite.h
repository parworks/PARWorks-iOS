//
//  ARMultiSite.h
//  EasyPAR
//
//  Created by Ben Gotow on 4/11/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARAugmentedPhotoSource.h"

@interface ARMultiSite : NSObject <ARAugmentedPhotoSource>

@property NSString * name;
@property NSArray * siteIdentifiers;

- (id)initWithSiteIdentifiers:(NSArray*)identifiers;
- (ARAugmentedPhoto*)augmentImage:(UIImage *)image withMetadata:(NSDictionary*)metadata;
- (ARAugmentedPhoto*)changeDetectImage:(UIImage*)image;

@end
