//
//  AROvelayViewFactory.h
//  ViewerDemo
//
//  Created by Demetri Miller on 1/29/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AROverlayView;


@interface AROverlayViewFactory : NSObject

+ (AROverlayView *)viewWithOverlay:(AROverlay *)overlay;

@end