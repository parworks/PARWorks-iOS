//
//  UIImageAdditions.m
//  ScribbleChat
//
//  The UIImageAdditions add convenience functions to the UIImage class that allow it to be
//  scaled and serialized.
// 
//  Created by Ben Gotow on 12/24/08.
//  Copyright 2008 MEDL Mobile. All rights reserved.
//

#import "UIImageAdditions.h"

@implementation UIImage (ScribbleChatAdditions)

- (UIImage*)scaledImage:(float)scale
{
    CGImageRef image = [self CGImage];
    CGSize newSize = CGSizeMake(self.size.width * scale, self.size.height * scale);
    UIGraphicsBeginImageContext(newSize);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, newSize.height);
    CGContextScaleCTM(c, 1, -1);
    CGContextDrawImage(c, CGRectMake(0, 0, newSize.width, newSize.height), image);
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
