//
//  ARMultisiteAugmentedPhotoNoPolling.m
//  ARCore
//
//  Created by Adam Hickey on 8/8/13.
//  Copyright (c) 2013 PARWorks. All rights reserved.
//
#import "ARManager.h"
#import "ARMultisiteAugmentedPhotoNoPolling.h"
#import "ASIHTTPRequest+JSONAdditions.h"
#import "AROverlayPoint.h"

@implementation ARMultisiteAugmentedPhotoNoPolling
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
    self.overlays = [NSMutableArray array];
    
    //get the sitesToCheck and imgId
    _sitesToCheck = [json objectForKey:@"sitesToCheck"];
    _imgId = [json objectForKey:@"imgId"];
    
    //make the url
    NSString * url = [REQ_IMAGE_AUGMENT_MULTI_RESULT_NO_POLL stringByAppendingString: [_sitesToCheck componentsJoinedByString: @"&site="]];
    url = [url stringByAppendingString:[@"&imgId=" stringByAppendingString:_imgId]];
    
    //start the request
    ASIHTTPRequest * resultReq = [[ARManager shared] createRequest:url withMethod:@"GET" withArguments:[NSMutableDictionary dictionary]];
    ASIHTTPRequest * __weak __resultReq = resultReq;
    
    [resultReq setCompletionBlock:^(void){
        NSArray* json = [__resultReq responseJSON];
        [self processResponse:json];
    }];
    
    [resultReq startAsynchronous];
}

- (void)processResponse:(NSArray*) json
{
    [self processResponse: json forDisplayWithScale: 1];
}

- (void)processResponse: (NSArray*) response forDisplayWithScale: (float) scale
{
    for(NSDictionary * augmentData in response) {
        NSLog(@"processResponse");
    
        NSMutableDictionary * overlayDicts = [augmentData objectForKey: @"overlays"];
        for (NSDictionary * overlay in overlayDicts) {
            AROverlay * result = [[AROverlay alloc] initWithDictionary: overlay];
            for (AROverlayPoint * p in result.points) {
                p.x = p.x *= scale;
                p.y = p.y *= scale;
            }
            [result setSite: self.site];
            [super addOverlay: result];
        }
    }
    self.response = BackendResponseFinished;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end

