//
//  ARCameraVC.h
//  SquareCam
//
//  Created by Demetri Miller on 5/2/13.
//
//

#import "ARCameraVC.h"
#import "ARCameraVC_iPad.h"
#import "ARCameraVC_iPhone.h"
#import "ARCameraViewUtil.h"
#import "MBProgressHUD.h"
#import "NSBundle+ARCoreResources.h"

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static NSString * const AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";


@implementation ARCameraVC
{
    BOOL _isFirstLoad;
}

#pragma mark - Lifecycle
- (id)initForCurrentDeviceIdiom
{
    ARCameraVC *vc;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        vc = [[ARCameraVC_iPhone alloc] initWithNibName:@"ARCameraVC_iPhone" bundle:[NSBundle arCoreResourcesBundle]];
    } else {
        vc = [[ARCameraVC_iPad alloc] initWithNibName:@"ARCameraVC_iPad" bundle:[NSBundle arCoreResourcesBundle]];
    }
    
    return vc;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _isFirstLoad = YES;    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isFirstLoad) {
        _isFirstLoad = NO;
        
        self.previewView = [[ARCameraPreviewView alloc] initWithFrame:self.view.bounds delegate:self];
        [self.view addSubview:_previewView];
    }
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

#pragma mark - Convenience
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
		[alertView show];
	});
}


#pragma mark - Camera Capture
- (IBAction)takePicture:(id)sender
{
    ARCameraVCPhotoTakenBlock __weak weakBlock = _photoTakenBlock;
    [_previewView takePictureWithCompletionBlock:^(NSData *jpegData, NSError *error) {
        if (weakBlock) {
            weakBlock(jpegData, error);
        }
    }];
}

- (void)toggleFlashMode:(id)sender
{
    AVCaptureFlashMode mode = _previewView.flashMode;
    mode = (mode+1)%3;
    _previewView.flashMode = mode;
}






@end
