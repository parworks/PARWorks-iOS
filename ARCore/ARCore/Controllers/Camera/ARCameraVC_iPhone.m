//
//  ARCameraVC_iPhone.m
//  SquareCam 
//
//  Created by Demetri Miller on 5/2/13.
//
//

#import "ARCameraOverlayTooltip.h"
#import "ARCameraVC_iPhone.h"
#import "DMRotatableCameraHUD.h"
#import "GRCameraOverlayToolbar.h"

@implementation ARCameraVC_iPhone
{
    BOOL _isFirstLoad;
}


#pragma mark - Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isFirstLoad = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isFirstLoad) {
        _isFirstLoad = NO;

        [self setupViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayoutForCurrentOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)setupViews
{
    _toolbar = [GRCameraOverlayToolbar toolbarFromXIB];
    CGRect frame = _toolbar.frame;
    frame.origin.y = self.view.bounds.size.height - _toolbar.bounds.size.height;
    _toolbar.frame = frame;
    [self.view addSubview:_toolbar];
    
    [_toolbar.cameraButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar.flashButton addTarget:self action:@selector(toggleFlashMode:) forControlEvents:UIControlEventTouchUpInside];
    
    // Tooltip that appears to animate from the toolbar
    self.tooltip = [[ARCameraOverlayTooltip alloc] initWithFrame:CGRectMake(0, 0, 250, 60)];
    _tooltip.center = CGPointMake(self.view.bounds.size.width/2, _toolbar.frame.origin.y - _tooltip.frame.size.height + 10);
    _tooltip.label.text = @"This is some tooltip text";
    _tooltip.label.adjustsFontSizeToFitWidth = YES;
    _tooltip.label.textAlignment = NSTextAlignmentCenter;
    _tooltip.alpha = 0.0;
    [self.view addSubview:_tooltip];
}


#pragma mark - Layout
/*
- (void)relayoutForCurrentOrientation:(NSNotification *)note
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    // Default orientation for the camera overlay is portrait...
    
    CGFloat rotateAngle;
    CGFloat tooltipTranslateOffset;
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            tooltipTranslateOffset = 0;
            break;
        case UIDeviceOrientationLandscapeRight:
            rotateAngle = -M_PI/2.0f;
            tooltipTranslateOffset = 95;
            break;
        case UIDeviceOrientationLandscapeLeft:
            rotateAngle = M_PI/2.0f;
            tooltipTranslateOffset = -95;
            break;
        case UIDeviceOrientationPortrait:
            rotateAngle = 0.0;
            tooltipTranslateOffset = 0;
            break;
        default: // do nothing
            return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform t = CGAffineTransformMakeRotation(rotateAngle);
        
        UIWindow *mainWindow = [[UIApplication sharedApplication] windows][0];
        
        float shortSide = self.view.bounds.size.width;
        float longSide = shortSide * IOS_CAMERA_ASPECT_RATIO;
        
        _toolbar.flashButton.transform = t;
        _toolbar.cancelButton.transform = t;
        _progressHUD.transform = t;
        _takenPhotoLayer.transform = CATransform3DMakeAffineTransform(t);
        _augmentedView.layer.transform = CATransform3DMakeAffineTransform(t);
        
        // In addition to the rotation, we also need to translate the tooltip so it doesn't
        // overlay the toolbar.
        _tooltip.transform = CGAffineTransformTranslate(t, tooltipTranslateOffset, 0);
        [_tooltip updateArrowLocationForDeviceOrientation:orientation];
        
        // we check for landscape, not portrait because there is also face up, face down, etc... and we want
        // to handle those as portrait and not as landscape.
        _takenPhotoLayer.bounds = UIInterfaceOrientationIsLandscape(orientation) ? CGRectMake(0, 0, longSide, shortSide) : CGRectMake(0, 0, shortSide, longSide);
        _augmentedView.bounds = UIInterfaceOrientationIsLandscape(orientation) ? CGRectMake(0, 0, longSide, shortSide) : CGRectMake(0, 0, shortSide, longSide);
    }];
}
*/
#pragma mark - Rotation
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}



@end
