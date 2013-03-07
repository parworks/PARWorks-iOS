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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self resetToLiveCameraInterface];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)setAugmentedPhoto:(ARAugmentedPhoto *)augmentedPhoto
{
    _augmentedPhoto = augmentedPhoto;
    
    if (_augmentedPhoto.response == BackendResponseFinished) {
        [_augmentedView setAugmentedPhoto: _augmentedPhoto];
        _augmentedView.alpha = 1;
        [self removeGestureRecognizer: _tap];
        [self bringSubviewToFront: _augmentedView];
        [self bringSubviewToFront: self.toolbar];
        [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageAugmentationStatusChanged:) name:NOTIF_AUGMENTED_PHOTO_UPDATED object:_augmentedPhoto];
}

- (ARAugmentedPhoto *)augmentedPhoto
{
    return _augmentedPhoto;
}

@end
