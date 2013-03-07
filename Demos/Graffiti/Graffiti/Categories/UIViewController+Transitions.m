//
//  UIViewController+Transitions.m
//  CameraTransitionTest
//
//  Created by Demetri Miller on 2/10/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "UIViewController+Transitions.h"

#define kUIViewController_Transitions_MainLayerKey @"kUIViewController_Transitions_MainLayerKey"
#define kUIViewController_Transitions_ContentsShadowKey @"kUIViewController_Transitions_ContentsShadowKey"
#define kUIViewController_Transitions_DepthLayerKey @"kUIViewController_Transitions_DepthLayerKey"

@implementation UIViewController (Transitions)

- (void)peelPresentViewController:(UIViewController *)viewControllerToPresent withBackgroundImage:(UIImage*)backgroundImage andContentImage:(UIImage *)contentImage depthImage:(UIImage *)depthImage
{
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [mainWindow setUserInteractionEnabled: NO];
    
    CGFloat windowOffset;
    CGRect bounds;
    if (self.navigationController) {
        windowOffset = 0;
        bounds = self.navigationController.view.bounds;
    } else {
        windowOffset = 20;
        bounds = self.view.bounds;
    }
    CALayer *mainLayer = [CALayer layer];
    mainLayer.frame = mainWindow.bounds;
    mainLayer.backgroundColor = [[UIColor clearColor] CGColor];
    mainLayer.contents = (__bridge id)([backgroundImage CGImage]);
    mainLayer.anchorPoint = CGPointMake(0, 0.5);
    mainLayer.position = CGPointMake(0, (mainWindow.bounds.size.height/2));
    [mainWindow.layer addSublayer:mainLayer];
    objc_setAssociatedObject(mainWindow, kUIViewController_Transitions_MainLayerKey, mainLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CATransformLayer *transformLayer = [CATransformLayer layer];
    [mainLayer addSublayer:transformLayer];
    
    CALayer *contentsLayer = [CALayer layer];
    contentsLayer.frame = CGRectMake(0, windowOffset, bounds.size.width, bounds.size.height);
    contentsLayer.contentsGravity = kCAGravityResize;
    contentsLayer.contents = (id)contentImage.CGImage;
    [transformLayer addSublayer:contentsLayer];
    
    CAGradientLayer *contentsShadowLayer = [CAGradientLayer layer];
    contentsShadowLayer.frame = contentsLayer.bounds;
    contentsShadowLayer.colors = [NSArray arrayWithObjects: (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.3] CGColor], nil];
    contentsShadowLayer.startPoint = CGPointMake(0, 0);
    contentsShadowLayer.endPoint = CGPointMake(1, 0);
    contentsShadowLayer.opacity = 0.0;
    [contentsLayer addSublayer:contentsShadowLayer];
    objc_setAssociatedObject(mainWindow, kUIViewController_Transitions_ContentsShadowKey, contentsShadowLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CATransform3D depthTransform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
    depthTransform.m34 = -1.0/500.0;
    CALayer *depthLayer = [CALayer layer];
    depthLayer.anchorPoint = CGPointMake(0, 0.5);
    depthLayer.bounds = CGRectMake(0, 0, 24, bounds.size.height);
    depthLayer.position = CGPointMake(bounds.size.width, bounds.size.height/2);
    depthLayer.transform = depthTransform;
    depthLayer.zPosition = 0;
    depthLayer.contents = (id)depthImage.CGImage;
    [transformLayer addSublayer:depthLayer];
    objc_setAssociatedObject(mainWindow, kUIViewController_Transitions_DepthLayerKey, depthLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self startAnimationWithMainLayer:mainLayer contentsShadowLayer:contentsShadowLayer presentVC:viewControllerToPresent];
    });
}

- (void)startAnimationWithMainLayer:(CALayer *)mainLayer contentsShadowLayer:(CALayer *)contentsShadowLayer presentVC:(UIViewController *)vc
{
    CATransform3D t = CATransform3DIdentity;
    t.m34 = -1.0/500.0;
    t = CATransform3DTranslate(t, -24, 0, 0);
    t = CATransform3DRotate(t, 3*M_PI_2, 0, 1, 0);
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:kUIViewController_PeelTransitionsAnimationDuration];
    //    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    mainLayer.sublayerTransform = t;
    contentsShadowLayer.opacity = 1.0;
    [CATransaction commit];
    
    double delayInSeconds = kUIViewController_PeelTransitionsAnimationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        [self presentViewController:vc animated:NO completion:nil];
        [mainWindow setUserInteractionEnabled: YES];
        mainLayer.contents = nil;
    });
}


- (void)unpeelViewController
{
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [mainWindow setUserInteractionEnabled: NO];
    CALayer *mainLayer = (CALayer *)objc_getAssociatedObject(mainWindow, kUIViewController_Transitions_MainLayerKey);
    CALayer *contentsShadowLayer = (CALayer *)objc_getAssociatedObject(mainWindow, kUIViewController_Transitions_ContentsShadowKey);
    CALayer *depthLayer = (CALayer *)objc_getAssociatedObject(mainWindow, kUIViewController_Transitions_DepthLayerKey);
    depthLayer.position = CGPointMake(depthLayer.position.x, depthLayer.position.y + 20);
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:kUIViewController_PeelTransitionsAnimationDuration];
    mainLayer.sublayerTransform = CATransform3DIdentity;
    contentsShadowLayer.opacity = 0.0;
    [CATransaction commit];
    
    // Remove the depth layer right before the animation has finished so we don't get the weird off-pixel flickering
    double depthDelay = kUIViewController_PeelTransitionsAnimationDuration - 0.4;
    dispatch_time_t delayPopTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(depthDelay * NSEC_PER_SEC));
    dispatch_after(delayPopTime, dispatch_get_main_queue(), ^(void){
        [depthLayer removeFromSuperlayer];
        objc_setAssociatedObject(mainWindow, kUIViewController_Transitions_DepthLayerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    
    // Cleanup
    double delayInSeconds = kUIViewController_PeelTransitionsAnimationDuration - 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:NO completion:nil];
        [mainLayer removeFromSuperlayer];
        [mainWindow setUserInteractionEnabled: YES];
        objc_setAssociatedObject(mainWindow, kUIViewController_Transitions_MainLayerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(mainWindow, kUIViewController_Transitions_ContentsShadowKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
}

@end
