//
//  GRViewController.m
//  Graffiti
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


#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>

#import "ARLoadingView.h"
#import "ASIHTTPRequest.h"
#import "AROverlayView+Animations.h"
#import "UIViewAdditions.h"
#import "UIImageView+AnimationAdditions.h"
#import "DMColorPickerView.h"
#import "GRAppDelegate.h"
#import "GRBrushPickerFolderView.h"
#import "GRColorPickerFolderView.h"
#import "GRFolderButton.h"
#import "GRGraffitiLoadingView.h"
#import "GRGraffitiView.h"
#import "GRViewController.h"
#import "GRGraffitiCameraOverlayView.h"


#import "PARWorks.h"
#import "SimplePaintView.h"
#import "UIView+Layout.h"

#define CAMERA_TRANSFORM_SCALE 1.25
#define kOverlayGraffitiViewKey @"kOverlayGraffitiViewKey"

@implementation GRViewController
{
    ARAugmentedPhoto *_curAugmentedPhoto;
}
#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _firstLoad = YES;
    _graffitiViews = [[NSMutableArray alloc] init];
    
    [brushSizeSlider setTransform: CGAffineTransformMakeRotation(M_PI / 2)];
    [brushSizeSlider setMinimumValue: 10];
    [brushSizeSlider setMaximumValue: 64];
    [self disablePaintControlsWithGraffitiView:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.presentedViewController isKindOfClass:[UIImagePickerController class]] &&
        [_cameraOverlayView augmentedPhoto] && [[_cameraOverlayView augmentedPhoto] response] == BackendResponseFinished &&
        [[[_cameraOverlayView augmentedPhoto] overlays] count] > 0) {
        augmentedView.overlayImageView.image = nil;
        [augmentedView.outlineViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [augmentedView.overlayViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [augmentedView.overlayTitleViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        [augmentedView.loadingView startAnimating];
        _curAugmentedPhoto = [_cameraOverlayView augmentedPhoto];
        [_loadingView startAnimating];

        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (_curAugmentedPhoto.response == BackendResponseFinished) {
                augmentedView.augmentedPhoto = _curAugmentedPhoto;
                [self augmentProcessFinishedWithPhoto:_curAugmentedPhoto];
            }
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_firstLoad) {
        _firstLoad = NO;

        _loadingView = [[GRGraffitiLoadingView alloc] initWithFrame:self.view.bounds];
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_loadingView];
        
        _folderDimView = [[UIControl alloc] initWithFrame:self.view.bounds];
        _folderDimView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _folderDimView.backgroundColor = [UIColor clearColor];
        _folderDimView.alpha = 0.0;
        [_folderDimView addTarget:self action:@selector(handleFolderDimViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_folderDimView];
        
        CGRect folderFrame = CGRectMake(self.view.bounds.size.width, 0, 360, self.view.bounds.size.height);
        _colorPicker = [[GRColorPickerFolderView alloc] initWithButtonOffsetY:20 image:[UIImage imageNamed:@"color_picker_icon.png"] frame:folderFrame];
        [_colorPicker.folderButton addTarget:self action:@selector(handleColorPickerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_colorPicker];
        
        _brushPicker = [[GRBrushPickerFolderView alloc] initWithButtonOffsetY:75 image:[UIImage imageNamed:@"brush_icon.png"] frame:folderFrame];
        [_brushPicker.folderButton addTarget:self action:@selector(handleBrushPickerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_brushPicker];
            
        cameraButton.layer.contentsScale = [UIScreen mainScreen].scale;
        cameraButton.layer.shadowColor = [UIColor blackColor].CGColor;
        cameraButton.layer.shadowOffset = CGSizeZero;
        cameraButton.layer.shadowRadius = 4.0;
        cameraButton.layer.shadowOpacity = 1.0;
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showCameraPicker];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return YES;
}


#pragma mark - Rotation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}


#pragma mark - Presentation
- (void)showCameraPicker
{
    NSString * sitename = [[NSUserDefaults standardUserDefaults] objectForKey: SITENAME_KEY];
    _site = [[ARSite alloc] initWithIdentifier: sitename];
    _cameraOverlayView = [[GRGraffitiCameraOverlayView alloc] initWithFrame:self.view.bounds];
    _cameraOverlayView.site = _site;
    
    UIImagePickerController *picker = [self imagePicker];
    picker.delegate = _cameraOverlayView;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        picker.cameraOverlayView = _cameraOverlayView;
        _cameraOverlayView.imagePicker = picker;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (UIImagePickerController *)imagePicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = @[(NSString *) kUTTypeImage];
        picker.showsCameraControls = NO;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    return picker;
}


#pragma mark - User Interaction
- (IBAction)handleColorPickerButtonTapped:(id)sender
{
    if (_colorPicker.isShowing) {
        [_colorPicker hideInParent:self.view animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            [_brushPicker shiftFrame:CGPointMake(-50, 0)];
        }];
        _folderDimView.alpha = 0.0;
    } else {
        [_colorPicker showInParent:self.view animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            [_brushPicker shiftFrame:CGPointMake(50, 0)];
        }];
        _folderDimView.alpha = 1.0;
    }
    _focusedGraffitiView.backgroundView.strokeColor = _colorPicker.picker.currentColor;
}

- (IBAction)handleBrushPickerButtonTapped:(id)sender
{
    if (_brushPicker.isShowing) {
        [_brushPicker hideInParent:self.view animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            [_colorPicker shiftFrame:CGPointMake(50, 0)];
        }];
        _folderDimView.alpha = 0.0;
    } else {
        [_brushPicker showInParent:self.view animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            [_colorPicker shiftFrame:CGPointMake(-50, 0)];
        }];
        _folderDimView.alpha = 1.0;
    }
    _focusedGraffitiView.backgroundView.brushName = _brushPicker.currentBrushName;
    _focusedGraffitiView.backgroundView.brushSize = _brushPicker.brushSizeSlider.value;
}

- (IBAction)handleCameraButtonTapped:(id)sender
{
    [self showCameraPicker];
}

- (void)handleFolderDimViewTapped:(id)sender
{
    if (_colorPicker.isShowing) {
        [self handleColorPickerButtonTapped:nil];
    }
    
    if (_brushPicker.isShowing) {
        [self handleBrushPickerButtonTapped:nil];
    }
    
    _folderDimView.alpha = 0.0;
}


#pragma mark - Animations
- (void)augmentProcessStarted
{
    [_loadingView startAnimating];    
}

- (void)augmentProcessFinishedWithPhoto:(ARAugmentedPhoto *)photo
{
    // remove the loading view
    [_loadingView stopAnimating];
    
    GRAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    if (photo.overlays.count == 0)
        return;
    
    for (AROverlay *overlay in photo.overlays) {
        GRGraffitiView *view = objc_getAssociatedObject(overlay, kOverlayGraffitiViewKey);
        [delegate getGraffitiForOverlay:overlay withCompletionBlock:^(UIImage *image) {
            [view.backgroundView setImage:image];
            [view.backgroundView setNeedsDisplay];
            [view setController: self];
            [view revealWithRandomType];
        }];     
    }
}


- (void)enablePaintControlsWithGraffitiView:(GRGraffitiView *)view
{
    _focusedGraffitiView = view;
    _focusedGraffitiView.backgroundView.brushSize = _brushPicker.brushSizeSlider.value;
    _focusedGraffitiView.backgroundView.brushName = _brushPicker.currentBrushName;
    _focusedGraffitiView.backgroundView.strokeColor = _colorPicker.picker.currentColor;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [_colorPicker shiftFrame:CGPointMake(-50, 0)];
    [_brushPicker shiftFrame: CGPointMake(-50, 0)];
    [UIView commitAnimations];
}

- (void)disablePaintControlsWithGraffitiView:(GRGraffitiView *)view
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [_colorPicker shiftFrame:CGPointMake(50, 0)];
    [_brushPicker shiftFrame: CGPointMake(50, 0)];
    [UIView commitAnimations];
    _focusedGraffitiView = nil;
}


#pragma mark - AROverlayViewAnimationDelegate
- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    GRViewController * __weak weakSelf = self;
    GRGraffitiView *gv = (GRGraffitiView *)overlayView;
    [overlayView animateBounceFocusWithParent:parent centeredBlock:nil complete:^{
        gv.backgroundView.userInteractionEnabled = YES;
        [weakSelf enablePaintControlsWithGraffitiView:gv];
    }];
}

- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    GRViewController * __weak weakSelf = self;
    GRGraffitiView * gv = (GRGraffitiView *)overlayView;

    [overlayView animateBounceUnfocusWithParent:parent uncenteredBlock:nil complete:^{
        gv.backgroundView.userInteractionEnabled = NO;
        
        GRAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        UIImage * img = [gv.backgroundView getImage];
        [delegate saveGraffiti:img forOverlay: overlayView.overlay];

        [weakSelf disablePaintControlsWithGraffitiView:gv];
    }];
}


#pragma mark - ARAugmentedViewDelegate
- (AROverlayView *)overlayViewForOverlay:(AROverlay *)overlay
{
    GRGraffitiView *graffitiView = [[GRGraffitiView alloc] initWithOverlay:overlay];
    graffitiView.animDelegate = self;
    SimplePaintView *paintView = [graffitiView backgroundView];
    paintView.brushSize = _brushPicker.brushSizeSlider.value;
    paintView.brushName = _brushPicker.currentBrushName;
    paintView.strokeColor = _colorPicker.picker.currentColor;
    objc_setAssociatedObject(overlay, kOverlayGraffitiViewKey, graffitiView, OBJC_ASSOCIATION_ASSIGN);
    return graffitiView;
}


#pragma mark - GRColorPickerDelegate
- (void)didPickColor:(UIColor *)color
{
    _focusedGraffitiView.backgroundView.strokeColor = color;
}

@end