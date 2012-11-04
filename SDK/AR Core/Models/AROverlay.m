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


#import "AROverlayPoint.h"
#import "AROverlay.h"
#import "ARSite.h"

@implementation AROverlay

@synthesize site = _site;
@synthesize points = _points;

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        _dict = dict;
        [self setupVerticesFromDictionary];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _dict = [aDecoder decodeObjectForKey: @"dict"];
        _site = [aDecoder decodeObjectForKey: @"site"];
        [self setupVerticesFromDictionary];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject: _dict forKey: @"dict"];
    [aCoder encodeObject: _site forKey: @"site"];
}

- (NSString*)name
{
    return [_dict objectForKey: @"name"];
}

- (NSDictionary*)dictionary
{
    return _dict;
}

// Some simplistic parse logic for getting the point values
// out of the string. We'll want to add error handling to this at some point.
// Parsing only handles a single overlay currently... We'll wait
// for the multi-overlay spec to be defined before adding that parsing.
- (void)setupVerticesFromDictionary
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
        
    NSDictionary * o = [object dictionary];
    return ([[_dict objectForKey: @"vertices"] isEqualToString: [o objectForKey:@"vertices"]] && [[_dict objectForKey: @"description"] isEqualToString: [o objectForKey:@"description"]]);
}

@end
