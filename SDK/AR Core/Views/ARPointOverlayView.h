//
//  ARPointOverlayView.h
//  MagView
//
//  Created by Demetri Miller on 11/28/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ARPointOverlayViewDelegate <NSObject>

- (void)didAddScaledTouchPoint:(CGPoint)p;
- (void)didClearPoints;
- (void)didRemoveLastPoint;

@end

@interface ARPointOverlayView : UIView
{
    __weak UIImageView *_backingImageView;
    NSMutableArray *_pointViews;
}

@property(nonatomic, strong) NSMutableArray *points;
@property(nonatomic, assign) float imageScale;
@property(nonatomic, readonly, getter = isEditing) BOOL editing;
@property(nonatomic, weak) id<ARPointOverlayViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame backingImageView:(UIImageView *)imageView;

- (void)addScaledTouchPoint:(CGPoint)p;
- (void)clearPoints;
- (void)removeLastPoint;

@end
