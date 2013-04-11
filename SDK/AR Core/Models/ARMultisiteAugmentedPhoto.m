//
//  ARSiteCollection.m
//  EasyPAR
//
//  Created by Ben Gotow on 4/11/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "ARMultisiteAugmentedPhoto.h"
#import "ASIHTTPRequest+JSONAdditions.h"

@implementation ARMultisiteAugmentedPhoto

- (id)initWithImage:(UIImage*)i andSiteIdentifiers:(NSArray*)identifiers
{
    self = [super initWithImage: i];
    if (self) {
        self.siteIdentifiers = identifiers;
    }
    return self;
}

- (ASIFormDataRequest*)requestForProcessing
{
    NSString * url = [REQ_IMAGE_AUGMENT_MULTI stringByAppendingString: [_siteIdentifiers componentsJoinedByString: @"&site="]];
    return (ASIFormDataRequest*)[[ARManager shared] createRequest:url withMethod:@"POST" withArguments: [NSMutableDictionary dictionary]];
}

- (void)processPostComplete:(ASIFormDataRequest*)req
{
//    {
//        "success" : true,
//        "candidates" : [
//                        { "site" : "siteId1", "imgId" : "imageId1" },
//                        { "site" : "siteId2", "imgId" : "imageId2" },
//                        { "site" : "siteId3", "imgId" : "imageId3" },
//                        ....
//                        ]
//    }

    NSDictionary * json = [req responseJSON];
    _pendingPhotos = [[NSMutableArray alloc] init];
    _sites = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary * candidate in [json objectForKey: @"candidates"]) {
        ARAugmentedPhoto * p = [[ARAugmentedPhoto alloc] init];
        ARSite * s = [[ARSite alloc] initWithIdentifier: [candidate objectForKey: @"site"]];
        [_sites setObject: s forKey: [candidate objectForKey: @"site"]];

        [p setSite: s];
        [p startPollForImageIdentifier: [candidate objectForKey: @"imgId"]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoUpdated:) name:NOTIF_AUGMENTED_PHOTO_UPDATED object:p];
        [_pendingPhotos addObject: p];
    }
}

- (void)photoUpdated:(NSNotification*)notif
{
    ARAugmentedPhoto * photo = [notif object];
    if ([photo response] == BackendResponseFinished) {
        [[self overlays] addObjectsFromArray: [photo overlays]];
        [_pendingPhotos removeObject: photo];

        if ([_pendingPhotos count] == 0) {
            self.response = BackendResponseFinished;
            [[NSNotificationCenter defaultCenter] removeObserver: self];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
        }
        
    } else if ([photo response] == BackendResponseFailed) {
        [_pendingPhotos removeAllObjects];
        self.response = BackendResponseFailed;
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
    }
}

@end
