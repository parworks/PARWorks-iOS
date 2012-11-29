//
//  AROverlayPoint.m
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


#import "ARSiteOverlayPoint.h"

@implementation ARSiteOverlayPoint


#pragma mark - Lifecycle
+ (ARSiteOverlayPoint *)pointWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
    ARSiteOverlayPoint *point = [[ARSiteOverlayPoint alloc] init];
    point.x = x;
    point.y = y;
    point.z = z;
    return point;
}

- (id)init
{
    self = [super init];
    if (self) {
        _x = _y = _z = 0.0;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _x = [[aDecoder decodeObjectForKey: @"x"] floatValue];
        _y = [[aDecoder decodeObjectForKey: @"y"] floatValue];
        _z = [[aDecoder decodeObjectForKey: @"z"] floatValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithFloat: _x] forKey:@"x"];
    [aCoder encodeObject:[NSNumber numberWithFloat: _y] forKey:@"y"];
    [aCoder encodeObject:[NSNumber numberWithFloat: _z] forKey:@"z"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<AROverlayPoint: %p> x:%f y:%f z:%f", self, _x, _y, _z];
}
@end
