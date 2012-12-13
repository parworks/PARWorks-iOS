//
//  UIImageView+ContentScaling.h
//  MagView
//
//  Created by Demetri Miller on 11/28/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ContentScaling)

- (CGRect)aspectFitFrameForCurrentImage;
- (float)aspectFitScaleForCurrentImage;

@end
