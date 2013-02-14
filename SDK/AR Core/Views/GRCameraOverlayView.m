//
//  GRGraffitiCameraOverlayView.m
//  Graffiti
//
//  Created by Demetri Miller on 11/4/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "ARAugmentedPhoto.h"
#import "ARAugmentedView.h"
#import "ARSite.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImage.h"
#import "GRCameraOverlayToolbar.h"
#import "GRCameraOverlayView.h"
#import "MBProgressHUD.h"
#import "UIImageAdditions.h"
#import "UIViewAdditions.h"
#import "UIViewController+Transitions.h"

#define kDefaultsGRCameraFlashModeKey @"kDefaultsGRCameraFlashModeKey"

@implementation GRCameraOverlayView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame
{
    // The overlayView should always be the same frame as the UIWindow.
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    self = [super initWithFrame:window.frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.userInteractionEnabled = YES;
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:self];
    _progressHUD.labelText = @"Augmenting";
	_progressHUD.detailsLabelText = @"Tap to cancel";
	_progressHUD.square = YES;
    
    
    // Camera controls
    self.toolbar = [GRCameraOverlayToolbar toolbarFromXIBWithParent:self];
    [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_toolbar setFrameY:(self.frame.size.height - _toolbar.frame.size.height)];
    [_toolbar.cameraButton addTarget:self action:@selector(cameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar.flashButton addTarget:self action:@selector(flashButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_toolbar];
        
    // Image view we'll be using for showing the taken photo.
    _takenPhotoLayer = [CALayer layer];
    _takenPhotoLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _takenPhotoLayer.backgroundColor = [UIColor blackColor].CGColor;
    _takenPhotoLayer.contentsGravity = kCAGravityResizeAspectFill;
    _takenPhotoLayer.opacity = 0.0;
    [self.layer addSublayer:_takenPhotoLayer];
    
    // Augmented view that will show the augmented results in this view.
    _augmentedView = [[ARAugmentedView alloc] initWithFrame:self.bounds];
    _augmentedView.alpha = 0.0;
    [self addSubview:_augmentedView];
    
       
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self handleOrientationChange:nil];
//    [self layoutAugmentButtonForCurrentFrame];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout
- (void)handleOrientationChange:(NSNotification *)note
{
    UIInterfaceOrientation orientation = [UIDevice currentDevice].orientation;
    // Default orientation for the camera overlay is portrait...

    CGFloat rotateAngle;
    CGRect frame;
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            break;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform t = CGAffineTransformMakeRotation(rotateAngle);
        _toolbar.cameraIcon.transform = t;
        _toolbar.flashButton.transform = t;
        _toolbar.cancelButton.transform = t;
        _progressHUD.transform = t;
        _takenPhotoLayer.transform = CATransform3DMakeAffineTransform(t);
        _takenPhotoLayer.bounds = UIInterfaceOrientationIsPortrait(orientation) ? CGRectMake(0, 0, 320, 480) : CGRectMake(0, 0, 480, 320);
    }];
}


#pragma mark - Convenience
- (void)showAugmentingInterface
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAugmenting)];
        [self addGestureRecognizer:_tap];
        
        [_progressHUD show:YES];
        [self addSubview:_progressHUD];
    });
}

- (void)resetToLiveCameraInterface
{
    [self removeGestureRecognizer:_tap];
    [_progressHUD hide:YES];

    _takenPhotoLayer.opacity = 0.0;
    _augmentedView.alpha = 0.0;
    _takenPhotoLayer.contents = nil;    
}

- (void)updateLayer:(CALayer *)layer withBlurredImageWhenReady:(UIImage *)image
{
    GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:[image scaledImage:0.15] smoothlyScaleOutput: NO];
    GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    
    [blurFilter setBlurSize: 0.35];
    [picture addTarget: blurFilter];
    [blurFilter addTarget: brightnessFilter];
    [brightnessFilter setBrightness: -0.3];
    
    [picture processImage];
    
    UIImage *result = [brightnessFilter imageFromCurrentlyProcessedOutput];
    [CATransaction begin];
    [CATransaction setAnimationDuration:2.0];
    layer.contents = (id)result.CGImage;
    [CATransaction commit];
}

#pragma mark - User Interaction
- (void)cameraButtonTapped:(id)sender
{
    [self showAugmentingInterface];
    [_imagePicker takePicture];
}

- (void)cancelAugmenting
{
    [self resetToLiveCameraInterface];
}

- (void)cancelButtonTapped:(id)sender
{
    [self resetToLiveCameraInterface];
    [_imagePicker unpeelViewController];
}

- (void)flashButtonTapped:(id)sender
{
    UIImagePickerControllerCameraFlashMode mode = [self flashModeFromDefaults];
    switch (mode) {
        case UIImagePickerControllerCameraFlashModeAuto:
            mode = UIImagePickerControllerCameraFlashModeOn;
            break;
        case UIImagePickerControllerCameraFlashModeOff:
            mode = UIImagePickerControllerCameraFlashModeAuto;
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            mode = UIImagePickerControllerCameraFlashModeOff;
            break;
        default:
            break;
    }
    
    _imagePicker.cameraFlashMode = mode;
    [self setFlashModeInDefaults:mode];
    [_toolbar updateFlashImageForFlashMode:mode withParent:self];
}


#pragma mark - Getters/Setters
- (void)setImagePicker:(UIImagePickerController *)imagePicker
{
    _imagePicker = imagePicker;
    imagePicker.cameraFlashMode = [self flashModeFromDefaults];
}

- (UIImagePickerControllerCameraFlashMode)flashModeFromDefaults
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kDefaultsGRCameraFlashModeKey];
}

- (void)setFlashModeInDefaults:(UIImagePickerControllerCameraFlashMode)flashMode
{
    [[NSUserDefaults standardUserDefaults] setInteger:flashMode forKey:kDefaultsGRCameraFlashModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _pickerFinishedTimestamp = [NSDate timeIntervalSinceReferenceDate];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize viewportSize = _imagePicker.view.bounds.size;
    CGSize originalSize = [originalImage size];
    
    // Downsize the image
    UIGraphicsBeginImageContextWithOptions(viewportSize, YES, 1);
    float scale = fminf(viewportSize.width / originalSize.width, viewportSize.height / originalSize.height);
    CGSize resizedSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    CGRect resizedFrame = CGRectMake((viewportSize.width - resizedSize.width) / 2, (viewportSize.height - resizedSize.height) / 2 - 20, resizedSize.width, resizedSize.height);
    [originalImage drawInRect:resizedFrame];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _takenPhotoLayer.contents = (id)resizedImage.CGImage;
    _takenPhotoLayer.opacity = 1.0;
    [CATransaction commit];

    [self.layer insertSublayer:_takenPhotoLayer below:_toolbar.layer];
    [self bringSubviewToFront:_toolbar];
    [self bringSubviewToFront:_progressHUD];

    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self updateLayer:_takenPhotoLayer withBlurredImageWhenReady:resizedImage];
    });

    // Upload the original image to the AR API for processing. We'll animate the
    // resized image back on screen once it's finished.
    [self setAugmentedPhoto:[_site augmentImage:resizedImage]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self resetToLiveCameraInterface];
    [_imagePicker unpeelViewController];
}

- (void)imageAugmented:(NSNotification*)notif
{
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval diff = time - _pickerFinishedTimestamp;
    if (diff < 4) {
        double delayInSeconds = 4 - diff;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self imageAugmented:notif];
        });
        return;
    }
    
    _takenPhotoLayer.opacity = 0.0;
    [_progressHUD hide:YES];
    
    if (_augmentedPhoto.response == BackendResponseFinished) {
        if ([[_augmentedPhoto overlays] count] == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"We weren't able to find any overlays in that image. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [self resetToLiveCameraInterface];
            return;
        }
        
        [self setAugmentedPhoto: _augmentedPhoto];
        
    } else if (_augmentedPhoto.response == BackendResponseFailed){
        [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"The PAR Works API server did not successfully augment the photo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self resetToLiveCameraInterface];
        
    } else {
        // just wait...
    }
}

- (void)setAugmentedPhoto:(ARAugmentedPhoto *)augmentedPhoto
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name:NOTIF_AUGMENTED_PHOTO_UPDATED object:nil];
    _augmentedPhoto = augmentedPhoto;
    
    if (_augmentedPhoto.response == BackendResponseFinished) {
        [_augmentedView setAugmentedPhoto: _augmentedPhoto];
        _augmentedView.transform = CGAffineTransformIdentity;
        _augmentedView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self bringSubviewToFront: _augmentedView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageAugmented:) name:NOTIF_AUGMENTED_PHOTO_UPDATED object:_augmentedPhoto];
}

@end
