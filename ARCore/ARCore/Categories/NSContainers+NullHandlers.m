//
//  NSDictionary+NullHandlers.m
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


#import "NSContainers+NullHandlers.h"

@implementation NSDictionary (NullHandlers)

- (id)objectForKey:(id)aKey or:(id)ifNull
{
    id o = [self objectForKey: aKey];
    if ((o == nil) || ([o isKindOfClass: [NSNull class]]))
        return ifNull;
    return o;
}

@end



@implementation NSMutableDictionary (NullHandlers)

- (BOOL)setObjectIfValid:(id)anObject forKey:(id < NSCopying >)aKey
{
    if (anObject) {
        [self setObject:anObject forKey:aKey];
        return YES;
    }
    
    return NO;
}

@end



@implementation NSArray (NullHandlers)

- (id)objectAtIndex:(NSUInteger)index or:(id)ifNullOrOutOfBounds
{
    if  (index >= [self count])
        return ifNullOrOutOfBounds;
        
    id o = [self objectAtIndex: index];
    if ([o isKindOfClass: [NSNull class]])
        return ifNullOrOutOfBounds;

    return o;
}

@end
