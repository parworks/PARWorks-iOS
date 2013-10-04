//
//  AVCaptureUtil.h
//  SquareCam 
//
//  Created by Demetri Miller on 4/29/13.
//
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

typedef void(^ARCameraCaptureCompleteBlock)(UIImage *image, NSDictionary* metadata, NSError *error);


@interface ARCameraViewUtil : NSObject

+ (UIImage *)fixPhotoLibraryOrientationBeforeUploadingImage:(UIImage *)image;

+ (AVCaptureVideoOrientation)avOrientationForInterfaceOrientation:(UIInterfaceOrientation)orientation;
+ (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
+ (UIImageOrientation)imageOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

+ (CGFloat)rotationAngleForDeviceOrientation:(UIDeviceOrientation)orientation;

+ (void)processBuffer:(CMSampleBufferRef)imageDataSampleBuffer complete:(ARCameraCaptureCompleteBlock)complete;
@end
