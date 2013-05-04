//
//  UIImage+ARCoreResources.m
//  ARCore
//
//  Created by Demetri Miller on 4/21/13.
//  Copyright (c) 2013 PARWorks. All rights reserved.
//

#import "NSBundle+ARCoreResources.h"
#import "UIImage+ARCoreResources.h"

@implementation UIImage (ARCoreResources)

+ (UIImage *)arCoreImageNamed:(NSString *)name
{
    // Check the default bundle first before trying to load the image
    // from our custom bundle.
    UIImage *img = [UIImage imageNamed:name];
    if (!img) {
        img = [UIImage imageNamed:[NSString stringWithFormat:@"ARCore.bundle/%@", name]];
    }
    
    return img;
}

@end
