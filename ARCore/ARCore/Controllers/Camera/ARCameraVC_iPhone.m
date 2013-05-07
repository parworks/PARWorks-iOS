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
