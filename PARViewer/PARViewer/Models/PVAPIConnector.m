//
//  PVAPIConnector.m
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVAPIConnector.h"

@implementation PVAPIConnector

static PVAPIConnector * sharedManager;

#pragma mark -
#pragma mark Singleton Implementation

+ (PVAPIConnector *)shared
{
	@synchronized(self)
	{
		if (sharedManager == nil)
			sharedManager = [[self alloc] init];
	}
	return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if (sharedManager == nil) {
			sharedManager = [super allocWithZone:zone];
			return sharedManager;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (unsigned)retainCount
{
	// denotes an object that cannot be released
	return UINT_MAX;
}

- (oneway void)release
{
	// do nothing
}

- (id)autorelease
{
	return self;
}

- (id)init
{
	self = [super init];
    
	if (self) {
        _appVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] retain];
        _appId = [@"4e9bc24a08a65b3be36e1089" retain];
    }
	return self;
}

@end
