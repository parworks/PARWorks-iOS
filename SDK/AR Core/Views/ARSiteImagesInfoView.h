//
//  ARSiteImagesInfoView.h
//  PARWorks iOS
//
//  Created by Demetri Miller on 12/8/12.
//  Copyright (c) 2012 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSite.h"

@class ARSiteImagesInfoViewButton;

@interface ARSiteImagesInfoView : UIView

@property(nonatomic, weak) IBOutlet UILabel *stepLabel;
@property(nonatomic, weak) IBOutlet UILabel *directionsLabel;

@property(nonatomic, weak) IBOutlet ARSiteImagesInfoViewButton *addBaseImageButton;
@property(nonatomic, weak) IBOutlet ARSiteImagesInfoViewButton *processBaseImageButton;
@property(nonatomic, weak) IBOutlet ARSiteImagesInfoViewButton *addOverlayButton;

@property(nonatomic, assign) ARSiteStatus siteStatus;

@end


@interface ARSiteImagesInfoViewButton : UIButton

@end