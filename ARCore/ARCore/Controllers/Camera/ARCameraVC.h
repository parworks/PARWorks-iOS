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

@class ARCameraVC;

typedef void(^ARCameraVCPhotoTakenBlock)(UIImage *image, NSDictionary *metadata, NSError *error);

/** TODO: Implement this...
@protocol ARCameraVCDelegate <NSObject>

@optional
- (UIView *)hudForCameraVC:(ARCameraVC *)cameraVC;
- (void)didTakePhotoWithData:(NSData *)jpegData error:(NSError *)error;

@end
*/


@interface ARCameraVC : UIViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, ARCameraPreviewViewDelegate>

@property(nonatomic, strong) ARCameraPreviewView *previewView;
@property(nonatomic, copy) ARCameraVCPhotoTakenBlock photoTakenBlock;
//@property(nonatomic, weak) id<ARCameraVCDelegate> delegate;


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
