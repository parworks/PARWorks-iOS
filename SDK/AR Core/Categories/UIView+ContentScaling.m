//
//  UIView+ContentScaling.m
//  PAR Works iOS SDK
//
//  Copyright 2013 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+ContentScaling.h"

@implementation UIView (ContentScaling)

- (CGRect)aspectFitFrameForCurrentImage
{
    UIImage *image = [self imageFromView];
    
    if (image == nil) {
        return CGRectZero;
    }
    
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
    
    if (image == nil) {
        return 0;
    }
    
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
