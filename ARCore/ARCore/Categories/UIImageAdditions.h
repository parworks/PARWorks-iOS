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

#import <Foundation/Foundation.h>

@interface UIImage (ScribbleChatAdditions)

- (UIImage*)scaledImage:(float)scale; 

@end
