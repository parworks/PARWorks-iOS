//
//  GRGraffitiCameraOverlayView.m
//  Graffiti
//
//  Created by Demetri Miller on 11/4/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "ARAugmentedPhoto.h"
#import "ARAugmentedView.h"
#import "ARCameraOverlayTooltip.h"
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
#define IOS_CAMERA_ASPECT_RATIO 4.0/3.0

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
    UIWindow *w = [[UIApplication sharedApplication] windows][0];
    _isiPhone5 = w.bounds.size.height > 480;

    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.userInteractionEnabled = YES;
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:self];
    _progressHUD.labelText = @"Augmenting";
	_progressHUD.detailsLabelText = @"Tap to cancel";
	_progressHUD.square = YES;
    
    // Image view we'll be using for showing the taken photo.
    _takenBlackLayer = [CALayer layer];
    _takenBlackLayer.backgroundColor = [UIColor blackColor].CGColor;
    _takenBlackLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _takenBlackLayer.opacity = 0.0;
    [self.layer addSublayer: _takenBlackLayer];
    
    // Camera controls
    self.toolbar = [GRCameraOverlayToolbar toolbarFromXIBWithParent:self];
    [_toolbar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_toolbar setFrameY:(self.frame.size.height - _toolbar.frame.size.height)];
    [_toolbar.cameraButton addTarget:self action:@selector(cameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar.flashButton addTarget:self action:@selector(flashButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_toolbar];
    
    CGRect cameraArea = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width * IOS_CAMERA_ASPECT_RATIO);

    // on the iphone 5, the best we can do is center the damn thing...
    if (_isiPhone5)
        cameraArea.origin.y += 23;
    
    _takenPhotoLayer = [CALayer layer];
    _takenPhotoLayer.frame = cameraArea;
    _takenPhotoLayer.contentsGravity = kCAGravityResizeAspect;
    _takenPhotoLayer.opacity = 0.0;
    [self.layer addSublayer:_takenPhotoLayer];
    
    // Tooltip that appears to animate from the toolbar
    self.tooltip = [[ARCameraOverlayTooltip alloc] initWithFrame:CGRectMake(0, 0, 250, 60)];
    _tooltip.center = CGPointMake(self.bounds.size.width/2, _toolbar.frame.origin.y - _tooltip.frame.size.height + 10);
    _tooltip.label.text = @"This is some tooltip text";
    _tooltip.label.adjustsFontSizeToFitWidth = YES;
    _tooltip.label.textAlignment = NSTextAlignmentCenter;
    _tooltip.alpha = 0.0;
    [self addSubview:_tooltip];
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSString *name = (_site.name && (_site.name.length > 0)) ? _site.name : @"the site";
        [self showTooltipWithString: [NSString stringWithFormat: @"Take a picture of %@ to see overlays!", name]];
    });
    
    // Augmented view that will show the augmented results in this view.
    _augmentedView = [[ARAugmentedView alloc] initWithFrame:self.bounds];
    _augmentedView.frame = cameraArea;
    _augmentedView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    _augmentedView.frame = cameraArea;
    _augmentedView.alpha = 0.0;
    _augmentedView.backgroundColor = [UIColor blackColor];
    [self addSubview:_augmentedView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayoutForCurrentOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self relayoutForCurrentOrientation:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout
- (void)relayoutForCurrentOrientation:(NSNotification *)note
{
    UIInterfaceOrientation orientation = [UIDevice currentDevice].orientation;
    // Default orientation for the camera overlay is portrait...

    CGFloat rotateAngle;
    CGFloat tooltipTranslateOffset;
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            tooltipTranslateOffset = 0;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            tooltipTranslateOffset = 95;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            tooltipTranslateOffset = -95;
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            tooltipTranslateOffset = 0;
            break;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform t = CGAffineTransformMakeRotation(rotateAngle);
        
        UIWindow *mainWindow = [[UIApplication sharedApplication] windows][0];
        if (mainWindow.bounds.size.height > 480) {
            _toolbar.cameraButton.transform = t;
        } else {
            _toolbar.cameraIcon.transform = t;
        }

        _toolbar.flashButton.transform = t;
        _toolbar.cancelButton.transform = t;
        _progressHUD.transform = t;
        _takenPhotoLayer.transform = CATransform3DMakeAffineTransform(t);
        _augmentedView.layer.transform = CATransform3DMakeAffineTransform(t);

        // In addition to the rotation, we also need to translate the tooltip so it doesn't
        // overlay the toolbar.
        _tooltip.transform = CGAffineTransformTranslate(t, tooltipTranslateOffset, 0);
        [_tooltip updateArrowLocationForInterfaceOrientation:orientation];
        
        float shortSide = self.bounds.size.width;
        float longSide = shortSide * IOS_CAMERA_ASPECT_RATIO;
        float longSidePadding = 0;
        
        if (_isiPhone5)
            longSidePadding = 23;
        
        // we check for landscape, not portrait because there is also face up, face down, etc... and we want
        // to handle those as portrait and not as landscape.
        _takenPhotoLayer.bounds = UIInterfaceOrientationIsLandscape(orientation) ? CGRectMake(longSidePadding, 0, longSide, shortSide) : CGRectMake(0, longSidePadding, shortSide, longSide);
        _augmentedView.bounds = UIInterfaceOrientationIsLandscape(orientation) ? CGRectMake(longSidePadding, 0, longSide, shortSide) : CGRectMake(0, longSidePadding, shortSide, longSide);
    }];
}

- (void)showTooltipWithString:(NSString *)string
{
    _tooltip.label.text = string;
    
    CGAffineTransform origTransform = _tooltip.transform;
    CGAffineTransform startTransform = CGAffineTransformScale(origTransform, 0.5, 0.5);
    CGAffineTransform secondTransform = CGAffineTransformScale(origTransform, 1.2, 1.2);
    CGAffineTransform thirdTransform = CGAffineTransformScale(origTransform, 0.9, 0.9);
    
    _tooltip.transform = startTransform;
    [UIView animateWithDuration:0.2 animations:^{
        _tooltip.transform = secondTransform;
        _tooltip.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _tooltip.transform = thirdTransform;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                _tooltip.transform = origTransform;
            }];
        }];
    }];
    
    // show for 1 second + 1 second per 4 words
    double delayInSeconds = 0.8 + [[string componentsSeparatedByString:@" "] count] * 0.32;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CGAffineTransform t = _tooltip.transform;
        [UIView animateWithDuration:0.2 animations:^{
            _tooltip.alpha = 0.0;
            _tooltip.transform = CGAffineTransformScale(_tooltip.transform, 0.5, 0.5);
        } completion:^(BOOL finished) {
            _tooltip.transform = t;
        }];
    });
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
        [self relayoutForCurrentOrientation: nil];
        [self addSubview:_progressHUD];
    });
}

- (void)resetToLiveCameraInterface
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name:NOTIF_AUGMENTED_PHOTO_UPDATED object:nil];
    [self removeGestureRecognizer:_tap];
    [_progressHUD hide:YES];

    [CATransaction begin];
    [CATransaction setAnimationDuration:0.4];
    _takenPhotoLayer.opacity = 0.0;
    _takenBlackLayer.opacity = 0.0;
    _augmentedView.alpha = 0.0;
    [CATransaction commit];
}

- (void)updateLayer:(CALayer *)layer withBlurredImageWhenReady:(UIImage *)image
{
    GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:[image scaledImage:0.10] smoothlyScaleOutput: NO];
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
    if (_augmentedView.alpha > 0)
        [self resetToLiveCameraInterface];
    else {
        [self showAugmentingInterface];
        [_imagePicker takePicture];
    }
}

- (void)cancelAugmenting
{
    [self resetToLiveCameraInterface];
}

- (void)cancelButtonTapped:(id)sender
{
    [self resetToLiveCameraInterface];

    [_takenBlackLayer removeFromSuperlayer];
    [self.layer insertSublayer:_takenBlackLayer above:_toolbar.layer];

    [CATransaction begin];
    [CATransaction setAnimationDuration:0.35];
    _takenBlackLayer.opacity = 0.85;
    [CATransaction commit];

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
    CGSize originalSize = [originalImage size];
    float scale;
    
    // Downsize the image to 1000px in size
    scale = fminf(1200.0 / originalSize.width, 1200.0 / originalSize.height);
    CGSize sizeFor1000 = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    UIGraphicsBeginImageContextWithOptions(sizeFor1000, YES, 1);
    [originalImage drawInRect: CGRectMake(0, 0, sizeFor1000.width, sizeFor1000.height)];
    UIImage *image1000 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
 
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _takenBlackLayer.opacity = 1.0;
    _takenPhotoLayer.contents = (id)image1000.CGImage;
    _takenPhotoLayer.opacity = 1.0;
    [CATransaction commit];

    [self.layer insertSublayer:_takenPhotoLayer below:_toolbar.layer];
    [self bringSubviewToFront:_toolbar];
    [self bringSubviewToFront:_progressHUD];

    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self updateLayer:_takenPhotoLayer withBlurredImageWhenReady:image1000];
    });

    // Upload the original image to the AR API for processing. We'll animate the
    // resized image back on screen once it's finished.
    [self setAugmentedPhoto:[_site augmentImage:image1000]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self resetToLiveCameraInterface];
    [_imagePicker unpeelViewController];
}

- (void)imageAugmentationStatusChanged:(NSNotification*)notif
{
    if (_augmentedPhoto.response == BackendResponseFinished) {
        NSTimeInterval timeSinceStart = [NSDate timeIntervalSinceReferenceDate] - _pickerFinishedTimestamp;
        if (timeSinceStart < 3.5) {
            double delayInSeconds = 3.5 - timeSinceStart;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self imageAugmentationStatusChanged:notif];
            });
            return;
        }
        
        if ([[_augmentedPhoto overlays] count] == 0) {
            [self showTooltipWithString: @"No overlays found. Make sure the object is focused and in the frame."];
            [self resetToLiveCameraInterface];
            return;
        } else {
            _takenPhotoLayer.opacity = 0.0;
            [_progressHUD hide:YES];

            [self setAugmentedPhoto: _augmentedPhoto];
        }
        
    } else if (_augmentedPhoto.response == BackendResponseFailed){
        [self resetToLiveCameraInterface];
        [self showTooltipWithString: @"Sorry, we couldn't augment your photo. Try again!"];
        
    } else {
        // just wait...
    }
}

- (void)setAugmentedPhoto:(ARAugmentedPhoto *)augmentedPhoto
{
    _augmentedPhoto = augmentedPhoto;
    
    if (_augmentedPhoto.response == BackendResponseFinished) {
        [_augmentedView setAugmentedPhoto: _augmentedPhoto];
        _augmentedView.alpha = 1;
        [self removeGestureRecognizer: _tap];
        [self bringSubviewToFront: _augmentedView];
        [self bringSubviewToFront: _toolbar];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageAugmentationStatusChanged:) name:NOTIF_AUGMENTED_PHOTO_UPDATED object:_augmentedPhoto];
}

@end
