//
//  UIView+ImageCapture.h
//  CameraTransitionTest
//
//  Created by Demetri Miller on 2/7/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ImageCapture)
- (UIImage*)imageRepresentationAtScale:(float)outputScaleFactor;
@end
