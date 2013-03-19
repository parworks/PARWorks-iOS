//
//  ARSiteImagesViewController.h
//  PAR Works iOS SDK
//
//  Copyright 2013 PAR Works, Inc.
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
#import "ARSite.h"
#import "GridView.h"
#import "PointCloudView.h"
#import "GRCameraOverlayView.h"

#define PICKER_ORIGIN_TRY_IT    0
#define PICKER_ORIGIN_BASE      1

@class ARSiteImagesInfoView;

@interface ARSiteImagesViewController : UIViewController <GRCameraOverlayViewDelegate, GridViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImagePickerController * _picker;
    int                       _pickerOrigin;
    BOOL    _imageIsSiteImage;
    PointCloudView * _pointCloudView;
}

@property (strong, nonatomic) ARSite * site;
@property (weak, nonatomic) IBOutlet UILabel *pointCloudLabel;
@property (weak, nonatomic) IBOutlet ARSiteImagesInfoView *infoView;
@property (weak, nonatomic) IBOutlet GridView *gridView;
@property (weak, nonatomic) IBOutlet UIButton *cameraCaptureButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraDoneButton;
@property (strong, nonatomic) IBOutlet UIView *cameraOverlayView;
@property (strong, nonatomic) IBOutlet GRCameraOverlayView *cameraOverlayAugmentView;

- (id)initWithSite:(ARSite*)s;

- (BOOL)isLoadingForGridView:(GridView*)gv;
- (NSArray*)objectCollectionForGridView:(GridView*)gv;
- (void)object:(id)obj selectedInGridView:(GridView*)gv;

- (IBAction)addBasePhotos:(id)sender;
- (IBAction)augmentPhoto:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)doneTakingPictures:(id)sender;

/// InfoView Button Actions
- (IBAction)processImagesButtonTapped:(id)sender;
- (IBAction)addOverlayButtonTapped:(id)sender;

@end
