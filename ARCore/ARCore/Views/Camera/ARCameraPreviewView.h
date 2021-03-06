//
//  AVCameraView.h
//  SquareCam 
//
//  Created by Demetri Miller on 4/30/13.
//
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "ARCameraViewUtil.h"

@protocol ARCameraPreviewViewDelegate <NSObject>

@optional
- (void)capturingStateDidChange:(BOOL)isCapturing;
- (void)didCaptureImageWithImage:(UIImage *)image metadata:(NSDictionary*)metadata error:(NSError *)error;

// In case the owning view controller needs to explicitly tell the preview view the orientation for the
// image capture.
- (UIInterfaceOrientation)currentCaptureInterfaceOrientation;
@end



@interface ARCameraPreviewView : UIView <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureVideoPreviewLayer  * _previewLayer;
	AVCaptureStillImageOutput   * _stillImageOutput;
	AVCaptureVideoDataOutput    * _videoDataOutput;
    dispatch_queue_t              _videoDataOutputQueue;
	AVCaptureSession            * _session;
    UIView *_flashView;
    
    UIPinchGestureRecognizer *_pinch;
	CGFloat _beginGestureScale;
	CGFloat _effectiveScale;
}

@property(nonatomic, assign) AVCaptureFlashMode flashMode;

/** When YES, a user can pinch to zoom the camera view. Defaults to YES. */
@property(nonatomic, assign) BOOL canZoom;

/** When YES, a white view flashes on screen when a photo is taken. Defaults to YES. */
@property(nonatomic, assign) BOOL showFlash;

@property(nonatomic, weak) id<ARCameraPreviewViewDelegate> delegate;

/// Lifecycle
- (id)initWithFrame:(CGRect)frame delegate:(id<ARCameraPreviewViewDelegate>)delegate;

/// Camera Capture
- (void)takePictureWithCompletionBlock:(ARCameraCaptureCompleteBlock)complete;

/// Zooming
- (void)zoomToEffectiveScale:(CGFloat)scale;

/// Config
- (void)setVideoOrientation:(AVCaptureVideoOrientation)orientation;

@end
