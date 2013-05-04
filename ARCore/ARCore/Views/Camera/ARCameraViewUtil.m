//
//  AVCaptureUtil.m
//  SquareCam 
//
//  Created by Demetri Miller on 4/29/13.
//
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ARCameraViewUtil.h"

@implementation ARCameraViewUtil
+ (AVCaptureVideoOrientation)avOrientationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        default:
            return AVCaptureVideoOrientationPortrait;
            break;
    }
}

+ (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}

+ (CGFloat)rotationAngleForDeviceOrientation:(UIDeviceOrientation)orientation
{
    CGFloat rotateAngle = 0.0;
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            rotateAngle = -M_PI/2.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            rotateAngle = M_PI/2.0f;
            break;
        default: // do nothing
            break;
    }
    
    return rotateAngle;
}

+ (void)saveBufferToLibrary:(CMSampleBufferRef)imageDataSampleBuffer complete:(ARCameraCaptureCompleteBlock)complete
{    
    // trivial simple JPEG case
    NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                imageDataSampleBuffer,
                                                                kCMAttachmentMode_ShouldPropagate);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"Error saving to photo album");
        }
     
        if (complete) {
            complete(jpegData, error);
        }
    }];
    
    if (attachments) {
        CFRelease(attachments);
    }
}

@end
