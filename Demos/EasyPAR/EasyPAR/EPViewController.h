//
//  EPViewController.h
//  EasyPAR
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
#import "GRCameraOverlayView.h"
#import "ARAugmentedView.h"

@interface EPViewController : UIViewController <UIAlertViewDelegate,ARAugmentedViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    GRCameraOverlayView         * _cameraOverlayView;
    CATextLayer                 * _loadingLayer;
    
    UIImage                     * _image;
    UIImageView                 * _shrinking;
    CALayer                     * _shrinkingMask;
    UIImageView                 * _scanline;
    BOOL                          _scanlineAnimationRunning;
    BOOL                          _augmentCompleteAnimationRunning;
    
    NSMutableArray              * _layers;
    UIImagePickerController     * _picker;
    
    BOOL                        _firstLoad;
    BOOL                        _selectedSite;
    
    ARSite                      * _site;
    ARAugmentedPhoto            * _augmentedPhoto;
    __weak IBOutlet ARAugmentedView *_augmentedView;
    __weak IBOutlet UIView          *_toolbarContainer;
    __weak IBOutlet UIButton        *_cameraButton;
    __weak IBOutlet UIButton        *_libraryButton;
    __weak IBOutlet UIButton        *_settingButton;
}

- (void)translateLayers:(float)baseSpeed;

- (IBAction)showCameraPicker:(id)sender;
- (IBAction)showLibraryPicker:(id)sender;
- (IBAction)selectSite:(id)sender;

@end
