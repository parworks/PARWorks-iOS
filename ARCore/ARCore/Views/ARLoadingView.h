//
//  ARLoadingView.h
//  LoadingView
//
//  Created by Ben Gotow on 2/13/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum PVLoadingViewStyle{
    ARLoadingViewStyleWhite = 0,
    ARLoadingViewStyleBlack = 1,
} ARLoadingViewStyle;

@interface ARLoadingView : UIView
{
    UIView * _block1;
    UIView * _block2;
}

@property (nonatomic) ARLoadingViewStyle loadingViewStyle;

- (void)startAnimating;
- (void)stopAnimating;

@end
