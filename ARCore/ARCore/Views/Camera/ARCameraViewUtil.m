//
//  AVCaptureUtil.m
//  SquareCam
//
//  Created by Demetri Miller on 4/29/13.
//
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ARCameraViewUtil.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import "ARManager.h"
#import <CoreImage/CoreImage.h>
#import "NSMutableDictionary+ImageMetadata.h"
#import <MobileCoreServices/MobileCoreServices.h>

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
    AVCaptureVideoOrientation orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown: {
            orientation = [self avOrientationForInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
            break;
        }
        default:
            orientation = AVCaptureVideoOrientationPortrait;
    }
    
    return orientation;
}

+ (UIImageOrientation)imageOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    // Figured out the mapping through trial and error...
    UIImageOrientation orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationPortrait:
        default:
            orientation = UIImageOrientationRight;
            break;
    }
    
    return orientation;
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

+ (UIImage *)fixPhotoLibraryOrientationBeforeUploadingImage:(UIImage *)image
{
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

UIImage *scaleAndRotateImage(UIImage *image, UIImageOrientation orientation)
{
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    int kMaxResolution = width > height ? width : height; // Or whatever
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = orientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+ (void)processBuffer:(CMSampleBufferRef)imageDataSampleBuffer complete:(ARCameraCaptureCompleteBlock)complete
{
    // trivial simple JPEG case
    NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);

    // For some idiotic reason, images captured from the camera at the foundation level are always oriented landscape
    // right. Create a background queue for rotating the image to the "up" orientation.
    UIImage *incorrectImage = [UIImage imageWithData:jpegData];
    id value = CFDictionaryGetValue(attachments, (__bridge CFStringRef)@"Orientation");
    
    UIImage *correctImage = scaleAndRotateImage(incorrectImage, [[self class] orientationForExifOrientation:[value integerValue]]);
    
    NSMutableDictionary * metadata = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)(attachments)];
    [metadata setImageOrientation:correctImage.imageOrientation];
    [metadata setMake:@"Apple" model:[[UIDevice currentDevice] localizedModel] software:[[UIDevice currentDevice] systemVersion]];
    
    if (complete)
        complete(correctImage, metadata, NULL);
    if (attachments)
        CFRelease(attachments);
}

+ (UIImageOrientation)orientationForExifOrientation:(int)tag
{
    UIImageOrientation orientation = UIImageOrientationUp;
    switch (tag) {
        case UIImageOrientationUp:  // 0
            break;
        case UIImageOrientationDown: // 1
            orientation = UIImageOrientationDown;
            break;
        case UIImageOrientationLeft: // 2
            break;
        case UIImageOrientationRight: // 3
            orientation = UIImageOrientationUp;
            break;
        case UIImageOrientationUpMirrored: // 4
            break;
        case UIImageOrientationDownMirrored: // 5
            break;
        case UIImageOrientationLeftMirrored: // 6
            orientation = UIImageOrientationRight;
            break;
        case UIImageOrientationRightMirrored: // 7
            break;
        case 8: // wtf is exif tag 8?
            orientation = UIImageOrientationLeft;
        default:
            break;
    }
    return orientation;
}

@end
