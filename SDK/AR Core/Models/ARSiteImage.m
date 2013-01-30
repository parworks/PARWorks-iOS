//
//  ARSiteImage.m
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


#import "ARConstants.h"
#import "ARSiteImage.h"
#import "ARManager.h"
#import "ARSite.h"
#import "AROverlay.h"

@implementation ARSiteImage

@synthesize site = _site;
@synthesize response = _response;

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
        
        img = [[ARManager shared] rotateImage:img byOrientationFlag:img.imageOrientation];
        NSData * imgData = UIImageJPEGRepresentation(img, 0.7);
        
        NSMutableDictionary * args = [NSMutableDictionary dictionary];
        [args setObject:_site.identifier forKey:@"site"];
        [args setObject:[NSString stringWithFormat:@"%@%p", [NSNumber numberWithLong:time(0)], self] forKey:@"filename"];

        ASIFormDataRequest * req = (ASIFormDataRequest*)[[ARManager shared] createRequest:REQ_SITE_IMAGE_ADD withMethod:@"POST" withArguments:args];
        ASIFormDataRequest * __weak __req = req;
        
        [req setData:imgData forKey:@"image"];
        [req setFailedBlock: ^(void) {
            self.response = BackendResponseFailed;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: _site];
            [[ARManager shared] criticalRequestFailed: __req];
        }];
        [req setCompletionBlock: ^(void) {
            if ([[ARManager shared] handleResponseErrors: __req]){
                self.response = BackendResponseFinished;
                [_site invalidateImages];
            } else {
                _response = BackendResponseFailed;
            }
        }];
        
        self.response = BackendResponseUploading;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: _site];
        
        [req startAsynchronous];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _dict = [aDecoder decodeObjectForKey: @"dict"];
        self.site = [aDecoder decodeObjectForKey: @"site"];
        _response = BackendResponseFinished;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _dict forKey: @"dict"];
    [aCoder encodeObject: _site forKey: @"site"];
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
        return [[[NSBundle mainBundle] URLForResource:@"state_uploading" withExtension:@"png"] absoluteString];
    else if (_response == BackendResponseFailed)
        return [[[NSBundle mainBundle] URLForResource:@"state_failed" withExtension:@"png"] absoluteString];
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



@end
