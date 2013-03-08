//
//  GRGraffitiCameraOverlayView.m
//  Graffiti
//
//  Created by Demetri Miller on 3/6/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "ARAugmentedPhoto.h"
#import "ARAugmentedView.h"
#import "GRCameraOverlayToolbar.h"
#import "GRGraffitiCameraOverlayView.h"

@implementation GRGraffitiCameraOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)cancelButtonTapped:(id)sender
{
    [self resetToLiveCameraInterface];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self resetToLiveCameraInterface];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)setAugmentedPhoto:(ARAugmentedPhoto *)augmentedPhoto
{
    [super setAugmentedPhoto:augmentedPhoto];
    
    if (self.augmentedPhoto.response == BackendResponseFinished) {
        [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
