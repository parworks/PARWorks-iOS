//
//  AROverlayBuilderAnnotationView.h
//  MagView
//
//  Created by Demetri Miller on 11/28/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSiteImage.h"
#import "ARSite.h"

@protocol AROverlayBuilderAnnotationViewDelegate <NSObject>

- (void)didAddScaledTouchPoint:(CGPoint)p;

@end

@interface AROverlayBuilderAnnotationView : UIView
{
    __weak UIImageView *_backingImageView;
    NSMutableArray *_pointViews;
    NSMutableArray *_lockViews;
}

@property(nonatomic, strong) ARSiteImage * siteImage;
@property(nonatomic, assign) float imageScale;
@property(nonatomic, readonly, getter = isEditing) BOOL editing;
@property(nonatomic, weak) id<AROverlayBuilderAnnotationViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andSiteImage:(ARSiteImage*)siteImage backingImageView:(UIImageView *)imageView;

- (AROverlay*)currentOverlay;
- (void)closeCurrentOverlay;

- (void)addScaledTouchPoint:(CGPoint)p;

@end
