//
//  ARMultisiteAugmentedPhotoNoPolling.h
//  ARCore
//
//  Created by Adam Hickey on 8/8/13.
//  Copyright (c) 2013 PARWorks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARAugmentedPhoto.h"

@interface ARMultisiteAugmentedPhotoNoPolling : ARAugmentedPhoto
{
    NSMutableDictionary * _sites;
    NSMutableArray * _pendingPhotos;
}

@property (nonatomic, retain) NSArray * siteIdentifiers;
@property (nonatomic, retain) NSArray * sitesToCheck;
@property (nonatomic, retain) NSString * imgId;

- (id)initWithImage:(UIImage*)i andSiteIdentifiers:(NSArray*)identifiers;

@end
