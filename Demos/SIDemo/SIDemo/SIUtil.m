//
//  SIUtil.m
//  SIDemo
//
//  Created by Demetri Miller on 10/8/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "SIUtil.h"

@implementation SIUtil

static NSMutableDictionary * smallImages;

+ (int)smallImagesWithWidth:(int)width height:(int)height fromImage:(UIImage *)image withImageReadyCallback:(void (^)(int i, UIImage* img))imgCallback
{
    if (!image) return 0;

    NSOperationQueue * gcd = [[NSOperationQueue alloc] init];
    [gcd setMaxConcurrentOperationCount: 1];
    
    smallImages = [[NSMutableDictionary alloc] init];
    CGSize size = CGSizeMake(width, height);
    int xSteps = image.size.width / width;
    int ySteps = image.size.height / height;
    int count = xSteps * ySteps;
    
    int step = [gcd maxConcurrentOperationCount];
    for (int a = 0; a < step; a++)
    {
        [gcd addOperationWithBlock: ^(void) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 1);
            CGContextRef c = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(c, 0, size.height);
            CGContextScaleCTM(c, 1, -1);
            CGContextClipToRect(c, CGRectMake(0, 0, size.width, size.height));
            
            for (int i = a; i < count; i+= step) {
                int y = floor(i / xSteps);
                int x = i % xSteps;
            
                CGContextDrawImage(c, CGRectMake(-x * width, y * height - (image.size.height - height), image.size.width, image.size.height), image.CGImage);
                UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
                [smallImages setObject:img forKey:[NSNumber numberWithInt: count-i]];
                NSLog(@"Finished %d", i);
                
                imgCallback(i, img);
            }
            UIGraphicsEndImageContext();
        }];
    }
    
    return count;
}

+ (UIImage*)smallImageForArrayIndex:(int)r
{
    return [smallImages objectForKey: [NSNumber numberWithInt: r]];
}

+ (int)arrayIndexForCols:(int)cols rowIndex:(int)r columnIndex:(int)c
{
    return (cols*r) + c;
}

@end
