//
//  HNBrushPickerFolderView.h
//  HackNash
//
//  Created by Demetri Miller on 10/29/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "HNFolderView.h"

@interface HNBrushPickerFolderView : HNFolderView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_cv;
    UICollectionViewFlowLayout *_layout;
    
    NSMutableArray *_brushNames;
    
    int _initialCellSelectedIndex;
}

@property(nonatomic, strong) UISlider *brushSizeSlider;
@property(nonatomic, copy) NSString *currentBrushName;


@end
