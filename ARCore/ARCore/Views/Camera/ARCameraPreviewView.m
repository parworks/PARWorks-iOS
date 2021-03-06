//
//  AVCameraView.m
//  SquareCam 
//
//  Created by Demetri Miller on 4/30/13.
//
//

#import <ImageIO/ImageIO.h>
#import "ARCameraPreviewView.h"

#define kDefaultsFlashModeKey @"kDefaultsFlashModeKey" 

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static NSString * const AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";


@implementation ARCameraPreviewView

- (id)initWithFrame:(CGRect)frame delegate:(id<ARCameraPreviewViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate;
        [self sharedInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self sharedInit];
}

- (void)sharedInit
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self setupAVCapture];
    
    _canZoom = YES;
    _showFlash = YES;
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:_pinch];
}

- (void)dealloc
{
    [self teardownAVCapture];
}


#pragma mark - View Setup

- (void)setupAVCapture
{
	NSError *error = nil;
    
	_session = [AVCaptureSession new];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _session.sessionPreset = AVCaptureSessionPresetHigh;
    } else {
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    
    // Select a video device, make an input
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.flashMode = [[NSUserDefaults standardUserDefaults] integerForKey:kDefaultsFlashModeKey];
    
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        [self teardownAVCapture];
        return;
    }
	
	if ([_session canAddInput:deviceInput]) {
        [_session addInput:deviceInput];
    }
    
    // Make a still image output
	_stillImageOutput = [AVCaptureStillImageOutput new];
	[_stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext)];
	if ([_session canAddOutput:_stillImageOutput]) {
        [_session addOutput:_stillImageOutput];
    }
    
    // Make a video data output
	_videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCMPixelFormat_32BGRA)};
    _videoDataOutput.videoSettings = rgbOutputSettings;
    _videoDataOutput.alwaysDiscardsLateVideoFrames = YES; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	_videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
	
    if ([_session canAddOutput:_videoDataOutput]) {
        [_session addOutput:_videoDataOutput];
    }
	[[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
	
	_effectiveScale = 1.0;
	_previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _previewLayer.backgroundColor = [[UIColor blackColor] CGColor];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
	CALayer *rootLayer = self.layer;
    rootLayer.masksToBounds = YES;
    _previewLayer.frame = rootLayer.bounds;
	[rootLayer addSublayer:_previewLayer];
    
	[_session startRunning];
}

- (void)teardownAVCapture
{
    @try {
        [_stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage"];
    }
    @catch (NSException *exception) {}
    @finally {
        [_previewLayer removeFromSuperlayer];
        [_session stopRunning];
        _session = nil;
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _previewLayer.frame = self.layer.bounds;
}

#pragma mark - Getters/Setters

- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device.flashAvailable && flashMode != device.flashMode) {
        NSError *error;
        BOOL success = [device lockForConfiguration:&error];
        if (success) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
            
            [[NSUserDefaults standardUserDefaults] setInteger:flashMode forKey:kDefaultsFlashModeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            NSLog(@"Error getting lock for device configuration: %@", error.localizedDescription);
        }
    }
}

- (AVCaptureFlashMode)flashMode
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return device.flashMode;
}


#pragma mark - Camera Capture
- (void)takePictureWithCompletionBlock:(ARCameraCaptureCompleteBlock)complete
{
	// Find out the current orientation and tell the still image output.
    AVCaptureVideoOrientation avcaptureOrientation;
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    avcaptureOrientation = [ARCameraViewUtil avOrientationForDeviceOrientation:curDeviceOrientation];
    
	AVCaptureConnection *stillImageConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    stillImageConnection.videoOrientation = avcaptureOrientation;
    stillImageConnection.videoScaleAndCropFactor = _effectiveScale;
    _stillImageOutput.outputSettings = @{(id)AVVideoCodecKey : AVVideoCodecJPEG};
	
    ARCameraPreviewView * __weak weakSelf = self;
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            [ARCameraViewUtil processBuffer:imageDataSampleBuffer complete:^(UIImage *image, NSDictionary *metadata, NSError *error) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didCaptureImageWithImage:error:)]) {
                    [weakSelf.delegate didCaptureImageWithImage:image metadata:metadata error:error];
                }
                
                if (complete) {
                    complete(image, metadata, error);
                }
            }];
    }];
    
    // simulator scenario
    if (_stillImageOutput == nil) {
//        NSData * jpegData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"chipotle-franchise1" ofType:@"jpg"]];
//        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didCaptureImageWithData:error:)]) {
//            [weakSelf.delegate didCaptureImageWithImage:jpegData error: NULL];
//        }
//        
//        if (complete) {
//            complete(jpegData, NULL);
//        }
    }
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Perform a flash bulb animation using KVO to monitor the value of the capturingStillImage property of the AVCaptureStillImageOutput class
	if (context == (__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext)) {
		BOOL isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
		
        if (_delegate && [_delegate respondsToSelector:@selector(capturingStateDidChange:)]) {
            [_delegate capturingStateDidChange:isCapturingStillImage];
        }
        
		if (isCapturingStillImage && _showFlash) {
			// Do flash bulb like animation
			_flashView = [[UIView alloc] initWithFrame:self.bounds];
            _flashView.backgroundColor = [UIColor whiteColor];
            _flashView.alpha = 0.0;
			[self addSubview:_flashView];
			
			[UIView animateWithDuration:.2f animations:^{
                _flashView.alpha = 1.0;
            }];
		}
		else {
			[UIView animateWithDuration:.2f animations:^{
                _flashView.alpha = 0.0;
            } completion:^(BOOL finished){
                [_flashView removeFromSuperview];
                _flashView = nil;
            }];
		}
	}
}


#pragma mark - Zooming
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && _canZoom) {
		_beginGestureScale = _effectiveScale;
	}
	return YES;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    if (!_canZoom) {
        return;
    }
    
    // Scale image depending on users pinch gesture
	BOOL allTouchesAreOnThePreviewLayer = YES;
	NSUInteger numTouches = [recognizer numberOfTouches], i;
	for ( i = 0; i < numTouches; ++i ) {
		CGPoint location = [recognizer locationOfTouch:i inView:self];
		CGPoint convertedLocation = [_previewLayer convertPoint:location fromLayer:_previewLayer.superlayer];
		if ( ! [_previewLayer containsPoint:convertedLocation] ) {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if ( allTouchesAreOnThePreviewLayer ) {
		_effectiveScale = _beginGestureScale * recognizer.scale;
		if (_effectiveScale < 1.0) {
            _effectiveScale = 1.0;
        }
			
		CGFloat maxScaleAndCropFactor = [[_stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
		if (_effectiveScale > maxScaleAndCropFactor) {
            _effectiveScale = maxScaleAndCropFactor;
        }
			
        [self zoomToEffectiveScale:_effectiveScale];
	}
}

- (void)zoomToEffectiveScale:(CGFloat)scale
{
    if (_effectiveScale != scale) {
        _effectiveScale = scale;
    }
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [_previewLayer setAffineTransform:CGAffineTransformMakeScale(scale, scale)];
    [CATransaction commit];
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)orientation
{
    _previewLayer.connection.videoOrientation = orientation;
}


@end
