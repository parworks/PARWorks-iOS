//
//  UIImageView+ContentScaling.m
//  MagView
//
//  Created by Demetri Miller on 11/28/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+ContentScaling.h"

@implementation UIView (ContentScaling)

- (CGRect)aspectFitFrameForCurrentImage
{
    UIImage *image = [self imageFromView];
    float imageRatio = image.size.width / image.size.height;
    float viewRatio = self.frame.size.width / self.frame.size.height;
    float scale = [self aspectFitScaleForCurrentImage];
    
    CGRect frame;
    if(imageRatio < viewRatio) {
        float width = scale * image.size.width;
        float topLeftX = (self.frame.size.width - width) * 0.5;
        frame = CGRectMake(topLeftX, 0, width, self.frame.size.height);
    } else{
        float height = scale * image.size.height;
        float topLeftY = (self.frame.size.height - height) * 0.5;
        frame = CGRectMake(0, topLeftY, self.frame.size.width, height);
    }
    
    return frame;
}

- (float)aspectFitScaleForCurrentImage
{
    UIImage *image = [self imageFromView];
    float imageRatio = image.size.width / image.size.height;
    float viewRatio = self.frame.size.width / self.frame.size.height;
    
    float scale;
    if(imageRatio < viewRatio) {
        scale = self.frame.size.height / image.size.height;
    } else{
        scale = self.frame.size.width / image.size.width;
    }
    
    return scale;
}

- (UIImage *)imageFromView
{
    UIImage *image;
    if ([self respondsToSelector:@selector(image)]) {
        image = (UIImage *)[self performSelector:@selector(image)];
    } else {
        image = [UIImage imageWithCGImage:(CGImageRef)self.layer.contents];
    }
    return image;
}

@end
