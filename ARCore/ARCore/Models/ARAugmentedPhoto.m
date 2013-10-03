//
//  ARAugmentedPhoto.m
//  PAR Works iOS SDK
//
//  Copyright 2013 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "ARConstants.h"
#import "AROverlay.h"
#import "AROverlayPoint.h"
#import "ARAugmentedPhoto.h"
#import "ARManager.h"
#import "ARSite.h"
#import "SBJSON.h"
#import "ASIHTTPRequest+JSONAdditions.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>


#define PHOTOS_DIRECTORY [@"~/Documents/Photos/" stringByExpandingTildeInPath]
#define DEFAULT_JPEG_QUALITY 0.45

@implementation ARAugmentedPhoto

- (id)initWithImage:(UIImage*)i
{
    self = [super init];
    if (self) {
        self.image = i;
        self.imageIdentifier = [NSString stringWithFormat: @"%x.jpg", (unsigned int)_image];
    
        if (([i size].width < 1000) && ([i size].height < 1000))
            NSLog(@"HDAR: The image you are augmenting is smaller than 1000px, and will probably not be augmented successfully.");
    }
    return self;
}

- (id)initWithScaledImage:(UIImage*)img atScale:(float)scale andOverlayJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        self.image = img;
        self.response = BackendResponseFinished;
        [self processJSONData:json forDisplayWithScale: scale];
    }
    return self;
}

- (id)initWithImageFile:(NSString*)iPath andOverlayJSONFile:(NSString*)jsonPath
{
    self = [super init];
    if (self) {
        self.image = [UIImage imageWithContentsOfFile: iPath];
        self.imageIdentifier = [iPath lastPathComponent];
        self.response = BackendResponseFinished;
        
        NSError *err = nil;
        NSData *data = [NSData dataWithContentsOfFile:jsonPath];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        
        if (err || ![dict isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Error parsing JSON -- %@", err);
            return nil;
        }
        
        [self processJSONData:dict];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.imageIdentifier = [aDecoder decodeObjectForKey: @"imageIdentifier"];
        self.site = [aDecoder decodeObjectForKey: @"site"];
        self.overlays = [aDecoder decodeObjectForKey: @"overlays"];
        self.response = [aDecoder decodeIntForKey: @"response"];

        NSString * path = [PHOTOS_DIRECTORY stringByAppendingPathComponent: self.imageIdentifier];
        self.image = [UIImage imageWithContentsOfFile: path];
        
        if (self.response == BackendResponseProcessing) {
            [self processPoll];
        } else if (self.response == BackendResponseUploading) {
            [self process];
        }
            
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSData * imgData = UIImagePNGRepresentation(self.image);
    NSString * imgPath = [PHOTOS_DIRECTORY stringByAppendingPathComponent: self.imageIdentifier];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:PHOTOS_DIRECTORY withIntermediateDirectories:YES attributes:nil error:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath: imgPath] == NO)
        [imgData writeToFile:imgPath atomically:NO];
    
    [aCoder encodeObject:self.imageIdentifier forKey:@"imageIdentifier"];
    [aCoder encodeObject:self.site forKey:@"site"];
    [aCoder encodeObject:self.overlays forKey:@"overlays"];
    [aCoder encodeInt:self.response forKey:@"response"];
}

- (NSMutableDictionary*)processArguments
{
    NSMutableDictionary * args = [NSMutableDictionary dictionary];
    if (_site)
        [args setObject:_site.identifier forKey:@"site"];
    [args setObject:_imageIdentifier forKey:@"imgId"];
    [args setObject:_imageIdentifier forKey:@"filename"];
    if ([[ARManager shared] locationEnabled]) {
        [args setObject:[NSNumber numberWithDouble: [[ARManager shared] deviceLocation].coordinate.latitude] forKey:@"lat"];
        [args setObject:[NSNumber numberWithDouble: [[ARManager shared] deviceLocation].coordinate.longitude] forKey:@"lon"];
        [args setObject:[NSNumber numberWithDouble: [[ARManager shared] deviceHeading].magneticHeading] forKey:@"heading"];
    }
    return args;
}

- (UIImage*)imageForCell:(GridCellView*)cell
{
    return _image;
}

- (ASIFormDataRequest*)requestForProcessing
{
    NSMutableDictionary * args = [self processArguments];
    if (_site == nil)
        return (ASIFormDataRequest*)[[ARManager shared] createRequest:REQ_IMAGE_AUGMENT_GEO withMethod:@"POST" withArguments:args];
    else
        return (ASIFormDataRequest*)[[ARManager shared] createRequest:REQ_IMAGE_AUGMENT withMethod:@"POST" withArguments:args];
}
- (ASIFormDataRequest*)requestForChangeDetectionProcessing
{
    NSString *isChangeDetection = @"true";
    NSMutableDictionary * args = [self processArguments];
    [args setObject:isChangeDetection forKey:@"withCD"];
    if (_site == nil)
        @throw [NSException exceptionWithName: @"ProcessChangeDetectionExcepion" reason: @"The site cannot be nil when processing change detection." userInfo:nil];
    else
        return (ASIFormDataRequest*)[[ARManager shared] createRequest:REQ_IMAGE_AUGMENT withMethod:@"POST" withArguments:args];
}

- (void)process
{
    if (_image == nil)
        @throw [NSException exceptionWithName: @"ProcessException" reason: @"You need to provide an image to the ARAugmentedPhoto before calling process." userInfo: nil];
    
    if ((_site == nil) && ([[ARManager shared] locationEnabled] == NO))
        @throw [NSException exceptionWithName: @"ProcessException" reason: @"You cannot process an image without specifying a site or enabling location services in the ARManager." userInfo: nil];

    NSDictionary *propDict = [_image.CIImage properties];
    NSLog(@"Final properties %@", propDict);

    _image = [[ARManager shared] rotateImage:_image byOrientationFlag:_image.imageOrientation];
    
   NSURL *docsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
   NSURL *outputURL = [docsURL URLByAppendingPathComponent:@"imageWithEXIFData.jpg"];
    
    ASIFormDataRequest * req = [self requestForProcessing];
    ASIFormDataRequest * __weak __req = req;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_STATUS_CHANGE object: @"Upload Starting..."];
    
    CGFloat jpegQuality = DEFAULT_JPEG_QUALITY;
    if ([[NSUserDefaults standardUserDefaults] floatForKey:@"jpegQuality"])
        jpegQuality = [[NSUserDefaults standardUserDefaults] floatForKey:@"jpegQuality"];
    
    NSData *imageData = [NSData dataWithContentsOfURL:outputURL];
    
    
    [req setData:imageData forKey:@"image"];
    [req setShowAccurateProgress: YES];
    [req setFailedBlock: ^(void) {
        _response = BackendResponseFailed;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_STATUS_CHANGE object: @"Upload Failed."];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
        [[ARManager shared] criticalRequestFailed: __req];
        if (_processingCompletionBlock) _processingCompletionBlock(self);
    }];

    ASIHTTPRequest*  __block __breq = req;
    [req setBytesSentBlock:^(unsigned long long size, unsigned long long total) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_STATUS_CHANGE object: [NSString stringWithFormat: @"%.1f%% Uploaded (%lld KB)", ((float)([__breq totalBytesSent]) / (float)[__breq postLength]) * 100.0, [__breq totalBytesSent] / 1024]];
    }];

    [req setCompletionBlock: ^(void) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_STATUS_CHANGE object: @"Upload Finished."];

        if ([[ARManager shared] handleResponseErrors: __req]) {
            [self processPostComplete: __req];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_STATUS_CHANGE object: @"Polling for response..."];

        } else {
            _response = BackendResponseFailed;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
            if (_processingCompletionBlock) _processingCompletionBlock(self);
        }
    }];

    _response = BackendResponseUploading;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
    
    [req startAsynchronous];
}

- (UIImage*)addEXIFDataToImage:(UIImage*)image{
    NSData *jpeg = UIImageJPEGRepresentation(image, 0.0);

    CGImageSourceRef source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);

    //get all the metadata in the image
    NSDictionary *metadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);

    //make the metadata dictionary mutable so we can add properties to it
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];

    NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
    if(!EXIFDictionary) {
        //if the image does not have an EXIF dictionary (not all images do), then create one for us to use
        EXIFDictionary = [NSMutableDictionary dictionary];
    }
    if(!GPSDictionary) {
        GPSDictionary = [NSMutableDictionary dictionary];
    }

    //Setup GPS dict
    if ([[ARManager shared] locationEnabled]) {
        [metadataAsMutable setObject:[self getGPSDictionaryForLocation:[[ARManager shared] deviceLocation]] forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    //add our modified EXIF data back into the image’s metadata
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    
      CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)

    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];

    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);

    if(!destination) {
        NSLog(@"***Could not create image destination ***");
    }

    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadataAsMutable);

    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);

    if(!success) {
        NSLog(@"***Could not create data from image destination ***");
    }

    //cleanup

    CFRelease(destination);
    CFRelease(source);

    return [UIImage imageWithData:dest_data];
}

- (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location {
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];

    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];

    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];

    // Latitude
    CGFloat latitude = location.coordinate.latitude;
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } else {
        [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];

    // Longitude
    CGFloat longitude = location.coordinate.longitude;
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } else {
        [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];

    // Altitude
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } else {
            [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        }
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }

    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setObject:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }

    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setObject:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }

    return gps;
}

- (void)processPostComplete:(ASIFormDataRequest*)req
{
    [self startPollForImageIdentifier: [[req responseJSON] objectForKey: @"imgId"]];
}

- (void)startPollForImageIdentifier:(NSString*)ident
{
    _response = BackendResponseProcessing;
    _imageIdentifier = ident;
    _pollCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
    
    [_pollTimer invalidate];
    _pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(processPoll) userInfo:nil repeats:NO];
}

- (void)processPoll
{
    _pollTimer = nil;
    if (_pollCount == 20) {
        self.response = BackendResponseFailed;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
        return;
    }
    
    NSMutableDictionary * args = [self processArguments];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"static_result"])
        [args setObject:@"true" forKey:@"specialResult"];
    
    ASIHTTPRequest * req = [[ARManager shared] createRequest:REQ_IMAGE_AUGMENT_RESULT withMethod:@"GET" withArguments:args];
    ASIHTTPRequest * __weak __req = req;
    
    [req setCompletionBlock: ^(void) {
        if ([__req responseStatusCode] != 200) {
            _pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(processPoll) userInfo:nil repeats:NO];
            _pollCount ++;
        } else {
            [self processJSONData: [__req responseJSON]];
            self.response = BackendResponseFinished;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
            if (_processingCompletionBlock) _processingCompletionBlock(self);
        }
    }];
    [req startAsynchronous];
}

- (void)processJSONData:(NSDictionary*)data 
{
    [self processJSONData: data forDisplayWithScale: 1];
}

- (void)processJSONData:(NSDictionary*)data forDisplayWithScale:(float)scale
{
    if ([data isKindOfClass: [NSDictionary class]] == NO)
        return;

    if (_overlays == nil)
        self.overlays = [NSMutableArray array];

    NSMutableDictionary * overlayDicts = [data objectForKey: @"overlays"];
    for (NSDictionary * overlay in overlayDicts) {
        AROverlay * result = [[AROverlay alloc] initWithDictionary: overlay];
        for (AROverlayPoint * p in result.points) {
            p.x = p.x *= scale;
            p.y = p.y *= scale;
        }
        [result setSite: self.site];
        [self addOverlay: result];
    }
    
    if ([data objectForKey: @"image_override_url"]) {
        NSString * path = [data objectForKey: @"image_override_url"];
        NSData * imgData = [NSData dataWithContentsOfURL: [NSURL URLWithString: path]];
        UIImage * img = [UIImage imageWithData: imgData];
        if (img) {
            self.image = img;
            NSLog(@"Swapping in fake image %@ from URL: %@", img, path);
        }
    }
}

- (void)processPMData:(NSString*)data
{
    if (_overlays == nil)
        self.overlays = [NSMutableArray array];
    
    // read the bizarre pm format, which doesn't seem to be based on anything and just appends information
    // about each overlay beneath the previous one.
    NSArray * lines = [data componentsSeparatedByString: @"\n"];
    NSArray * ignored = @[@"localization", @"focallength", @"score", @"fov", @""];
    
    NSMutableDictionary * overlayDict = [NSMutableDictionary dictionary];
    for (NSString * line in lines) {
        NSArray * parts = [line componentsSeparatedByString: @"="];
        if ([ignored containsObject: [parts objectAtIndex: 0]])
            continue;
        
        if ([overlayDict objectForKey: [parts objectAtIndex: 0]] == nil)
            [overlayDict setObject:[parts objectAtIndex: 1] forKey: [parts objectAtIndex: 0]];
        else {
            [self addOverlay: [[AROverlay alloc] initWithDictionary: overlayDict]];
            overlayDict = [NSMutableDictionary dictionary];
            [overlayDict setObject:[parts objectAtIndex: 1] forKey: [parts objectAtIndex: 0]];
        }
    }
    
    if ([[overlayDict allKeys] count] > 0)
        [self addOverlay: [[AROverlay alloc] initWithDictionary: overlayDict]];
    if (_overlays == nil)
        self.overlays = [NSMutableArray array];
}
- (void)processChangeDetection
{
    if (_image == nil)
        @throw [NSException exceptionWithName: @"ProcessException" reason: @"You need to provide an image to the ARAugmentedPhoto before calling process." userInfo: nil];
    
    if (_site == nil )
        @throw [NSException exceptionWithName: @"ProcessException" reason: @"You cannot process change detection on an image without specifying a site." userInfo: nil];
    
    _image = [[ARManager shared] rotateImage:_image byOrientationFlag:_image.imageOrientation];
    
    ASIFormDataRequest * req = [self requestForChangeDetectionProcessing];
    ASIFormDataRequest * __weak __req = req;
    
    CGFloat jpegQuality = DEFAULT_JPEG_QUALITY;
    if ([[NSUserDefaults standardUserDefaults] floatForKey:@"jpegQuality"])
        jpegQuality = [[NSUserDefaults standardUserDefaults] floatForKey:@"jpegQuality"];
    
    [req setData:UIImageJPEGRepresentation(_image, jpegQuality) forKey:@"image"];
    [req setFailedBlock: ^(void) {
        _response = BackendResponseFailed;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
        [[ARManager shared] criticalRequestFailed: __req];
        if (_processingCompletionBlock) _processingCompletionBlock(self);
    }];
    [req setCompletionBlock: ^(void) {
        if ([[ARManager shared] handleResponseErrors: __req]) {
            [self processChangeDetectionPostComplete: __req];
            
        } else {
            _response = BackendResponseFailed;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
            if (_processingCompletionBlock) _processingCompletionBlock(self);
        }
    }];
    
    _response = BackendResponseUploading;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
    
    [req startAsynchronous];
}

- (void)processChangeDetectionPostComplete:(ASIFormDataRequest*)req
{
    [self startPollForChangeDetectionImageIdentifier: [[req responseJSON] objectForKey: @"imgId"]];
}

- (void)startPollForChangeDetectionImageIdentifier:(NSString*)ident
{
    _response = BackendResponseProcessing;
    _imageIdentifier = ident;
    _pollCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
    
    [_pollTimer invalidate];
    _pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(processChangeDetectionPoll) userInfo:nil repeats:NO];
}

- (void)processChangeDetectionPoll
{
    [_pollTimer invalidate];
    _pollTimer = nil;
    if (_pollCount == 20) {
        self.response = BackendResponseFailed;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
        return;
    }
    
//    NSMutableDictionary * args = [self processArguments];
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"static_result"])
//        [args setObject:@"true" forKey:@"specialResult"];
    
    NSMutableDictionary * args = [NSMutableDictionary dictionary];
    [args setObject:_site.identifier forKey:@"site"];
    [args setObject:_imageIdentifier forKey:@"imgId"];

    
    ASIHTTPRequest * req = [[ARManager shared] createRequest:REQ_SITE_CHANGE_DETECT_RESULT withMethod:@"GET" withArguments:args];
    ASIHTTPRequest * __weak __req = req;
    
    [req setCompletionBlock: ^(void) {
        NSString * response = [__req responseString];
        if ([response length] == 0) {
            _pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(processChangeDetectionPoll) userInfo:nil repeats:NO];
            _pollCount ++;
        } else {
            [self processChangeDetectionJSONData: [__req responseJSON]];
            self.response = BackendResponseFinished;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
            if (_processingCompletionBlock) _processingCompletionBlock(self);
        }
    }];
    [req startAsynchronous];
}
- (void)processChangeDetectionJSONData:(NSDictionary*)data
{
    [self processChangeDetectionJSONData: data forDisplayWithScale:1];
}

- (void)processChangeDetectionJSONData:(NSDictionary*)data forDisplayWithScale:(float)scale
{
    if ([data isKindOfClass: [NSDictionary class]] == NO)
        return;
    
    if (_overlays == nil)
        self.overlays = [NSMutableArray array];
    
    NSString * resultData = [data objectForKey:@"resultData"];
    SBJsonParser * parser = [SBJsonParser new];
    id resultDataObject = nil;
    
    @try {
        resultDataObject = [parser objectWithString: resultData];
        
        NSMutableDictionary *objects = [resultDataObject objectForKey: @"objects"];
        for(NSMutableDictionary *object in objects) {
            
            NSString * objectId = [object objectForKey:@"objectId"];
            NSString * objectLabel = [object objectForKey:@"objectLabel"];
            
            NSMutableDictionary *instances = [object objectForKey:@"instances"];
            
            for(NSMutableDictionary *instance in instances) {
                
                AROverlay *result = [[AROverlay alloc] initWithChangeDetectionDictionary:instance overlayId:objectId objectLabel:objectLabel];
                [result setSite: self.site];
                [self addOverlay: result];
            }
            
            
        }
        
        
        
    } @catch (NSException * e) {
        NSLog(@"JSON parse error: %@", [e description]);
    }

}

- (void)addOverlay:(AROverlay*)ar
{
    for (AROverlay * e in self.overlays)
        if ([e isEqual: ar])
            return;
    [self.overlays addObject: ar];
}

- (void)dealloc
{
    [_pollTimer invalidate];
    _pollTimer = nil;
}


#pragma mark - Overlay Information
- (NSSet *)groupNamesForOverlays
{
    NSMutableSet *set = [NSMutableSet set];
    for (AROverlay *overlay in _overlays) {
        if (overlay.name && overlay.name.length > 0) {
            [set addObject:overlay.name];
        }
    }
    return set;
}

- (NSArray *)overlaysForName:(NSString *)name
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name LIKE %@", name];
    NSArray *matchedOverlays = [_overlays filteredArrayUsingPredicate:pred];
    return matchedOverlays;
}

- (NSDictionary *)overlaysSortedByGroupName
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *name in [self groupNamesForOverlays]) {
        NSArray *array = [self overlaysForName:name];
        [dict setObject:array forKey:name];
    }
    
    NSPredicate *unknownPred = [NSPredicate predicateWithFormat:@"(name = nil) || (name.length == 0)"];
    NSArray *unknown = [_overlays filteredArrayUsingPredicate:unknownPred];
    if (unknown.count > 0) {
        [dict setObject:unknown forKey:@"unknown"];
    }
    
    return dict;
}
@end
