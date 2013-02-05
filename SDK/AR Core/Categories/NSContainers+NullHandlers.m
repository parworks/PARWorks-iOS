//
//  NSDictionary+NullHandlers.m
//  Wannado
//
//  Created by Ben Gotow on 7/1/12.
//  Copyright (c) 2012 Foundry376. All rights reserved.
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
