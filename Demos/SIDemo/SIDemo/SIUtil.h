//
//  SIUtil.h
//  SIDemo
//
//  Created by Demetri Miller on 10/8/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIUtil : NSObject

+ (int)smallImagesWithWidth:(int)width height:(int)height fromImage:(UIImage *)image withImageReadyCallback:(void (^)(int i, UIImage* img))imgCallback;
+ (int)arrayIndexForCols:(int)cols rowIndex:(int)r columnIndex:(int)c;

@end
