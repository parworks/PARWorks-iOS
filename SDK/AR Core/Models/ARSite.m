//
//  ARSite.m
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


#import "ARSite.h"
#import "ARSiteImage.h"
#import "ARConstants.h"
#import "ARManager.h"
#import "AROverlay.h"
#import "ARSiteImage.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest+JSONAdditions.h"
#import "ARAugmentedPhoto.h"
#import "NSContainers+NullHandlers.h"

@implementation ARSite


- (id)initWithIdentifier:(NSString*)ident
{
    self = [super init];
    if (self) {
        self.identifier = ident;
        self.status = ARSiteStatusUnknown;
        _summaryImageCount = 0;
        _summaryOverlayCount = 0;
    }
    return self;
}

- (id)initWithInfo:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.identifier = [dict objectForKey: @"id"];
        self.status = ARSiteStatusUnknown;
        [self parseInfo: dict];
    }
    return self;
}

- (id)initWithSummaryDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _summaryImageCount = [dict[@"numImages"] intValue];
        _summaryOverlayCount = [dict[@"numOverlays"] intValue];
        self.identifier = dict[@"id"];
        self.status = [self siteStatusForString:dict[@"siteState"]];
        [self checkStatusIn20Seconds];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setIdentifier: [aDecoder decodeObjectForKey: @"identifier"]];
        [self setImages: [aDecoder decodeObjectForKey: @"images"]];
        [self setOverlays: [aDecoder decodeObjectForKey: @"overlays"]];
        [self setStatus: [aDecoder decodeIntForKey: @"status"]];
        [self setAugmentedPhotos: [aDecoder decodeObjectForKey: @"augmentedPhotos"]];
        _summaryImageCount = [aDecoder decodeIntForKey: @"summaryImageCount"];
        _summaryOverlayCount = [aDecoder decodeIntForKey: @"summaryOverlayCount"];
    }
    return self;    
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _identifier forKey: @"identifier"];
    [aCoder encodeObject: _images forKey: @"images"];
    [aCoder encodeObject: _overlays forKey: @"overlays"];
    [aCoder encodeObject: _augmentedPhotos forKey: @"augmentedPhotos"];
    [aCoder encodeInt: _status forKey: @"status"];
    [aCoder encodeInt: _summaryImageCount forKey: @"summaryImageCount"];
    [aCoder encodeInt: _summaryOverlayCount forKey: @"summaryOverlayCount"];
}

- (void)fetchInfo
{
    NSDictionary * d = [NSDictionary dictionaryWithObject:_identifier forKey:@"site"];
    ASIHTTPRequest * req = [[ARManager shared] createRequest: @"/ar/site/info/overview" withMethod:@"GET" withArguments:d];
    ASIHTTPRequest * __weak __req = req;
    ARSite * __weak __site = self;

    [req setCompletionBlock: ^(void) {
        NSDictionary * dict = [__req responseJSON];
        if ([dict isKindOfClass: [NSDictionary class]]) {
            [self parseInfo: dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
        }
    }];
    [req startAsynchronous];
}

- (void)parseInfo:(NSDictionary*)dict
{
    self.address = [dict objectForKey: @"address" or: nil];
    self.name = [dict objectForKey: @"name" or: @"Unnamed Site"];
    self.posterImage = [NSURL URLWithString: [dict objectForKey: @"posterImage" or: nil]];
    self.totalAugmentedImages = [[dict objectForKey: @"numAugmentedImages" or: nil] intValue];
    self.description = [dict objectForKey: @"description" or: @"No Description Provided."];
    self.location = CLLocationCoordinate2DMake([[dict objectForKey: @"lat" or: nil] doubleValue], [[dict objectForKey:@"lon" or: nil] doubleValue]);
    self.recentlyAugmentedImages = [dict objectForKey:@"recentlyAugmentedImages" or: nil];
    
    if (self.posterImage == nil)
        self.posterImage = [_recentlyAugmentedImages lastObject];
}

#pragma mark Site Status

- (void)checkStatus
{
    NSDictionary * d = [NSDictionary dictionaryWithObject:_identifier forKey:@"site"];
    ASIHTTPRequest * req = [[ARManager shared] createRequest: @"/ar/site/process/state" withMethod:@"GET" withArguments:d];
    ASIHTTPRequest * __weak __req = req;
    ARSite * __weak __site = self;
    
    [req setCompletionBlock: ^(void) {
        NSDictionary * json = [__req responseJSON];
        if (![json isKindOfClass: [NSDictionary class]]) {
            _status = ARSiteStatusUnknown;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
            return;
        }
        
        _status = [__site siteStatusForString:[json objectForKey:@"state"]];
        if (_status == ARSiteStatusProcessing)
            [__site checkStatusIn20Seconds];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
    }];
    [req startAsynchronous];
}

- (void)checkStatusIn20Seconds
{
    [self performSelector:@selector(checkStatus) withObject:nil afterDelay:20];
}

- (ARSiteStatus)siteStatusForString:(NSString *)s
{
    ARSiteStatus status = ARSiteStatusUnknown;
    if ([s isEqualToString:@"PROCESSED"]) {
        status = ARSiteStatusProcessed;
    } else if ([s isEqualToString:@"PROCESSING"]) {
        status = ARSiteStatusProcessing;
    } else if ([s isEqualToString:@"NOT_PROCESSED"]) {
        status = ARSiteStatusNotProcessed;
    } else if ([s isEqualToString:@"PROCESSING_FAILED"]) {
        status = ARSiteStatusProcessingFailed;
    } else if ([s isEqualToString:@"CREATING"]) {
        status = ARSiteStatusCreating;
    }
    
    return status;
}

- (NSString*)description
{
    NSString * s = @"❓";
    
    if (_status == ARSiteStatusProcessing)
        s = @"⏳";
    else if (_status == ARSiteStatusProcessingFailed)
        s = @"❗";
    else if (_status == ARSiteStatusProcessed)
        s = @"⭕";
        
    if (_invalid)
        return @"Site Invalid";
    else if (_status != ARSiteStatusCreating)
        return [NSString stringWithFormat: @"%d 🗻, %d 📌 - %@", [self imageCount], [self overlayCount], s];
    else
        return @"Creating site...";
}

#pragma mark Site Image Management

- (NSURL*)posterImageURL
{
    return [NSURL URLWithString: [_posterImage objectForKey: @"imgContentPath" or: [_posterImage objectForKey: @"imgPath"]]];
}

- (NSMutableArray*)images
{
    if ((_images == nil) && (!_invalid))
        [self fetchImages];
    return _images;
}

- (BOOL)isFetchingImages
{
    return (_imageReq != nil);
}

- (void)finishedFetchingImages
{
    _imageReq = nil;
}

- (void)fetchImages
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    _imageReq = [[ARManager shared] createRequest: REQ_SITE_IMAGE withMethod:@"GET" withArguments: dict];

    ARSite * __weak __site = self;
    ASIHTTPRequest * __weak req = _imageReq;
    
    [_imageReq setCompletionBlock: ^(void) {
        NSDictionary * json = [req responseJSON];
        if (![json isKindOfClass: [NSDictionary class]]) {
            __site.invalid = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
            return;
        }
        // grab all the image dictionaries from the JSON and pull out just the ID
        // of each image—that's all we need.
        __site.images = [NSMutableArray array];
        for (NSDictionary * imgJSON in [json objectForKey: @"images"]) {
            ARSiteImage * img = [[ARSiteImage alloc] initWithDictionary: imgJSON];
            [img setSite: __site];
            [[__site images] addObject: img];
        }
        [__site finishedFetchingImages];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
    }];
    
    [_imageReq setFailedBlock: ^(void) {
        [__site finishedFetchingImages];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
    }];

    [_imageReq startAsynchronous];
}

- (void)addImage:(UIImage*)img
{
    ARSiteImage * i = [[ARSiteImage alloc] initWithSite: self andImage: img];
    [_images addObject: i];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: self];
}

- (void)invalidateImages
{
    _images = nil;
    [self performSelector:@selector(fetchImages) withObject:nil afterDelay:1.5];
}

- (int)imageCount
{
    if (!_images || _images.count == 0) {
        return _summaryImageCount;
    } else {
        return _images.count;
    }
}

#pragma mark Site Overlay Management

- (int)overlayCount
{
    if (!_overlays || _overlays.count == 0) {
        return _summaryOverlayCount;
    } else {
        return _overlays.count;
    }
}

- (NSArray*)overlays
{
    if (_overlays == nil)
        [self fetchAvailableOverlays];
    return _overlays;
}

- (void)addOverlay:(AROverlay*)ar
{
    if (![_overlays containsObject: ar])
        [_overlays addObject: ar];
}

- (void)deleteOverlay:(AROverlay*)ar
{
    [_overlays removeObject: ar];
    
    if ([ar isSaved]) {
        // remove it from the server
    }
}

- (void)fetchAvailableOverlays
{
    if (_overlaysReq)
        return;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    _overlaysReq = [[ARManager shared] createRequest: REQ_SITE_OVERLAYS withMethod:@"GET" withArguments: dict];

    __weak ASIHTTPRequest * __req = _overlaysReq;
    __weak NSMutableArray * __overlays = _overlays;
    __weak ARSite * __self = self;

    [_overlaysReq setCompletionBlock: ^(void) {
        if ([[ARManager shared] handleResponseErrors: __req]){
            // grab all the image dictionaries from the JSON and pull out just the ID
            // of each image—that's all we need.
            NSDictionary * json = [__req responseJSON];
            __self.overlays = [NSMutableArray array];
            for (NSDictionary * overlayJSON in [json objectForKey: @"overlays"]) {
                AROverlay * overlay = [[AROverlay alloc] initWithDictionary: overlayJSON];
                [overlay setSite: __self];
                [__overlays addObject: overlay];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __self];
            _overlaysReq = nil;
        }
    }];
    [_overlaysReq startAsynchronous];
}


#pragma mark Augmenting and Processing

- (ARAugmentedPhoto*)augmentImage:(UIImage*)image
{
    ARAugmentedPhoto * a = [[ARAugmentedPhoto alloc] initWithImage: image];
    [a setSite: self];
    
    if (!_augmentedPhotos) _augmentedPhotos = [[NSMutableArray alloc] init];
    [_augmentedPhotos addObject: a];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: self];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
    [a process];
    return a;
}

- (void)removeAllAugmentedPhotos
{
    [_augmentedPhotos removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
}

- (void)processBaseImages
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    __weak ASIHTTPRequest * weak = [[ARManager shared] createRequest: REQ_SITE_PROCESS withMethod:@"GET" withArguments: dict];
    
    [self setStatus: ARSiteStatusProcessing];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: self];
    
    [weak setCompletionBlock: ^(void) {
        if ([[ARManager shared] handleResponseErrors: weak]){
            // processing has begun—we need to poll and wait for it to complete
            [self checkStatusIn20Seconds];
        }
    }];
    [weak startAsynchronous];
}

@end
