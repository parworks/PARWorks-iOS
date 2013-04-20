//
//  AROverlayTitleView.h
//  PARViewer
//
//  Created by Ben Gotow on 2/10/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AROverlay.h"

@interface AROverlayTitleView : UIButton
{
    UIButton *       _arrowView;
}

@property (nonatomic, weak) AROverlay * overlay;
@property (nonatomic, assign) CGPoint point;

- (id)initWithOverlay:(AROverlay*)overlay;
- (BOOL)showWithText:(NSString*)text atPoint:(CGPoint)p withinBounds:(CGRect)b;
- (BOOL)showWithText:(NSString*)text atPoint:(CGPoint)p withinBounds:(CGRect)b animated:(BOOL)animated;
- (void)dismiss;

- (NSString*)text;

@end
