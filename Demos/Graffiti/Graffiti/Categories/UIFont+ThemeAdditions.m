//
//  UIFont+ThemeAdditions.m
//  PARViewer
//
//  Created by Ben Gotow on 2/5/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "UIFont+ThemeAdditions.h"

@implementation UIFont (ThemeAdditions)

+ (UIFont*)boldParworksFontWithSize:(float)size
{
    return [UIFont fontWithName:@"Avenir-Medium" size:size];
}

+ (UIFont*)heavyParworksFontWithSize:(float)size
{
    return [UIFont fontWithName:@"Avenir-Heavy" size:size];
}

+ (UIFont*)parworksFontWithSize:(float)size
{
    return [UIFont fontWithName:@"Avenir-Roman" size:size];
}

@end
