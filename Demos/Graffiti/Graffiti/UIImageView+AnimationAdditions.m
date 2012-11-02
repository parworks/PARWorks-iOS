//
//  UIImageView+AnimationAdditions.m
//  ScribbleMath
//
//  Created by Ben Gotow on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+AnimationAdditions.h"
#import "UIViewAdditions.h"

@implementation UIImageView (AnimationAdditions)

- (id)initWithImageSeries:(NSString*)fileFormatString
{
    self = [super init];
    if (self) {
        NSMutableArray * b = [NSMutableArray array];
        UIImage * img;
        
        for (int ii = 1; ii < 100; ii++) {
            img = [UIImage imageNamed:[NSString stringWithFormat: fileFormatString, ii]];
            if (img == nil)
                break;
            else {
                self.size = [img size];
                [b addObject: img];
            }
        }
        [self setAnimationImages: b];
        [self setAnimationDuration: 0.4];
        [self setAnimationRepeatCount: 1];
        [self setImage: [b lastObject]];
    }
    return self;
}

@end
