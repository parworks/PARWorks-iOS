//
//  HNColorPickerFolderView.h
//  HackNash
//
//  Created by Demetri Miller on 10/29/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HNFolderButton.h"
#import "UIView+Layout.h"

@class HNFolderButton;

@interface HNFolderView : UIView

@property(nonatomic, strong) HNFolderButton *folderButton;
@property(nonatomic, assign, getter = isShowing) BOOL showing;

/// Lifecycle
- (id)initWithButtonOffsetY:(CGFloat)offsetY image:(UIImage *)image frame:(CGRect)frame;


- (void)showInParent:(UIView *)view animated:(BOOL)animated;
- (void)hideInParent:(UIView *)view animated:(BOOL)animated;
@end
