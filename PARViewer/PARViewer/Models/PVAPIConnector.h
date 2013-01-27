//
//  PVAPIConnector.h
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVAPIConnector : NSObject
{
    NSString * _appId;
    NSString * _appVersion;
}

+ (PVAPIConnector *)shared;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (oneway void)release;
- (id)autorelease;
- (id)init;

@end
