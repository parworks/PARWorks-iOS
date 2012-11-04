//
//  GRColorPickerFolderView.h
//  Graffiti
//
//  Copyright 2012 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import <UIKit/UIKit.h>

#import "GRFolderButton.h"
#import "UIView+Layout.h"

@class GRFolderButton;

@interface GRFolderView : UIView

@property(nonatomic, strong) GRFolderButton *folderButton;
@property(nonatomic, assign, getter = isShowing) BOOL showing;

/// Lifecycle
- (id)initWithButtonOffsetY:(CGFloat)offsetY image:(UIImage *)image frame:(CGRect)frame;


- (void)showInParent:(UIView *)view animated:(BOOL)animated;
- (void)hideInParent:(UIView *)view animated:(BOOL)animated;
@end
