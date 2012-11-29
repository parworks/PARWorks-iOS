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

@implementation ARSite

@synthesize identifier = _identifier;
@synthesize images = _images;
@synthesize overlays = _overlays;
@synthesize invalid = _invalid;
@synthesize status = _status;

- (id)initWithIdentifier:(NSString*)ident
{
    self = [super init];
    if (self) {
        self.identifier = ident;
        self.status = ARSiteStatusUnknown;
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
        
        if (_status != ARSiteStatusProcessed)
            [self checkStatus];
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
}

- (void)checkStatus
{
    NSDictionary * d = [NSDictionary dictionaryWithObject:_identifier forKey:@"site"];
    ASIHTTPRequest * req = [[ARManager shared] createRequest: @"/ar/site/process/state" withMethod:@"GET" withArguments:d];
    ASIHTTPRequest * __weak weak = req;
    ARSite * __weak site = self;
    
    [req setCompletionBlock: ^(void) {
        NSDictionary * json = [weak responseJSON];
        if (![json isKindOfClass: [NSDictionary class]]) {
            _status = ARSiteStatusUnknown;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: site];
            return;
        }
        if ([[json objectForKey:@"state"] isEqualToString: @"PROCESSING"])
            _status = ARSiteStatusProcessing;
        
        if ([[json objectForKey:@"state"] isEqualToString: @"NOT_PROCESSED"])
            _status = ARSiteStatusNotProcessed;
        
        if ([[json objectForKey:@"state"] isEqualToString: @"PROCESSING_FAILED"])
            _status = ARSiteStatusProcessingFailed;
        
        if ([[json objectForKey:@"state"] isEqualToString: @"PROCESSED"])
            _status = ARSiteStatusProcessed;

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: site];
    }];
    [req startAsynchronous];
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
        return [NSString stringWithFormat: @"%d 🗻, %d 📌 - %@", [[self images] count], [[self availableOverlays] count], s];
    else
        return @"Creating site...";
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

    ARSite * __weak site = self;
    ASIHTTPRequest * __weak req = _imageReq;
    
    [_imageReq setCompletionBlock: ^(void) {
        NSDictionary * json = [req responseJSON];
        if (![json isKindOfClass: [NSDictionary class]]) {
            site.invalid = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: site];
            return;
        }
        // grab all the image dictionaries from the JSON and pull out just the ID
        // of each image—that's all we need.
        self.images = [NSMutableArray array];
        for (NSDictionary * imgJSON in [json objectForKey: @"images"]) {
            ARSiteImage * img = [[ARSiteImage alloc] initWithDictionary: imgJSON];
            [img setSite: site];
            [[site images] addObject: img];
        }
        [site finishedFetchingImages];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: site];
    }];
    
    [_imageReq setFailedBlock: ^(void) {
        [site finishedFetchingImages];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: site];
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

- (NSArray*)availableOverlays
{
    if (_overlays == nil)
        [self fetchAvailableOverlays];
    return _overlays;
}

- (void)fetchAvailableOverlays
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    __weak ASIHTTPRequest * weak = [[ARManager shared] createRequest: REQ_SITE_OVERLAYS withMethod:@"GET" withArguments: dict];
    
    [weak setCompletionBlock: ^(void) {
        if ([[ARManager shared] handleResponseErrors: weak]){
            // grab all the image dictionaries from the JSON and pull out just the ID
            // of each image—that's all we need.
            NSDictionary * json = [weak responseJSON];
            self.overlays = [NSMutableArray array];
            for (NSDictionary * overlayJSON in [json objectForKey: @"overlays"]) {
                AROverlay * overlay = [[AROverlay alloc] initWithDictionary: overlayJSON];
                [overlay setSite: self];
                [_overlays addObject: overlay];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: self];
        }
    }];
    [weak startAsynchronous];
}

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
            // grab all the image dictionaries from the JSON and pull out just the ID
            // of each image—that's all we need.
            [self setStatus: ARSiteStatusProcessed];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: self];
        }
    }];
    [weak startAsynchronous];
}

@end
