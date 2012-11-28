//
//  WStreamGridView.h
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
#import "GridCellView.h"

@class GridView;

@protocol GridViewDelegate <NSObject>

- (BOOL)isLoadingForGridView:(GridView*)gv;
- (NSArray*)objectCollectionForGridView:(GridView*)gv;
- (void)object:(id)obj selectedInGridView:(GridView*)gv;

@end

@interface GridView : UIView <UIScrollViewDelegate>
{
    NSMutableArray * _cells;
    UIScrollView * _scrollView;
    
    NSMutableArray * _unusedCells;
    
    UIView * _statusView;
    UILabel * _statusLabel;
    UIActivityIndicatorView * _statusSpinner;
}

@property (nonatomic, weak) IBOutlet NSObject<GridViewDelegate> * delegate;

- (id)initWithFrame:(CGRect)frame;

- (void)awakeFromNib;
- (void)setup;

- (void)reloadData;

@end
