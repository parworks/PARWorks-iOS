//
//  ARAugmentedPhotoVC.m
//  ARCore
//
//  Created by Demetri Miller on 5/3/13.
//  Copyright (c) 2013 PARWorks. All rights reserved.
//

#import "ARAugmentedPhoto.h"
#import "ARAugmentedPhotoVC.h"
#import "ARAugmentedView.h"
#import "MBProgressHUD.h"
#import "NSBundle+ARCoreResources.h"
#import "UIViewAdditions.h"

@implementation ARAugmentedPhotoVC
{
    BOOL _isFirstLoad;
    NSTimeInterval _controllerLoadedTimestamp;
}


#pragma mark - Lifecycle
- (id)initWithSite:(id<ARAugmentedPhotoSource>)site imageToAugment:(UIImage *)image metadataToAugment:(NSDictionary*)metadata waitingImageContents:(id)contents
{
    self = [super initWithNibName:nil bundle:[NSBundle arCoreResourcesBundle]];
    if (self) {
        _isFirstLoad = YES;
        _site = site;
        _imageToAugment = image;
        _imageMetadataToAugment = metadata;
        _waitingImageContents = contents;
        NSLog(@"Showing image with size %@", NSStringFromCGSize(image.size));
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _controllerLoadedTimestamp = [[NSDate date] timeIntervalSinceReferenceDate];
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    _progressHUD.labelText = @"Augmenting";
    _progressHUD.square = YES;
    
    if (_waitingImageContents) {
        _takenBlackLayer = [CALayer layer];

        _takenBlackLayer.backgroundColor = [UIColor blackColor].CGColor;
        _takenBlackLayer.opacity = 1.0;
        [self.view.layer addSublayer: _takenBlackLayer];
        
        _takenPhotoLayer = [CALayer layer];
        _takenPhotoLayer.contentsGravity = kCAGravityResizeAspect;
        _takenPhotoLayer.opacity = 1.0;
        _takenPhotoLayer.contents = _waitingImageContents;
        [self.view.layer addSublayer:_takenPhotoLayer];
    }
    
    // Augmented view that will show the augmented results in this view.
    _augmentedView = [[ARAugmentedView alloc] initWithFrame:self.view.bounds];
    _augmentedView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _augmentedView.alpha = 0.0;
    _augmentedView.backgroundColor = [UIColor clearColor];
    _augmentedView.shouldAnimateViewLayout = YES;
    [self.view addSubview:_augmentedView];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(handleBackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _progressHUD.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    _backButton.frame = CGRectMake(15, 10, 60, 30);
    
    if ([self imageNeedsAugmentation]) {
        [self setAugmentedPhoto:[_site augmentImage:_imageToAugment withMetadata:_imageMetadataToAugment]];
    }

    [self showAugmentingInterface];
    
    [CATransaction begin]; {
        [CATransaction setDisableActions:YES];
        // Setting the frame twice because that's how it was being done in GRCameraOverlay
        // and I'm not sure why...
        _augmentedView.frame = self.view.bounds;
        _augmentedView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        _augmentedView.frame = self.view.bounds;
        
        _takenBlackLayer.frame = self.view.bounds;
        _takenPhotoLayer.frame = self.view.bounds;
    } [CATransaction commit];
    
    [_augmentedView setViewLayoutAnimationDuration:0.0];
    [_augmentedView setBounds:self.view.bounds];
}


#pragma mark - Interaction

- (void)handleBackButtonTapped
{
    BOOL isPad = fmaxf([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) > 1000;
    [self dismissViewControllerAnimated:!isPad completion:nil];
}

- (void)handleAugmentedPhotoReturnedNoOverlays
{
    [[[UIAlertView alloc] initWithTitle:@"Nothing Found" message:@"Sorry, no overlays were found in your photo." delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil] show];
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (void)showAugmentingInterface
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackButtonTapped)];
        [self.view addGestureRecognizer:_tap];
        
        [_progressHUD show:YES];
        [self.view addSubview:_progressHUD];
    });
}

- (void)hideAugmentingInterface
{
    [self.view removeGestureRecognizer:_tap];
    [_progressHUD hide:YES];
}


#pragma mark - Rotation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_augmentedView setViewLayoutAnimationDuration:duration];
//    [_augmentedView setBounds:self.view.bounds];
    
    _progressHUD.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    _takenPhotoLayer.bounds = self.view.bounds;
    _takenBlackLayer.bounds = self.view.bounds;
}


#pragma mark - Augmentation
- (BOOL)imageNeedsAugmentation
{
    return YES;
}

- (void)imageAugmentationStatusChanged:(NSNotification*)notif
{
    if (_augmentedPhoto == nil) {
        return;
    }
    
    if (_augmentedPhoto.response == BackendResponseFinished) {
        NSTimeInterval timeSinceStart = [NSDate timeIntervalSinceReferenceDate] - _controllerLoadedTimestamp;
        if (timeSinceStart < 3.5) {
            double delayInSeconds = 3.5 - timeSinceStart;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self imageAugmentationStatusChanged:notif];
            });
            return;
        }
        
        if ([[_augmentedPhoto overlays] count] == 0) {
            [self handleAugmentedPhotoReturnedNoOverlays];
            return;

        } else {
            _takenPhotoLayer.opacity = 0.0;
            [_progressHUD hide:YES];
            
            [self setAugmentedPhoto: _augmentedPhoto];
        }
        
    } else if (_augmentedPhoto.response == BackendResponseFailed){
        // Show an alert view that will dismiss this view controller when it is dismissed
        [[[UIAlertView alloc] initWithTitle:@"Oops!"
                                                     message:@"Sorry, we couldn't augment your photo."
                                                    delegate:nil
                                           cancelButtonTitle:@"Try again"
                                           otherButtonTitles:nil] show];
        [self dismissViewControllerAnimated:YES completion:NULL];
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
        [self.view removeGestureRecognizer: _tap];
        [self.view bringSubviewToFront: _augmentedView];
        [self.view bringSubviewToFront: _backButton];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageAugmentationStatusChanged:) name:NOTIF_AUGMENTED_PHOTO_UPDATED object:_augmentedPhoto];
}



@end
