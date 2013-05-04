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
- (void)didCaptureImageWithData:(NSData *)imageData error:(NSError *)error;

@end



@interface ARCameraPreviewView : UIView <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureVideoPreviewLayer  *_previewLayer;
	AVCaptureStillImageOutput   *_stillImageOutput;
	AVCaptureVideoDataOutput    *_videoDataOutput;
    dispatch_queue_t            _videoDataOutputQueue;
	
    UIView *_flashView;
    
    UIPinchGestureRecognizer *_pinch;
	CGFloat _beginGestureScale;
	CGFloat _effectiveScale;
}

@property(nonatomic, assign) AVCaptureFlashMode flashMode;
@property(nonatomic, weak) id<ARCameraPreviewViewDelegate> delegate;

/// Lifecycle
- (id)initWithFrame:(CGRect)frame delegate:(id<ARCameraPreviewViewDelegate>)delegate;

/// Camera Capture
- (void)takePictureWithCompletionBlock:(ARCameraCaptureCompleteBlock)complete;

@end
