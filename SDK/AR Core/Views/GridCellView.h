//
//  GridCellView.h
//  PAR Works iOS SDK
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
#import "CachedImageView.h"

@class GridCellView;

@protocol GridCellViewDataProvider <NSObject>
@optional
- (NSString*)imagePathForCell:(GridCellView*)cell;
- (UIImage*)imageForCell:(GridCellView*)cell;
@end

@interface GridCellView : UIView
{
    CachedImageView * _imageView;
}

@property (nonatomic, unsafe_unretained) id parent;
@property (nonatomic, strong) NSObject<GridCellViewDataProvider> * dataProvider;

- (id)initWithDataProvider:(NSObject<GridCellViewDataProvider> *)dp;
- (void)setDataProvider:(NSObject<GridCellViewDataProvider> *)dp;

@end
