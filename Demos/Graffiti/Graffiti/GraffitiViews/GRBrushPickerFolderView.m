//
//  GRBrushPickerFolderView.m
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

#import <objc/runtime.h>

#import "GRBrushPickerFolderView.h"

#define kGRBrushPickerFolderViewDefaultsSliderKey @"kGRBrushPickerFolderViewDefaultsSliderKey"
#define kGRBrushPickerFolderViewDefaultsBrushName @"kGRBrushPickerFolderViewDefaultsBrushName"

@implementation GRBrushPickerFolderView

- (id)initWithButtonOffsetY:(CGFloat)offsetY image:(UIImage *)image frame:(CGRect)frame
{
    self = [super initWithButtonOffsetY:offsetY image:image frame:frame];
    if (self) {
        [self loadBrushNames];
        self.currentBrushName = [self brushNameFromDefaults];
        _initialCellSelectedIndex = [_brushNames indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqualToString:_currentBrushName];
        }];
        
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumInteritemSpacing = 20;
        _layout.minimumLineSpacing = 20;
        _layout.itemSize = CGSizeMake(44, 44);

        _cv = [[UICollectionView alloc] initWithFrame:CGRectMake(self.folderButton.width + 20, 0, self.width - self.folderButton.width - 40, self.height) collectionViewLayout:_layout];
        [_cv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"BrushCell"];
        _cv.backgroundColor = [UIColor clearColor];
        _cv.contentInset = UIEdgeInsetsMake(20, 0, 20, 00);
        _cv.showsHorizontalScrollIndicator = NO;
        _cv.showsVerticalScrollIndicator = NO;
        _cv.delegate = self;
        _cv.dataSource = self;
        [self addSubview:_cv];
        
        
        self.brushSizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(_cv.x, self.height - 30, _cv.width, 30)];
        [_brushSizeSlider addTarget:self action:@selector(handleBrushSizeSliderChanged:) forControlEvents:UIControlEventValueChanged];
        _brushSizeSlider.minimumValue = 10;
        _brushSizeSlider.maximumValue = 44;
        _brushSizeSlider.value = [self brushSizeFromDefaults];
        [self addSubview:_brushSizeSlider];
    }
    return self;
}

- (void)loadBrushNames
{
    _brushNames = [NSMutableArray array];
    NSString *format = @"brush_%d_texture";
    int count = 1;
    NSString *filename = [NSString stringWithFormat:format, count];
    while ([[NSBundle mainBundle] pathForResource:filename ofType:@"png"]) {
        [_brushNames addObject:filename];
        count++;
        filename = [NSString stringWithFormat:format, count];
    }
}


#pragma mark - User Defaults
- (void)handleBrushSizeSliderChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setFloat:_brushSizeSlider.value forKey:kGRBrushPickerFolderViewDefaultsSliderKey];
}

- (float)brushSizeFromDefaults
{
    float value = [[NSUserDefaults standardUserDefaults] floatForKey:kGRBrushPickerFolderViewDefaultsSliderKey];
    if (value == 0) {
        value = 20;
    }
    return value;
}

- (NSString *)brushNameFromDefaults
{
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:kGRBrushPickerFolderViewDefaultsBrushName];
    if (!name) {
        name = _brushNames[0];
    }
    return name;
}

- (void)saveBrushNameToDefaults:(NSString *)name
{
    [[NSUserDefaults standardUserDefaults] setObject:_currentBrushName forKey:kGRBrushPickerFolderViewDefaultsBrushName];
}


#pragma mark - UICollectionViewDataSource/Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self setCellSelected:cell];
    self.currentBrushName = _brushNames[indexPath.row];
    [self saveBrushNameToDefaults:_currentBrushName];
    
    if (_initialCellSelectedIndex >= 0) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_initialCellSelectedIndex inSection:0]];
        [self setCellDeselected:cell];
        _initialCellSelectedIndex = -1;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self setCellDeselected:cell];
}


- (void)setCellSelected:(UICollectionViewCell *)cell
{
    cell.contentView.layer.borderWidth = 3.0;
    cell.contentView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:1.0].CGColor;
    
}

- (void)setCellDeselected:(UICollectionViewCell *)cell
{
    //    cell.contentView.layer.shadowOpacity = 0.0;
    cell.contentView.layer.borderWidth = 1.0;
    cell.contentView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:1.0].CGColor;
    
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _brushNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BrushCell" forIndexPath:indexPath];

    UIImageView *iv = objc_getAssociatedObject(cell, @"ImageView");
    if (!iv) {
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        iv.backgroundColor = [UIColor whiteColor];
        objc_setAssociatedObject(cell, @"ImageView", iv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [cell.contentView addSubview:iv];
    }
    
    UIImage *img = [UIImage imageNamed:_brushNames[indexPath.row]];
    iv.image = img;
    
    if (cell.selected) {
        [self setCellSelected:cell];
    } else if (_initialCellSelectedIndex == indexPath.row) {
        cell.selected = YES;
        [self setCellSelected:cell];
    } else {
        [self setCellDeselected:cell];
    }
    
    return cell;
}

@end
