//
//  GRHomeViewController.h
//  Graffiti
//
//  Created by Ben Gotow on 1/8/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GRCameraOverlayView;

@interface GRHomeViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)createGraffiti:(id)sender;
- (IBAction)scanForGraffiti:(id)sender;

@end
