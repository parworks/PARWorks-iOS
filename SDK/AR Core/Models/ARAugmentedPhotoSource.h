//
//  ARAugmentedPhotoSource.h
//  EasyPAR
//
//  Created by Ben Gotow on 4/11/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARAugmentedPhoto;

@protocol ARAugmentedPhotoSource <NSObject>

- (NSString*)name;
- (ARAugmentedPhoto*)augmentImage:(UIImage*)image;

@end
