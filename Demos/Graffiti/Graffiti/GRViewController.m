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

#import "ASIHTTPRequest.h"
#import "UIViewAdditions.h"
#import "UIImageView+AnimationAdditions.h"
#import "DMColorPickerView.h"
#import "GRAppDelegate.h"
#import "GRBrushPickerFolderView.h"
#import "GRCameraOverlayView.h"
#import "GRColorPickerFolderView.h"
#import "GRFolderButton.h"
#import "GRGraffitiLoadingView.h"
#import "GRGraffitiView.h"
#import "GRViewController.h"
#import "PARWorks.h"
#import "SimplePaintView.h"
#import "UIView+Layout.h"

#define CAMERA_TRANSFORM_SCALE 1.25
#define kOverlayGraffitiViewKey @"kOverlayGraffitiViewKey"

@implementation GRViewController

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_firstLoad) {
        _loadingView = [[GRGraffitiLoadingView alloc] initWithFrame:self.view.bounds];
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_loadingView];
        
        _cameraOverlayView = [[GRCameraOverlayView alloc] initWithFrame:self.view.bounds];
        [_cameraOverlayView.augmentButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
        
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
        
        [self showCameraPicker];
        _firstLoad = NO;
    
        cameraButton.layer.contentsScale = [UIScreen mainScreen].scale;
        cameraButton.layer.shadowColor = [UIColor blackColor].CGColor;
        cameraButton.layer.shadowOffset = CGSizeZero;
        cameraButton.layer.shadowRadius = 4.0;
        cameraButton.layer.shadowOpacity = 1.0;
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (!_picker) {
            _picker = [[UIImagePickerController alloc] init];
            _picker.delegate = self;
            _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            _picker.mediaTypes = @[(NSString *) kUTTypeImage];
            _picker.cameraOverlayView = _cameraOverlayView;
            _picker.showsCameraControls = NO;
            _picker.cameraViewTransform = CGAffineTransformMakeScale(CAMERA_TRANSFORM_SCALE, CAMERA_TRANSFORM_SCALE);
        }
        [self presentViewController:_picker animated:NO completion:nil];
    
    } else {
        NSString * imgPath = [[NSBundle mainBundle] pathForResource:@"img_durham_1" ofType:@"jpg"];
        NSString * pmPath = [[NSBundle mainBundle] pathForResource:@"img_durham_1" ofType:@"pm"];
        ARAugmentedPhoto * p = [[ARAugmentedPhoto alloc] initWithImageFile: imgPath andPMFile: pmPath];
        [augmentedView setAugmentedPhoto: p];
        augmentedView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        
        [self augmentProcessStarted];
        [self performSelector:@selector(augmentProcessFinishedWithPhoto:) withObject:p afterDelay: 2];
    }
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
- (IBAction)takePicture:(id)sender
{
    [_picker takePicture];
}

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
        [delegate getGraffitiForSite:overlay.name withCompletionBlock:^(UIImage *image) {
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
    
    // save the image
    if (view) {
        GRAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        UIImage * img = [view.backgroundView getImage];
        
        AROverlay * overlay = augmentedView.augmentedPhoto.overlays[0];
        [delegate saveGraffiti:img forSite: overlay.name];
    }
    _focusedGraffitiView = nil;
}

#pragma mark - ARAugmentedViewDelegate
- (AROverlayView *)overlayViewForOverlay:(AROverlay *)overlay
{
    GRGraffitiView *graffitiView = [[GRGraffitiView alloc] initWithOverlay:overlay];
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image = [info objectForKey: UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:NO completion:^{
        // Upload the original image to the AR API for processing. We'll animate the
        // resized image back on screen once it's finished.
        [self augmentProcessStarted];
        ARAugmentedPhoto * p = [[ARManager shared] augmentPhotoUsingNearbySites: image completion:^(ARAugmentedPhoto *augmentedPhoto) {
            [self augmentProcessFinishedWithPhoto:augmentedPhoto];
        }];
        [augmentedView setAugmentedPhoto: p];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // do nothing
}

@end