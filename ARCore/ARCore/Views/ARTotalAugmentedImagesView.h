//
//  ARTotalAugmentedImagesView.h
//  ARCore
//
//  Created by Demetri Miller on 2/5/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARTotalAugmentedImagesView : UIView
{
    UILabel *_countLabel;
    UIImageView *_cameraIconView;
}

@property(nonatomic, assign) NSInteger count;

@end
