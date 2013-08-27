//
//  ARSite.m
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

#import "ARAugmentedImage.h"
#import "ARAugmentedPhoto.h"
#import "ARSite.h"
#import "ARSiteImage.h"
#import "ARConstants.h"
#import "ARManager.h"
#import "AROverlay.h"
#import "ARSiteImage.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest+JSONAdditions.h"
#import "NSContainers+NullHandlers.h"

@implementation ARSite

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return ![key isEqualToString:@"status"];
}

- (id)initWithIdentifier:(NSString*)ident
{
    self = [super init];
    if (self) {
        self.identifier = ident;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateImages:) name:NOTIF_UPLOAD_COMPLETED_IN_SITE object:nil];
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateImages:) name:NOTIF_UPLOAD_COMPLETED_IN_SITE object:nil];
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
        self.name = dict[@"name"];
        self.status = [self siteStatusForString:dict[@"siteState"]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateImages:) name:NOTIF_UPLOAD_COMPLETED_IN_SITE object:nil];

        if ([[dict objectForKey:@"posterImageUrl"] isKindOfClass: [NSString class]]) {
            NSString * url = [dict objectForKey:@"posterImageUrl"];
            _posterImage = [NSDictionary dictionaryWithObject:url forKey:@"imgContentPath"];
        }
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
        _summaryImageCount = [aDecoder decodeIntForKey: @"summaryImageCount"];
        _summaryOverlayCount = [aDecoder decodeIntForKey: @"summaryOverlayCount"];
        _posterImage = [aDecoder decodeObjectForKey:@"_posterImage"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateImages:) name:NOTIF_UPLOAD_COMPLETED_IN_SITE object:nil];
    }
    return self;    
}

- (void)updateFromSite:(ARSite*)site
{
    _status = site.status;
    _siteDescription = site.siteDescription;
    _summaryOverlayCount = site.summaryOverlayCount;
    _summaryImageCount = site.summaryImageCount;
    _posterImage = site.posterImage;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _identifier forKey: @"identifier"];
    [aCoder encodeObject: _images forKey: @"images"];
    [aCoder encodeObject: _overlays forKey: @"overlays"];
    [aCoder encodeInt: _status forKey: @"status"];
    [aCoder encodeInt: _summaryImageCount forKey: @"summaryImageCount"];
    [aCoder encodeInt: _summaryOverlayCount forKey: @"summaryOverlayCount"];
    [aCoder encodeObject: _posterImage forKey: @"_posterImage"];
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
    self.totalAugmentedImages = [[dict objectForKey: @"numAugmentedImages" or: nil] intValue];
    self.siteDescription = [dict objectForKey: @"description" or: @"No Description Provided."];
    self.location = CLLocationCoordinate2DMake([[dict objectForKey: @"lat" or: nil] doubleValue], [[dict objectForKey:@"lon" or: nil] doubleValue]);
    self.logoURL = [NSURL URLWithString: [dict objectForKey: @"logoURL" or: nil]];

    _posterImage = [dict objectForKey: @"augmentedPosterImage" or: nil];
    _posterImageOriginalWidth = [[_posterImage objectForKey:@"fullSizeWidth" or: nil] floatValue];
    _recentAugmentationOutput = [dict objectForKey:@"recentlyAugmentedImages" or: nil];
    
    if (_posterImageOriginalWidth == 0)
        _posterImageOriginalWidth = 2592;
    
    if (_posterImage == nil)
        _posterImage = [_recentAugmentationOutput lastObject];
    
    if ((_posterImage == nil) && ([dict objectForKey:@"posterImageUrl"]))
        _posterImage = [NSDictionary dictionaryWithObject:[dict objectForKey:@"posterImageUrl"] forKey:@"imgContentPath"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - Getters/Setters
- (void)setStatus:(ARSiteStatus)status
{
    if (_status != status) {
        [self willChangeValueForKey:@"status"];
        _status = status;
        [self didChangeValueForKey:@"status"];
    }
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
            __site.status = ARSiteStatusUnknown;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
            return;
        }
        
        // Some entities use KVO on the status. Make sure we don't generate excessive calls
        ARSiteStatus s = [__site siteStatusForString:[json objectForKey:@"state"]];
        if (__site.status != s) {
            __site.status = s;
        }

        if (__site.status == ARSiteStatusProcessing)
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
//    NSLog(@"%@", [_posterImage description]);
    return [NSURL URLWithString: [_posterImage objectForKey: @"imgContentPath" or: [_posterImage objectForKey: @"imgPath"]]];
}

- (NSDictionary*)posterImageOverlayJSON
{
    NSData *data = [[_posterImage objectForKey: @"output" or: nil] dataUsingEncoding: NSASCIIStringEncoding];
    if (!data)
        return nil;
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error: nil];
}

- (NSMutableArray*)images
{
    if (!_images && ![self isFetchingImages] && !_invalid)
        [self fetchImagesWithCompletion:nil];
    return _images;
}

- (NSMutableArray *)registeredImages
{
    NSMutableArray *registered;
    if ([self images]) {
        registered = [NSMutableArray array];
        for (ARSiteImage *img in [self images]) {
            if (img.registered) {
                [registered addObject:img];
            }
        }
    }
    
    return registered;
}

- (NSMutableArray *)unregisteredImages
{
    NSMutableArray *unregistered;
    if (self.images) {
        unregistered = [NSMutableArray array];
        for (ARSiteImage *img in self.images) {
            if (!img.registered) {
                [unregistered addObject:img];
            }
        }
    }
    
    return unregistered;
}

- (BOOL)hasUnregisteredImages
{
    return ([self unregisteredImages] && [self unregisteredImages].count > 0);
}

- (BOOL)isFetchingImages
{
    return (_imageReq != nil || _registeredImageReq != nil);
}

- (void)finishedFetchingImages
{
    _imageReq = nil;
}

- (void)finishedFetchingRegisteredImages
{
    _registeredImageReq = nil;
}

- (void)fetchImagesWithCompletion:(ImageLoadCompletionBlock)completion
{
    if (_imageReq || _registeredImageReq)
        return;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    _imageReq = [[ARManager shared] createRequest: REQ_SITE_IMAGE withMethod:@"GET" withArguments: dict];
    _registeredImageReq = [self registeredImagesRequestWithArgs:dict completion:completion];
    
    ARSite * __weak __site = self;
    ASIHTTPRequest * __weak req = _imageReq;
    ASIHTTPRequest * __weak registeredReq = _registeredImageReq;
    
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
        
        [registeredReq startAsynchronous];
    }];
    
    [_imageReq setFailedBlock: ^(void) {
        [__site finishedFetchingImages];
        if (completion) {
            completion(__site.images);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
    }];

      
    [_imageReq startAsynchronous];
}

- (ASIHTTPRequest *)registeredImagesRequestWithArgs:(NSDictionary *)args completion:(ImageLoadCompletionBlock)completion
{
    ASIHTTPRequest *request = [[ARManager shared] createRequest: REQ_SITE_IMAGE_REGISTERED withMethod:@"GET" withArguments:args];

    typeof(self) __weak __site = self;
    ASIHTTPRequest * __weak req = request;

    [request setCompletionBlock:^{
        NSDictionary *json = [req responseJSON];
        if (![json isKindOfClass:[NSDictionary  class]]) {
            __site.invalid = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object:__site];
            return;
        }
        
        // At this point the images should have already been loaded.
        NSSet *imageIDs = [NSSet setWithArray:json[@"images"]];
        for (ARSiteImage *img in __site.images) {
            img.registered = [imageIDs containsObject:img.identifier];
        }
        
        [__site finishedFetchingRegisteredImages];
        
        if (completion) {
            completion(__site.images);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
        
    }];
    
    
    [request setFailedBlock:^{
        [__site finishedFetchingRegisteredImages];
        if (completion) {
            completion(__site.images);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
    }];
    
    return request;
}

- (void)invalidateImages:(NSNotification*)notif
{
    if ([[notif object] isEqualToString: _identifier])
        [self fetchImagesWithCompletion:nil];
}

- (int)imageCount
{
    if (!_images || _images.count == 0) {
        return _summaryImageCount;
    } else {
        return _images.count;
    }
}


#pragma mark - Augmented Images Management

- (NSMutableArray *)augmentedImages
{
    if (!_augmentedImages && ![self isFetchingAugmentedImages] && !_invalid) {
        [self fetchAugmentedImagesWithCompletion:nil];
    }
    return _augmentedImages;
}

- (BOOL)isFetchingAugmentedImages
{
    return (_augmentedImageReq != nil);
}

- (void)finishedFetchingAugmentedImages
{
    _augmentedImageReq = nil;
}

- (void)fetchAugmentedImagesWithCompletion:(ImageLoadCompletionBlock)completion
{
    if (_augmentedImageReq)
        return;

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    ImageLoadCompletionBlock completionCopy = [completion copy];
    
    _augmentedImageReq = [[ARManager shared] createRequest:REQ_SITE_IMAGE_LIST_AUGMENTED withMethod:@"GET" withArguments:dict];
    
    typeof(self) __weak __site = self;
    typeof(ASIHTTPRequest *) __weak __req = _augmentedImageReq;
    
    [_augmentedImageReq setCompletionBlock:^{
        NSArray *json = [__req responseJSON];
        if (![json isKindOfClass:[NSArray class]]) {
            __site.invalid = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object:__site];
            return;
        }
        
        // Grab all the image dictionaries from the JSON and create our ARAugmentedImage objects.
        __site.augmentedImages = [NSMutableArray array];
        for (NSDictionary *imgJson in json) {
            ARAugmentedImage *img = [[ARAugmentedImage alloc] initWithDictionary:imgJson];
            [img setSite:__site];
            [[__site augmentedImages] addObject:img];
        }

        if (completionCopy) {
            completionCopy([__site augmentedImages]);
        }
        [__site finishedFetchingAugmentedImages];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
    }];
    
    [_augmentedImageReq setFailedBlock: ^(void) {
        [__site finishedFetchingImages];
        if (completionCopy) {
            completionCopy([__site augmentedImages]);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __site];
    }];
    
    [_augmentedImageReq startAsynchronous];
    
}

- (void)invalidateAugmentedImages:(NSNotification *)note
{
    if ([[note object] isEqualToString: _identifier])
        [self fetchAugmentedImagesWithCompletion:nil];
}

- (int)augmentedImagesCount
{
    return _augmentedImages.count;
}

#pragma mark Site Overlay Management

- (void)invalidateOverlays
{
    _overlays = nil;
}

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
    // delete any overlay that is exactly equal to ar, or any overlay
    // that has the same ID (in case the _overlays list has been reloaded
    // and this particular instance of the object is not in the array.)
    [_overlays removeObject: ar];
    for (int ii = [_overlays count] - 1; ii>=0;ii--) {
        if ([[[_overlays objectAtIndex: ii] ID] isEqualToString: [ar ID]])
            [_overlays removeObjectAtIndex: ii];
    }
    
    if ([ar isSaved]) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
        [dict setObject:[ar ID] forKey:@"id"];
        _stagingDeleteReq = [[ARManager shared] createRequest: REQ_SITE_OVERLAY_REMOVE_STAGING withMethod:@"GET" withArguments: dict];
        [_stagingDeleteReq startAsynchronous];
        
        _deleteReq = [[ARManager shared] createRequest: REQ_SITE_OVERLAY_REMOVE withMethod:@"GET" withArguments: dict];
        [_deleteReq startAsynchronous];
    }
}

- (void)fetchAvailableOverlays
{
    if (_overlaysReq)
        return;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    if ([[ARManager shared] addOverlaysToStagingArea])
        [dict setObject:@"true" forKey:@"isStaging"];
    _overlaysReq = [[ARManager shared] createRequest: REQ_SITE_OVERLAYS withMethod:@"GET" withArguments: dict];

    __weak ASIHTTPRequest * __req = _overlaysReq;
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
                [(NSMutableArray*)__self.overlays addObject: overlay];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __self];
            if ([[ARManager shared] addOverlaysToStagingArea]) {
                [__self fetchAndIntersectProcessedOverlays];
            } else {
                [__self setOverlayRequest: nil];
            }
        }
    }];
    [_overlaysReq startAsynchronous];
}

- (void)setOverlayRequest:(ASIHTTPRequest*)req
{
    _overlaysReq = req;
}

- (void)fetchAndIntersectProcessedOverlays
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    _overlaysReq = [[ARManager shared] createRequest: REQ_SITE_OVERLAYS withMethod:@"GET" withArguments: dict];
    __weak ASIHTTPRequest * __req = _overlaysReq;
    __weak ARSite * __self = self;

    [_overlaysReq setCompletionBlock: ^(void) {
        if ([[ARManager shared] handleResponseErrors: __req]){
            NSDictionary * json = [__req responseJSON];

            for (AROverlay * overlay in __self.overlays) {
                [overlay setProcessed: NO];
            }
            
            for (NSDictionary * overlayJSON in [json objectForKey: @"overlays"]) {
                // we have to compare overlays based on their name because the ID seems to
                // change when they're processed (which is annoying...)
                NSString * name = [overlayJSON objectForKey: @"name"];
                for (AROverlay * overlay in __self.overlays) {
                    if ([[overlay name] isEqualToString:name])
                        [overlay setProcessed: YES];
                }
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: __self];
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

- (ARAugmentedPhoto*)changeDetectImage:(UIImage *)image
{
    ARAugmentedPhoto * a = [[ARAugmentedPhoto alloc] initWithImage: image];
    [a setSite: self];
    
 //   if (!_augmentedPhotos) _augmentedPhotos = [[NSMutableArray alloc] init];
 //   [_augmentedPhotos addObject: a];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: self];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
    [a processChangeDetection];
    return a;
}

- (void)setPosterImageWithImage:(ARSiteImage*)image
{
    NSDictionary * dict = @{@"site": self.identifier, @"imageId": image.identifier};
    __weak ASIHTTPRequest * weak = [[ARManager shared] createRequest: REQ_SITE_POSTER withMethod:@"GET" withArguments: dict];
    [weak startAsynchronous];
    
    _posterImage = @{@"imgContentPath": [[image urlForSize: 1000] absoluteString]};
}

- (void)removeAllAugmentedPhotos
{
    [_augmentedPhotos removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
}

- (void)processBaseImages
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    
    if ([[ARManager shared] addOverlaysToStagingArea]) {
        [dict setObject:@"true" forKey:@"processStaging"];
        [dict setObject:@"true" forKey:@"cleanOverlays"];
        [dict setObject:@"indoor" forKey:@"profile"];
    }
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

- (void)removeBaseImage:(ARSiteImage*)image
{
    NSDictionary * args = @{@"site": [self identifier], @"id": [image identifier]};
    __weak ASIHTTPRequest * weak = [[ARManager shared] createRequest: REQ_SITE_IMAGE_REMOVE withMethod:@"GET" withArguments: args];
    [weak setCompletionBlock: ^(void) {
        [[self images] removeObject: image];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: self];
    }];
    [weak startAsynchronous];
}

- (void)reprocessReports
{
     NSDictionary * args = @{@"site": [self identifier], @"cleanOverlays": @"true"};
        
    __weak ASIHTTPRequest * __req = [[ARManager shared] createRequest: REQ_SITE_OVERLAY_REPROCESS withMethod:@"GET" withArguments:args];
    
    [__req setCompletionBlock: ^(void) {
        if ([[ARManager shared] handleResponseErrors: __req]){           
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: self];
        }
    }];
    [__req startAsynchronous];
}

#pragma mark Accessing Public, Recently Augmented Photos

- (int)recentlyAugmentedImageCount
{
    return [_recentAugmentationOutput count];
}

- (NSURL*)URLForRecentlyAugmentedImageAtIndex:(int)index
{
    NSDictionary * output = [_recentAugmentationOutput objectAtIndex: index];
    return [NSURL URLWithString: [output objectForKey: @"imgContentPath" or: [output objectForKey: @"imgPath"]]];
}

- (float)originalWidthForRecentlyAugmentedImageAtIndex:(int)index
{
    NSDictionary * output = [_recentAugmentationOutput objectAtIndex: index];
    float width = [[output objectForKey:@"fullSizeWidth"] floatValue];
    if (width == 0)
        width = 2592;
    return width;
}


- (NSDictionary*)overlayJSONForRecentlyAugmentedImageAtIndex:(int)index
{
    NSDictionary * output = [_recentAugmentationOutput objectAtIndex: index];
    NSData *data = [[output objectForKey: @"output" or: nil] dataUsingEncoding: NSASCIIStringEncoding];
    if (!data)
        return nil;
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error: nil];
}


@end
