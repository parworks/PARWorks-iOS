//
//  EPViewController.m
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


#import <MobileCoreServices/MobileCoreServices.h>
#import "EPViewController.h"
#import "ASIHTTPRequest.h"
#import "UIImageView+AnimationAdditions.h"
#import "EnvironmentSelectorViewController.h"
#import "CATextLayer+Loading.h"
#import "PARWorks.h"
#import "EPUtil.h"
#import "AdOverlayView.h"
#import "EPAppDelegate.h"

#define WIDTH 20
#define HEIGHT 20

#define CAMERA_TRANSFORM_SCALE 1.25


@implementation EPViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _firstLoad = YES;
    
    // We use a text layer so we can get awesome implicit animations...
    _loadingLayer.foregroundColor = [UIColor whiteColor].CGColor;
    _loadingLayer = [CATextLayer layer];
    _loadingLayer.opacity = 0.0;
    _loadingLayer.string = @"Augmenting";
    _loadingLayer.fontSize = 16.0;
    _loadingLayer.rasterizationScale = [UIScreen mainScreen].scale;
    _loadingLayer.contentsScale = [UIScreen mainScreen].scale;
    _loadingLayer.needsDisplayOnBoundsChange = NO;
    [self.view.layer addSublayer:_loadingLayer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_selectedSite) {
        [self selectSite: nil];
        _selectedSite = YES;
        
    } else if (_firstLoad) {
        _cameraOverlayView = [[GRCameraOverlayView alloc] initWithFrame:self.view.bounds];
        [_cameraOverlayView.augmentButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];

        _shrinkingMask = [[CALayer alloc] init];
        _shrinking = [[UIImageView alloc] init];
        _scanline = [[UIImageView alloc] initWithImageSeries:@"scanline_%d.png"];
        [_shrinkingMask setOpaque: YES];
        [_shrinkingMask setBackgroundColor: [[UIColor redColor] CGColor]];
        [_shrinking.layer setMask: _shrinkingMask];
        [_shrinkingMask setFrame: self.view.bounds];
        [_shrinking setFrame: self.view.bounds];
        [self.view addSubview: _shrinking];
        [self.view addSubview: _scanline];

        [self showCameraPicker:nil];
        _firstLoad = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


#pragma mark - Presentation

- (IBAction)showCameraPicker:(id)sender
{
    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            _picker.mediaTypes = @[(NSString *) kUTTypeImage];
            _picker.cameraOverlayView = _cameraOverlayView;
            _picker.showsCameraControls = NO;
            _picker.cameraViewTransform = CGAffineTransformMakeScale(CAMERA_TRANSFORM_SCALE, CAMERA_TRANSFORM_SCALE);
        } else {
            _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    
    [self presentViewController:_picker animated:NO completion:nil];
}

- (void)showAugmentingViewWithImage:(UIImage *)image
{
    [_layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_layers removeAllObjects];

    if (!_layers)
        _layers = [NSMutableArray array];

    int xSteps = image.size.width / WIDTH;
    int ySteps = image.size.height / HEIGHT;
    int count = xSteps * ySteps;

    for (int i = 0; i < count; i++) {
        CALayer *layer = [CALayer layer];
        [_layers addObject:layer];
        [self.view.layer insertSublayer:layer below:_shrinking.layer];
    }

    [EPUtil smallImagesWithWidth:WIDTH height:HEIGHT fromImage:_image withImageReadyCallback: ^(int i, UIImage* img) {
        [(CALayer*)[_layers objectAtIndex: i] performSelectorOnMainThread:@selector(setContents:) withObject:(id)[img CGImage] waitUntilDone:NO];
        NSLog(@"Set layer image %d", i);
    }];
    
    NSLog(@"Created layers");
    [self layoutLayersInGrid];
}

- (void)startScanlineAnimation
{
    _scanlineAnimationRunning = YES;
    
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    [_shrinking setImage: _image];
    [_shrinkingMask setFrame: self.view.bounds];
    [_shrinking setFrame: self.view.bounds];
    [_scanline setAlpha: 0.0];
    [_showCameraButton setAlpha: 0];
    [_augmentedView setAlpha: 0];
    [_augmentedView setDelegate: self];
    
    [_scanline setAnimationRepeatCount: 1000];
    _scanline.frame = CGRectMake(0, -_scanline.frame.size.height, _scanline.frame.size.width, _scanline.frame.size.height);
    [CATransaction commit];
    
    CALayer *firstLayer = [_layers objectAtIndex:0];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(translateLayersOut)];
    _scanline.frame = CGRectMake(0, CGRectGetMinY(firstLayer.frame)-_scanline.frame.size.height/2, _scanline.frame.size.width, _scanline.frame.size.height);
    [_scanline setAlpha: 1];
    [UIView commitAnimations];
    NSLog(@"Started animation");
}

- (void)startAugmentCompleteAnimation
{
    if ([[_augmentedPhoto overlays] count] > 0) {
        _augmentCompleteAnimationRunning = YES;
        
        [self.view bringSubviewToFront: _augmentedView];
        [_augmentedView setTransform: CGAffineTransformIdentity];
        [_augmentedView setAugmentedPhoto: _augmentedPhoto];
        _augmentedView.center = CGPointMake(self.view.frame.size.height / 2, self.view.frame.size.width / 2 - 20);
        _augmentedView.transform = CGAffineTransformMakeScale(CAMERA_TRANSFORM_SCALE, CAMERA_TRANSFORM_SCALE);

        [self translateLayersWithStartDelay:0 rowDelay: 0.04];
        [self performSelector:@selector(finalizeAugmentCompleteAnimation) withObject:nil afterDelay:1.1];
    
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"We weren't able to find any overlays in that image. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
        [self showCameraPicker:nil];
    }
}

- (void)finalizeAugmentCompleteAnimation
{
    _augmentCompleteAnimationRunning = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.5];
    [_augmentedView setAlpha: 1];
    [self.view bringSubviewToFront: _showCameraButton];
    [_showCameraButton setAlpha: 1];
    [UIView commitAnimations];
}

#pragma mark - Layout

- (void)layoutLayersInGrid
{
    int xSteps = _image.size.width / WIDTH;
    int ySteps = _image.size.height / HEIGHT;
    int count = xSteps * ySteps;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    for (int i = 0; i < count; i++) {
        int y = floor(i / xSteps);
        int x = i % xSteps;
    
        float xOrigin = x * WIDTH;
        float yOrigin = y * HEIGHT;
        
        CALayer *l = [_layers objectAtIndex: i];
        l.frame = CGRectMake(xOrigin, yOrigin, WIDTH, HEIGHT);
    }
    [CATransaction commit];
}


#pragma mark - Animations

- (IBAction)resetLayerTransforms
{
    for (CALayer *l in _layers) {
        l.transform = CATransform3DIdentity;
        l.opacity = 1.0;
    }
}

- (IBAction)takePicture:(id)sender
{
    [_picker takePicture];
}

- (IBAction)selectSite:(id)sender
{
    EnvironmentSelectorViewController * e = [[EnvironmentSelectorViewController alloc] init];
    [self presentViewController:e animated:YES completion:NULL];
}

- (void)translateLayersOut
{
    [self translateLayersWithStartDelay:0.2 rowDelay: 0.15];
}

- (void)translateLayersWithStartDelay:(float)delay rowDelay:(float)rowDelay
{
    srand(time(0));
    CGSize size = CGSizeMake(WIDTH, HEIGHT);
    int rows = _image.size.height/size.height;
    int cols = _image.size.width/size.width;

    [_scanline startAnimating];
    
    CALayer *lastLayer = [_layers objectAtIndex:rows*(cols-1)];
    [UIView animateWithDuration:(rowDelay * rows)+delay animations:^{
        _scanline.frame = CGRectMake(0, CGRectGetMinY(lastLayer.frame)-_scanline.frame.size.height/2, _scanline.frame.size.width, _scanline.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:rowDelay * 6 animations:^{
            _scanline.alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }];
    [CATransaction begin];
    [CATransaction setAnimationDuration: ((rowDelay * rows) + delay) * 1.4];
    [_shrinkingMask setFrame: CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 200)];
    [CATransaction commit];
    
    // Iterate over each row animating all the bits offscreen in the -Y direction.
    for (int i=0; i<rows; i++)
        [self performSelector:@selector(translateRowOffscreen:) withObject:[NSNumber numberWithInt: i] afterDelay:delay + rowDelay * i];

    [self performSelector:@selector(translateLayersComplete) withObject:nil afterDelay:(rowDelay * (rows + 3)) + delay];
}

- (void)translateRowOffscreen:(NSNumber *)rowNumber
{
    int row = rowNumber.intValue;
    int cols = _image.size.width/WIDTH;
    
    CGFloat duration = ((rand()*0.1)/INT_MAX) + 0.6;
    
    static CAMediaTimingFunction *timing;
    timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:timing];
    
    for (int c = 0; c < cols; c ++) {
        CALayer *layer = [_layers objectAtIndex: (cols * row) + c];
        CGFloat yOffset = -(CGRectGetMinY(layer.frame) + 20 + (rand()%220));
        CGFloat xOffset = CGRectGetMidX(layer.frame);
        CGFloat randOffsetX = (rand()%40)-(20);
        xOffset+=randOffsetX;

        CATransform3D transform = CATransform3DIdentity;
    
        if (CATransform3DIsIdentity(layer.transform)) {
            transform = CATransform3DTranslate(transform, 0, yOffset, 0);
            transform = CATransform3DScale(transform, 0.5, 0.5, 1);
            CGFloat rotate = ((rand()*1.0)/INT_MAX) - 0.5;
            transform = CATransform3DRotate(transform, M_PI*rotate, 0, 0, 1);
        }
    
        layer.transform = transform;
    }

    
    [CATransaction commit];
}

- (void)translateLayersComplete
{
    if (_scanlineAnimationRunning) {
        _scanlineAnimationRunning = NO;
        if ((_augmentedPhoto.response == BackendResponseFinished) && !_augmentCompleteAnimationRunning)
            [self startAugmentCompleteAnimation];
        else {
            _loadingLayer.frame = CGRectMake(self.view.frame.size.height/2 - 40, self.view.frame.size.width/2, self.view.frame.size.height/2, _loadingLayer.fontSize+4);
            [_loadingLayer startLoadingAnimation];
        }
    }
}
    


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize viewportSize = self.view.bounds.size;
    CGSize originalSize = [originalImage size];
    
    UIGraphicsBeginImageContextWithOptions(viewportSize, YES, 1);
    
    float scale = fminf(viewportSize.width / originalSize.width, viewportSize.height / originalSize.height) * CAMERA_TRANSFORM_SCALE;
    CGSize resizedSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    CGRect resizedFrame = CGRectMake((viewportSize.width - resizedSize.width) / 2, (viewportSize.height - resizedSize.height) / 2 - 20, resizedSize.width, resizedSize.height);
    [originalImage drawInRect:resizedFrame];

    _image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    [self startScanlineAnimation];
    [self performSelectorOnMainThread:@selector(showAugmentingViewWithImage:) withObject:_image waitUntilDone:NO];
    
    // Upload the original image to the AR API for processing. We'll animate the
    // resized image back on screen once it's finished.
    if (!_site) {
        NSString * siteIdentifier = [(EPAppDelegate*)[[UIApplication sharedApplication] delegate] APIServer];
        _site = [[ARSite alloc] initWithIdentifier: siteIdentifier];
    }
    
    _augmentedPhoto = [_site augmentImage: originalImage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageAugmented:) name:NOTIF_AUGMENTED_PHOTO_UPDATED object:_augmentedPhoto];
}

- (void)imageAugmented:(NSNotification*)notif
{
    if (_augmentedPhoto.response == BackendResponseFinished) {
        if (!_scanlineAnimationRunning) {
            [_loadingLayer stopLoadingAnimation];
            [self startAugmentCompleteAnimation];
        }
    } else if (_augmentedPhoto.response == BackendResponseFailed){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"The PAR Works API server did not successfully augment the photo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];

        [self showCameraPicker:nil];

    } else {
        // just wait...
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // do nothing
}


- (AROverlayView *)overlayViewForOverlay:(AROverlay *)overlay
{
    if ([overlay.name isEqualToString: @"Ad"]) {
        AdOverlayView * v = [[AdOverlayView alloc] initWithOverlay: overlay];
        return v;
    } else {
        return nil;
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://parworks.com/"]];
}
@end