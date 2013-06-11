//
//  ARSiteImage.m
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


#import "ARConstants.h"
#import "ARSiteImage.h"
#import "ARManager.h"
#import "ARSite.h"
#import "AROverlay.h"
#import "NSBundle+ARCoreResources.h"
#import <objc/runtime.h>

@implementation ARSiteImage


- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        _dict = dict;
        _response = BackendResponseFinished;
    }
    return self;
}

- (id)initWithSite:(ARSite*)s andImage:(UIImage*)img
{
    self = [super init];
    if (self) {
        self.site = s;
        self.imageToUpload = [[ARManager shared] rotateImage:img byOrientationFlag:img.imageOrientation];
        self.response = WaitingToUpload;
        [[ARManager shared] queueSiteImageForUpload: self];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _dict = [aDecoder decodeObjectForKey: @"dict"];
        self.site = [aDecoder decodeObjectForKey: @"site"];
        self.imageToUpload = [aDecoder decodeObjectForKey: @"image"];
        _response = [aDecoder decodeIntForKey: @"response"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _dict forKey: @"dict"];
    [aCoder encodeObject: _site forKey: @"site"];
    [aCoder encodeInt:_response forKey: @"response"];
    if (self.imageToUpload)
        [aCoder encodeObject:_imageToUpload forKey:@"image"];
}

- (void)backgroundUploadStarted
{
    self.response = BackendResponseUploading;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: _site];
}

- (void)backgroundUploadFailed
{
    self.response = BackendResponseFailed;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: _site];
}

- (void)backgroundUploadSucceeded
{
    self.imageToUpload = nil;
    self.response = BackendResponseFinished;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: _site];
    [_site invalidateImages];
}

- (NSString*)identifier
{
    return [_dict objectForKey: @"id"];
}

- (NSArray*)overlays
{
    NSMutableArray * overlays = [NSMutableArray array];
    for (AROverlay * o in self.site.overlays)
        if ([[o siteImageIdentifier] isEqualToString: [self identifier]])
            [overlays addObject: o];
    return overlays;
}

- (NSString*)imagePathForCell:(GridCellView*)cell
{
    if (_response == BackendResponseUploading)
        return [[[NSBundle arCoreResourcesBundle] URLForResource:@"state_uploading" withExtension:@"png"] absoluteString];
    else if (_response == BackendResponseFailed)
        return [[[NSBundle arCoreResourcesBundle] URLForResource:@"state_failed" withExtension:@"png"] absoluteString];
    else
        return [[self urlForSize: 120] absoluteString];
}

- (void)applyExtraStylesToCell:(GridCellView*)cell
{
    [[cell layer] setShadowOpacity: ([[self overlays] count] > 0) ? 1 : 0];
    [[cell layer] setShadowColor: [[UIColor blueColor] CGColor]];
    [[cell layer] setShadowOffset: CGSizeMake(0, 1)];
    [[cell layer] setShadowRadius: 3];
}

- (NSURL *)urlForSize:(int)size
{
    NSString * url = nil;
    if (size < 333)
        url = [_dict objectForKey: @"gallery_size"];
    else if (size < 768)
        url = [_dict objectForKey: @"content_size"];
    else
        url = [_dict objectForKey: @"full_size"];
        
    url = [url substringFromIndex: [url rangeOfString:@"http" options:NSBackwardsSearch].location];
    return [NSURL URLWithString: url];
}

- (NSString *)urlStringForSiteImageSize:(ARSiteImageSize)sizeType
{
    NSString *key;
    switch (sizeType) {
        case ARSiteImageSize_Gallery:
            key = @"gallery_size";
            break;
        case ARSiteImageSize_Content:
            key = @"content_size";
            break;
        case ARSiteImageSize_Full:
            key = @"full_size";
            break;
        default:
            NSLog(@"Invalid size type... returning content size.");
            key = @"content_size";
            break;
    }
    
    return _dict[key];
}

- (NSTimeInterval)timestamp {
    // Dividing by 1000 since the API returns timestamps in milliseconds.
    return ([[_dict objectForKey: @"timestamp"] doubleValue]/1000.0);
}

@end
