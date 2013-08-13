//
//  ARAugmentedPhotoVC.h
//  ARCore
//
//  Created by Demetri Miller on 5/3/13.
//  Copyright (c) 2013 PARWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARAugmentedPhotoSource.h"

@class ARAugmentedPhoto;
@class ARAugmentedView;
@class MBProgressHUD;

@interface ARAugmentedPhotoVC : UIViewController <UIAlertViewDelegate>
{
    ARAugmentedView  *_augmentedView;
    
    UIImage *_imageToAugment;
    id _waitingImageContents;

    UITapGestureRecognizer  *_tap;
    MBProgressHUD           *_progressHUD;
    CALayer                 *_takenBlackLayer;
    CALayer                 *_takenPhotoLayer;
}

@property(nonatomic, strong) ARAugmentedPhoto *augmentedPhoto;
@property(nonatomic, strong) UIButton * backButton;
@property(nonatomic, strong) NSMutableArray *siteSet;
@property(nonatomic, strong) id <ARAugmentedPhotoSource> site;



/// Lifecycle
- (id)initWithSite:(id<ARAugmentedPhotoSource>)site imageToAugment:(UIImage *)image waitingImageContents:(id)contents;

- (BOOL)imageNeedsAugmentation;

@end
