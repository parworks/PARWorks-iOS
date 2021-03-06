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

#define PHOTOS_DIRECTORY [@"~/Documents/Photos/" stringByExpandingTildeInPath]

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
    
    ASIFormDataRequest * req = [self requestForProcessing];
    ASIFormDataRequest * __weak __req = req;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPLOAD_STATUS_CHANGE object: @"Upload Starting..."];
    
    NSData *imageData = [[ARManager shared] imageDataFromImage:_image metadata:_imageMetadata];
    
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
    
    self.responseDictionary = data;
    
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
