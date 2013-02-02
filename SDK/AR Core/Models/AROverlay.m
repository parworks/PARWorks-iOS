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
#import "UIColor+Utils.h"

@implementation AROverlay

#pragma mark - Lifecycle
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
        self.ID = dict[@"id"];
        self.content = dict[@"description"];
        self.siteImageIdentifier = dict[@"imageId"];
        self.name = dict[@"name"];

        self.accuracy = dict[@"accuracy"];
        self.title = dict[@"title"];
        self.success = [dict[@"success"] intValue];
        
        [self setBoundaryPropertiesWithDictionary:dict[@"boundary"]];
        [self setContentPropertiesWithDictionary:dict[@"content"]];
        [self setCoverPropertiesWithDictionary:dict[@"cover"]];
        [self setupPointsFromDictionary: dict];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _ID = [aDecoder decodeObjectForKey:@"id"];
        _content = [aDecoder decodeObjectForKey:@"content"];
        _siteImageIdentifier = [aDecoder decodeObjectForKey:@"siteImageIdentifier"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _points = [aDecoder decodeObjectForKey:@"points"];
        
        _accuracy = [aDecoder decodeObjectForKey:@"accuracy"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _success = [aDecoder decodeBoolForKey:@"success"];
        
        _boundaryType = [aDecoder decodeIntegerForKey:@"boundaryType"];
        _boundaryColor = [aDecoder decodeObjectForKey:@"boundaryColor"];
        
        _contentType = [aDecoder decodeIntegerForKey:@"contentType"];
        _contentSize = [aDecoder decodeIntegerForKey:@"contentSize"];
        _contentProvider = [aDecoder decodeObjectForKey:@"contentProvider"];
        
        _coverType = [aDecoder decodeIntegerForKey:@"coverType"];
        _coverTransparency = [aDecoder decodeIntegerForKey:@"coverTransparency"];
        _coverColor = [aDecoder decodeObjectForKey:@"coverColor"];
        _coverProvider = [aDecoder decodeObjectForKey:@"coverProvider"];
        _site = [aDecoder decodeObjectForKey: @"site"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _ID forKey: @"id"];
    [aCoder encodeObject: _content forKey: @"content"];
    [aCoder encodeObject: _siteImageIdentifier forKey: @"siteImageIdentifier"];
    [aCoder encodeObject: _name forKey: @"name"];
    [aCoder encodeObject: _points forKey: @"points"];

    [aCoder encodeObject: _accuracy forKey: @"accuracy"];
    [aCoder encodeObject: _title forKey: @"title"];
    [aCoder encodeBool: _success forKey:@"success"];
    
    [aCoder encodeInteger: _boundaryType forKey: @"boundaryType"];
    [aCoder encodeObject: _boundaryColor forKey: @"boundaryColor"];

    [aCoder encodeInteger: _contentType forKey: @"contentType"];
    [aCoder encodeInteger: _contentSize forKey: @"contentSize"];
    [aCoder encodeObject: _contentProvider forKey: @"contentProvider"];
    
    [aCoder encodeInteger: _coverType forKey: @"coverType"];
    [aCoder encodeInteger: _coverTransparency forKey: @"coverTransparency"];
    [aCoder encodeObject: _coverColor forKey: @"coverColor"];
    [aCoder encodeObject: _coverProvider forKey: @"coverProvider"];
    [aCoder encodeObject: _site forKey: @"site"];
}


#pragma mark - Parsing Convenience
- (void)setBoundaryPropertiesWithDictionary:(NSDictionary *)dict
{
    if (!dict) {
        _boundaryColor = [UIColor magentaColor];
        _boundaryType = AROverlayBoundaryType_Solid;
        return;
    }

    _boundaryColor = [UIColor colorWithString:dict[@"color"]];

    NSString *type = dict[@"type"];
    if ([type.lowercaseString isEqualToString:@"hide"]) {
        _boundaryType = AROverlayBoundaryType_Hidden;
    } if ([type.lowercaseString isEqualToString:@"dashed"]) {
        _boundaryType = AROverlayBoundaryType_Dashed;
    } else {
        _boundaryType = AROverlayBoundaryType_Solid;
    }
}

- (void)setContentPropertiesWithDictionary:(NSDictionary *)dict
{
    if (!dict) {
        _contentProvider = @"";
        _contentSize = AROverlayContentSize_Medium;
        _contentType = AROverlayContentType_Text;
        return;
    }
    
    _contentProvider = dict[@"provider"];

    NSString *size = dict[@"size"];
    if ([size.lowercaseString isEqualToString:@"small"]) {
        _contentSize = AROverlayContentSize_Small;
    } else if ([size.lowercaseString isEqualToString:@"large"]) {
        _contentSize = AROverlayContentSize_Large;
    } else if ([size.lowercaseString isEqualToString:@"fullscreen"]) {
        _contentSize = AROverlayContentSize_Fullscreen;
    } else {
        _contentSize = AROverlayContentSize_Medium;
    }
    
    NSString *type = dict[@"type"];
    if ([type.lowercaseString isEqualToString:@"url"]) {
        _contentType = AROverlayContentType_URL;
    } else if ([type.lowercaseString isEqualToString:@"video"]) {
        _contentType = AROverlayContentType_Video;
    } else if ([type.lowercaseString isEqualToString:@"image"]) {
        _contentType = AROverlayContentType_Image;
    } else if ([type.lowercaseString isEqualToString:@"audio"]) {
        _contentType = AROverlayContentType_Audio;
    } else {
        _contentType = AROverlayContentType_Text;
    }
}

- (void)setCoverPropertiesWithDictionary:(NSDictionary *)dict
{
    if (!dict) {
        _coverColor = [UIColor yellowColor];
        _coverTransparency = 100;
        _coverProvider = @"";
        _coverType = AROverlayCoverType_Regular;
        return;
    }
    
    _coverColor = [UIColor colorWithString:dict[@"color"]];
    _coverTransparency = dict[@"transparency"] ? [dict[@"transparency"] intValue] : 100;
    _coverProvider = dict[@"provider"];
    
    NSString *type = dict[@"type"];
    if ([type.lowercaseString isEqualToString:@"hide"]) {
        _coverType = AROverlayCoverType_Hidden;
    } else if ([type.lowercaseString isEqualToString:@"image"]) {
        _coverType = AROverlayCoverType_Image;
    } else {
        _coverType = AROverlayCoverType_Regular;
    }
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
