//
//  ARSiteOverlay.m
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

#import "ARManager.h"
#import "AROverlayPoint.h"
#import "AROverlay.h"
#import "ARSite.h"
#import "ASIHTTPRequest+JSONAdditions.h"

@implementation AROverlay

@synthesize site = _site;
@synthesize points = _points;
@synthesize ID = _ID;
@synthesize siteImageIdentifier = _siteImageIdentifier;
@synthesize name = _name;
@synthesize content = _content;

- (id)initWithSiteImage:(ARSiteImage *)s
{
    self = [super init];
    if (self) {
        [self setSite: [s site]];
        [self setSiteImageIdentifier: s.identifier];
        self.points = [NSMutableArray array];
        
        if (_site.status != ARSiteStatusProcessed)
            @throw [NSException exceptionWithName:@"PAR Works API Error" reason:@"You must process the base images in your site before creating an overlay." userInfo:nil];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        [self setSiteImageIdentifier: [dict objectForKey: @"imageId"]];
        [self setContent: [dict objectForKey:@"description"]];
        [self setName: [dict objectForKey: @"name"]];
        [self setID: [dict objectForKey: @"id"]];
        [self setupPointsFromDictionary: dict];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _site = [aDecoder decodeObjectForKey: @"site"];
        _content = [aDecoder decodeObjectForKey: @"content"];
        _points = [aDecoder decodeObjectForKey: @"points"];
        _name = [aDecoder decodeObjectForKey: @"name"];
        _ID = [aDecoder decodeObjectForKey: @"id"];
        _siteImageIdentifier = [aDecoder decodeObjectForKey: @"siteImageIdentifier"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _site forKey: @"site"];
    [aCoder encodeObject: _points forKey: @"points"];
    [aCoder encodeObject: _siteImageIdentifier forKey: @"siteImageIdentifier"];
    [aCoder encodeObject: _content forKey: @"content"];
    [aCoder encodeObject: _ID forKey: @"id"];
    [aCoder encodeObject: _name forKey: @"name"];
}

- (BOOL)isSaved
{
    return self.ID != nil;
}

// Some simplistic parse logic for getting the point values
// out of the string. We'll want to add error handling to this at some point.
// Parsing only handles a single overlay currently... We'll wait
// for the multi-overlay spec to be defined before adding that parsing.
- (void)setupPointsFromDictionary:(NSDictionary *)_dict
{
    self.points = [NSMutableArray array];
    
    if ([_dict objectForKey: @"vertices"]) {
        NSString * line = [_dict objectForKey: @"vertices"];
        NSArray *components = [line componentsSeparatedByString:@","];
        for (int i = 0; i < components.count-1; i += 3) {
            CGFloat x = [[components objectAtIndex:i] floatValue];
            CGFloat y = [[components objectAtIndex:i + 1] floatValue];
            CGFloat z = [[components objectAtIndex:i + 2] floatValue];
            [_points addObject:[AROverlayPoint pointWithX:x y:y z:z]];
        }
    } else {
        NSArray * pointsArray = [_dict objectForKey: @"points"];
        for (NSDictionary * point in pointsArray) {
            CGFloat x = [[point objectForKey: @"x"] floatValue];
            CGFloat y = [[point objectForKey: @"y"] floatValue];
            CGFloat z = 0;
            [_points addObject: [AROverlayPoint pointWithX:x y:y z:z]];
        }
    }
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass: [AROverlay class]] == NO)
        return NO;
    
    return ([[self points] isEqual: [object points]] && [[self description] isEqualToString: [object description]]);
}

#pragma mark Adding Points to the Overlay

- (void)addPointWithX:(float)x andY:(float)y
{
    [_points addObject: [AROverlayPoint pointWithX:x y:y z:0]];
}

- (void)removeLastPoint
{
    if ([_points count] > 0)
        [_points removeLastObject];
}

- (void)save
{
    if ([_points count] < 3)
        @throw [NSException exceptionWithName:@"PARWorks API Error" reason:@"Please add at least three AROverlayPoints to your overlay before saving it." userInfo:nil];

    if (!_name)
        @throw [NSException exceptionWithName:@"PARWorks API Error" reason:@"Please add a name before saving." userInfo:nil];

    if (!_content)
        @throw [NSException exceptionWithName:@"PARWorks API Error" reason:@"Please add content before saving." userInfo:nil];
    
    
    NSMutableString * vertices = [[NSMutableString alloc] init];
    for (AROverlayPoint * point in _points)
        [vertices appendFormat: @"&v=%d,%d", (int)floorf([point x]), (int)floorf([point y])];

    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:_siteImageIdentifier forKey:@"imgId"];
    [dict setObject:[_content stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding] forKey:@"content"]; // description?
    [dict setObject:_site.identifier forKey:@"site"];
    [dict setObject:[_name stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding] forKey:@"name"];
    [dict setObject:[vertices substringFromIndex: 3] forKey:@"v"];
    if (_ID) [dict setObject:_ID forKey:@"id"];
    
    __weak ASIHTTPRequest * __req = [[ARManager shared] createRequest: REQ_SITE_OVERLAY_ADD withMethod:@"GET" withArguments: dict];
    
    [__req setCompletionBlock: ^(void) {
        if ([[ARManager shared] handleResponseErrors: __req]){
            // grab all the image dictionaries from the JSON and pull out just the ID
            // of each image—that's all we need.
            NSDictionary * json = [__req responseJSON];
            if ([self ID] == nil) {
                [self setID: [json objectForKey: @"id"]];
                [[self site] addOverlay: self];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object: self];
        }
    }];
    [__req startAsynchronous];
}


@end
