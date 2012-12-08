//
//  UINavigationController+RotationHack.m
//  EasyPAR
//
//  Created by Demetri Miller on 11/29/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "UINavigationController+RotationHack.h"

@implementation UINavigationController (RotationHack)

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
