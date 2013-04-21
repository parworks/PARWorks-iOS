//
//  NSBundle+ARCoreResources.m
//  ARCore
//
//  Created by Demetri Miller on 4/21/13.
//  Copyright (c) 2013 PARWorks. All rights reserved.
//

#import "NSBundle+ARCoreResources.h"

@implementation NSBundle (ARCoreResources)

+ (NSBundle*)arCoreResourcesBundle
{
    static dispatch_once_t onceToken;
    static NSBundle *arCoreResourcesBundle = nil;
    dispatch_once(&onceToken, ^{
        arCoreResourcesBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"ARCore" withExtension:@"bundle"]];
    });
    return arCoreResourcesBundle;
}

@end
