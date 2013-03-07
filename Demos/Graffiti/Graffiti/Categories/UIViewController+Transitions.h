//
//  UIViewController+Transitions.h
//  CameraTransitionTest
//
//  Created by Demetri Miller on 2/10/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kUIViewController_PeelTransitionsAnimationDuration 0.8

@interface UIViewController (Transitions)

- (void)peelPresentViewController:(UIViewController *)viewControllerToPresent withBackgroundImage:(UIImage*)backgroundImage andContentImage:(UIImage *)contentImage depthImage:(UIImage *)depthImage;
- (void)unpeelViewController;


@end
