//
//  ARViewController.h
//  PARWorks iOS SDK
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
#import "ARAugmentedPhoto.h"
#import "ARAugmentedView.h"
#import "AROverlayAnimation.h"

/** This test view controller is demo used for testing the integration of
 my sample photo augmentation project into the stuff Ben has been working on.
 
 Implementation starts from point that the device has received a response
 from the server and we have an image along with augmentation data. That data
 is then molded into the right format at passed to our augmentation view 
 which handles presentation.
 */
@interface ARPhotoViewController : UIViewController <ARAugmentedViewDelegate>

@property (nonatomic, strong) IBOutlet ARAugmentedView * photoView;
@property (nonatomic, strong) ARAugmentedPhoto * photo;
@property (nonatomic, strong) AROverlayAnimation *overlayAnimation;
- (id)initWithAugmentedPhoto:(ARAugmentedPhoto*)p;

@end
