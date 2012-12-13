//
//  ARManager.m
//  PAR Works iOS SDK
//
//  Copyright 2012 PAR Works, Inc.
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


#import "ARManager.h"
#import "ARConstants.h"
#import "ASIHTTPRequest+JSONAdditions.h"
#import "NSData+Base64Encode.h"
#import <CommonCrypto/CommonHMAC.h>

static ARManager * sharedManager;

@implementation ARManager


#pragma mark -
#pragma mark Singleton Implementation

+ (ARManager *)shared
{
	@synchronized(self)
	{
		if (sharedManager == nil)
			sharedManager = [[self alloc] init];
	}
	return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if (sharedManager == nil) {
			sharedManager = [super allocWithZone:zone];
			return sharedManager;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)init
{
	self = [super init];
    
	if (self) {
        _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        _appUsername = @"joon";
    }
	return self;
}

#pragma mark -
#pragma mark Authentication

- (void)setApiKey:(NSString*)key andSecret:(NSString*)secret;
{
    _apiKey = key;
    _apiSecret = secret;
}

- (BOOL)locationEnabled
{
    return _locationEnabled;
}

- (void)setLocationEnabled:(BOOL)enabled
{
    _locationEnabled = enabled;
    
    if (_locationEnabled) {
        
        if (!_locationManager) {
            // start gathering location data
            _locationManager = [[CLLocationManager alloc] init];
            [_locationManager setDelegate: self];
            [_locationManager setDesiredAccuracy: 5];
        }
        [_locationManager startUpdatingHeading];
        [_locationManager startUpdatingLocation];

    } else {
        [_locationManager stopUpdatingHeading];
        [_locationManager stopUpdatingLocation];
    }
}

#pragma mark -
#pragma mark Device Position and Pose

- (CLLocation*)deviceLocation
{
    return [_locationManager location];
}

- (CLHeading*)deviceHeading
{
    return [_locationManager heading];
}


#pragma mark -
#pragma mark Creating Requests

- (NSURL*)urlForRequest:(NSString*)basePath withPathArgs:(NSDictionary*)args
{
    // chop off the leading / if there is one
    if ([basePath rangeOfString:@"/"].location == 0)
        basePath = [basePath substringFromIndex: 1];
    

    // create the full request path
    NSString * scheme = @"https";
    #ifdef DEBUG
    scheme = @"http";
    #endif

    NSMutableString * path = [NSMutableString stringWithFormat: @"%@://%@/%@", scheme, API_ROOT, basePath];

    NSString * argSeparator = @"?";
    for (NSString * key in args) {
        [path appendFormat:@"%@%@=%@", argSeparator, key, [args objectForKey: key]];
        argSeparator = @"&";
    }
    return [NSURL URLWithString: path];
}

- (ASIHTTPRequest*)createRequest:(NSString*)basePath withMethod:(NSString*)method withArguments:(NSDictionary*)args
{
    if (_apiKey == nil)
        @throw [NSException exceptionWithName:@"PAR Works API Error" reason:@"You need to set the API key before making API requests." userInfo:nil];
        
    // add the username argument, which is sent with every request
    NSMutableDictionary * expandedArgs = args ? [NSMutableDictionary dictionaryWithDictionary: args] : [NSMutableDictionary dictionary];
    
    // generate random salt based on the time
	NSString * salt = [NSString stringWithFormat: @"%.0f", [[NSDate date] timeIntervalSince1970]];

    // create a signature by taking the salt and encrypting it with the api secret
    NSString * sig = [self shaHashFor:salt withKey: _apiSecret];

    // attch to the request
//    [expandedArgs setObject:sig forKey:@"signature"];
//    [expandedArgs setObject:salt forKey:@"salt"];
//    [expandedArgs setObject:_apiKey forKey:@"apikey"];
    
    // create the full request path
    ASIHTTPRequest * h;
    NSURL *url;
//    url = [self urlForRequest: basePath withPathArgs: expandedArgs];
    if ([method isEqualToString: @"GET"]) {
        url = [self urlForRequest: basePath withPathArgs: expandedArgs];
        h = [[ASIHTTPRequest alloc] initWithURL: url];
    } else {
        url = [self urlForRequest:basePath withPathArgs:nil];
        h = [[ASIFormDataRequest alloc] initWithURL: url];
        for (NSString * key in expandedArgs)
            [(ASIFormDataRequest*)h setPostValue: [expandedArgs objectForKey: key] forKey: key];
    }
    
    [h setUserAgent:@"HD4AR-iOS"];
    [h setTimeOutSeconds: 60];
    [h addRequestHeader:@"Expect" value:@"100-Continue"];
    [h addRequestHeader:@"Content-Encoding" value:@"identity"];
    [h addRequestHeader:@"Content-Type" value:@"text/plain"];
    [h addRequestHeader:@"X-AppVersion" value: _appVersion];
    [h addRequestHeader:@"X-Consumer" value:@"iOS"];
    
    [h addRequestHeader:@"ApiKey" value:_apiKey];
    [h addRequestHeader:@"Salt" value:salt];
    [h addRequestHeader:@"Signature" value:sig];
    
    ASIHTTPRequest * __weak hh = h;
    [h setFailedBlock: ^(void) {
        [[ARManager shared] criticalRequestFailed: hh];
    }];
    

    return h;
}

- (ARAugmentedPhoto *)augmentPhotoUsingNearbySites:(UIImage*)image completion:(ARProcessingCompletionBlock)completion
{
    ARAugmentedPhoto * p = [[ARAugmentedPhoto alloc] initWithImage: image];
    p.processingCompletionBlock = completion;
    [p process];
    return p;
}

#pragma mark -
#pragma mark Managing and Finding Sites

- (void)addSite:(NSString*)identifier withCompletionBlock:(void (^)(void))completionBlock
{
    NSMutableDictionary * args = [NSMutableDictionary dictionaryWithCapacity: 2];
    [args setObject:identifier forKey:@"id"];
    [args setObject:@"surf" forKey:@"feature"];
    if (_locationEnabled) {
        [args setObject:[NSString stringWithFormat: @"%f", [[ARManager shared] deviceLocation].coordinate.latitude] forKey:@"lat"];
        [args setObject:[NSString stringWithFormat: @"%f", [[ARManager shared] deviceLocation].coordinate.longitude] forKey:@"lon"];
    }

    ASIHTTPRequest * req = [self createRequest:REQ_SITE_ADD withMethod:@"PUT" withArguments: args];
    ASIHTTPRequest * __weak weak = req;
    [req setCompletionBlock: ^(void) {
        [self handleResponseErrors: weak];
        if (completionBlock)
            completionBlock();
    }];
    [req startAsynchronous];
}

- (void)removeSite:(NSString*)identifier withCompletionBlock:(void (^)(void))completionBlock
{
    NSDictionary * args = [NSDictionary dictionaryWithObject:identifier forKey:@"site"];
    ASIHTTPRequest * req = [self createRequest:REQ_SITE_REMOVE withMethod:@"GET" withArguments: args];
    ASIHTTPRequest * __weak weak = req;
    [req setCompletionBlock: ^(void) {
        [self handleResponseErrors: weak];
        if (completionBlock)
            completionBlock();
    }];
    [req startAsynchronous];
}                                                               

- (void)sitesForCurrentAPIKey:(void (^)(NSArray *sites))completionBlock
{
    if (completionBlock)
        [completionBlock copy];
    
    ASIHTTPRequest *req = [self createRequest:REQ_SITE_LIST_ALL withMethod:@"GET" withArguments:nil];
    ASIHTTPRequest * __weak blockReq = req;
    [req setCompletionBlock: ^(void) {
        [self handleResponseErrors: blockReq];
        NSArray *rawSites = [blockReq responseJSON];
        
        NSMutableArray *sites = [NSMutableArray array];
        for (NSDictionary *dict in rawSites) {
            [sites addObject:[[ARSite alloc] initWithSummaryDictionary:dict]];
        }
        
        if (completionBlock)
            completionBlock(sites);
    }];
    [req startAsynchronous];
}

- (void)findNearbySites:(int)resolution withCompletionBlock:(void (^)(NSArray *))completionBlock
{
    if (!_locationEnabled)
        @throw [NSException exceptionWithName:@"PAR Works API Error" reason:@"You need to enable location by calling setLocationEnabled: before finding nearby sites." userInfo:nil];
    
    // create the full request path
    NSMutableDictionary * args = [NSMutableDictionary dictionaryWithCapacity:3];
    [args setObject:[NSString stringWithFormat: @"%f", [self deviceLocation].coordinate.latitude] forKey:@"lat"];
    [args setObject:[NSString stringWithFormat: @"%f", [self deviceLocation].coordinate.longitude] forKey:@"lon"];
    [args setObject:[NSString stringWithFormat: @"%d", resolution] forKey:@"resolution"];
    ASIHTTPRequest * req = [self createRequest:REQ_SITE_NEARBY withMethod:@"GET" withArguments: args];
    ASIHTTPRequest * __weak weak = req;

    [req setCompletionBlock: ^(void) {
        if ([self handleResponseErrors: weak]) {
            NSDictionary * json = [weak responseJSON];
            NSArray * sites = [json objectForKey: @"sites"];
            if (completionBlock)
                completionBlock(sites);
        }
    }];
}

#pragma mark Convenience Functions for Image Picking

- (UIImage*)rotateImage:(UIImage*)img byOrientationFlag:(UIImageOrientation)orient
{
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetWidth(imgRef);
    CGFloat             height = CGImageGetHeight(imgRef);
    CGAffineTransform   transform = CGAffineTransformIdentity;
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGSize              imageSize = bounds.size;
    CGFloat             boundHeight;
    
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        default:
            // image is not auto-rotated by the photo picker, so whatever the user
            // sees is what they expect to get. No modification necessary
            transform = CGAffineTransformIdentity;
            return img;
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ((orient == UIImageOrientationDown) || (orient == UIImageOrientationRight) || (orient == UIImageOrientationUp)){
        // flip the coordinate space upside down
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}


#pragma mark -
#pragma mark Handling Errors


- (BOOL)handleResponseErrors:(ASIHTTPRequest*)req
{
    id json = [req responseJSON];
    if (([req responseStatusCode] != 200) ||
        ([json isKindOfClass: [NSDictionary class]] && [json objectForKey: @"reason"])) {
        [self criticalRequestFailed: req];
        return NO;
    }
    return YES;
}

- (void)criticalRequestFailed:(ASIHTTPRequest*)req
{
    NSLog(@"API Request Failed: %@ returned %d: %@", [[req url] absoluteString], [req responseStatusCode], [req responseString]);
    
    id json = [req responseJSON];
    NSString * msg;
    
    if ([json isKindOfClass: [NSDictionary class]] && [json objectForKey: @"reason"])
        msg = [json objectForKey: @"reason"];
    else
        msg = @"The data could not be loaded. Please check the app's log for detailed information.";

    UIAlertView * v = [[UIAlertView alloc] initWithTitle:@"Unexpected Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [v show];
}

#pragma mark -
#pragma mark Convenience Functions for Networking

- (NSString*)shaHashFor:(NSString*)data withKey:(NSString*)key
{
	unsigned char HMACString[CC_SHA256_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA256, [key UTF8String], [key lengthOfBytesUsingEncoding: NSUTF8StringEncoding], [data UTF8String], [data lengthOfBytesUsingEncoding: NSUTF8StringEncoding], HMACString) ;
	NSData *HMACData = [[NSData alloc] initWithBytes: HMACString length: sizeof(HMACString)];
	return [HMACData base64EncodeWithLength: CC_SHA256_DIGEST_LENGTH];
}

@end
