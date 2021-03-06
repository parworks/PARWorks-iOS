//
//  ARMultiSite.m
//  EasyPAR
//
//  Created by Ben Gotow on 4/11/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "ARMultiSite.h"
#import "ARMultisiteAugmentedPhotoNoPolling.h"
#import "ARMultisiteAugmentedPhoto.h"

@implementation ARMultiSite

- (id)initWithSiteIdentifiers:(NSArray*)identifiers
{
    self = [super init];
    if (self) {
        self.siteIdentifiers = identifiers;
    }
    return self;
}

- (ARAugmentedPhoto*)augmentImage:(UIImage *)image withMetadata:(NSDictionary*)metadata
{
    NSLog(@"MULTISITE AUGMENTATION");
    ARMultisiteAugmentedPhotoNoPolling * a = [[ARMultisiteAugmentedPhotoNoPolling alloc] initWithImage:image andSiteIdentifiers:self.siteIdentifiers];
    [a setImageMetadata:metadata];
    [a process];
    return a;
}
- (ARAugmentedPhoto*)changeDetectImage:(UIImage*)image
{
    NSLog(@"Change detection doesn't work on multisites yet!");
    return nil;
}
@end
