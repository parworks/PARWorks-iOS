//
//  ARSiteCollection.h
//  EasyPAR
//
//  Created by Ben Gotow on 4/11/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARAugmentedPhoto.h"

@interface ARMultisiteAugmentedPhoto : ARAugmentedPhoto
{
    NSMutableDictionary * _sites;
    NSMutableArray * _pendingPhotos;
}

@property (nonatomic, retain) NSArray * siteIdentifiers;

- (id)initWithImage:(UIImage*)i andSiteIdentifiers:(NSArray*)identifiers;

@end
