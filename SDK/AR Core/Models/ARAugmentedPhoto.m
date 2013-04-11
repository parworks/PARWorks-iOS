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

- (void)process
{
    if (_image == nil)
        @throw [NSException exceptionWithName: @"ProcessException" reason: @"You need to provide an image to the ARAugmentedPhoto before calling process." userInfo: nil];
    
    if ((_site == nil) && ([[ARManager shared] locationEnabled] == NO))
        @throw [NSException exceptionWithName: @"ProcessException" reason: @"You cannot process an image without specifying a site or enabling location services in the ARManager." userInfo: nil];

    _image = [[ARManager shared] rotateImage:_image byOrientationFlag:_image.imageOrientation];

    ASIFormDataRequest * req = [self requestForProcessing];
    ASIFormDataRequest * __weak __req = req;

    [req setData:UIImageJPEGRepresentation(_image, 0.45) forKey:@"image"];
    [req setFailedBlock: ^(void) {
        _response = BackendResponseFailed;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
        [[ARManager shared] criticalRequestFailed: __req];
        if (_processingCompletionBlock) _processingCompletionBlock(self);
    }];
    [req setCompletionBlock: ^(void) {
        if ([[ARManager shared] handleResponseErrors: __req]) {
            [self processPostComplete: __req];

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
    _pollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(processPoll) userInfo:nil repeats:NO];
}

- (void)processPoll
{
    _pollTimer = nil;
    if (_pollCount == 20) {
        self.response = BackendResponseFailed;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AUGMENTED_PHOTO_UPDATED object: self];
        return;
    }
    
    ASIHTTPRequest * req = [[ARManager shared] createRequest:REQ_IMAGE_AUGMENT_RESULT withMethod:@"GET" withArguments:[self processArguments]];
    ASIHTTPRequest * __weak __req = req;
    
    [req setCompletionBlock: ^(void) {
        if ([__req responseStatusCode] != 200) {
            _pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(processPoll) userInfo:nil repeats:NO];
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
    
}

@end
