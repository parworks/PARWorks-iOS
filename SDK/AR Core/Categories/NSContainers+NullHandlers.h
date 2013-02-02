//
//  NSDictionary+NullHandlers.h
//  Wannado
//
//  Created by Ben Gotow on 7/1/12.
//  Copyright (c) 2012 Foundry376. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NullHandlers)

- (id)objectForKey:(id)aKey or:(id)ifNull;

@end

@interface NSArray (NullHandlers)

- (id)objectAtIndex:(NSUInteger)index or:(id)ifNullOrOutOfBounds;

@end
