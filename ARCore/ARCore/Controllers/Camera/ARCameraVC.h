//
//  ARCameraVC.m
//  SquareCam
//
//  Created by Demetri Miller on 5/2/13.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ARCameraPreviewView.h"

@class DMRotatableCameraHUD;

typedef void(^ARCameraVCPhotoTakenBlock)(NSData *jpegData, NSError *error);

@interface ARCameraVC : UIViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, ARCameraPreviewViewDelegate>

@property(nonatomic, strong) ARCameraPreviewView *previewView;
@property(nonatomic, copy) ARCameraVCPhotoTakenBlock photoTakenBlock;

/// Lifecycle
- (id)initForCurrentDeviceIdiom;

/// Camera Capture
- (IBAction)takePicture:(id)sender;
- (void)toggleFlashMode:(id)sender;

/// Convenience
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message;

/// Accessors
- (void)setPhotoTakenBlock:(ARCameraVCPhotoTakenBlock)photoTakenBlock;

@end
