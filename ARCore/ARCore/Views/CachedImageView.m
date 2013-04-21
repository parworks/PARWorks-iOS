//
//  CachedImageView.m
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


#import "CachedImageView.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "UIImage+ARCoreResources.h"

static NSOperationQueue * _downloadsRequestQueue = nil;
static NSCache * _imageCache = nil;

@implementation CachedImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    [self setClipsToBounds: YES];
    [self setPlaceholderImageName: @"placeholder.png"];
}

- (void)setPlaceholderImageName:(NSString*)name
{
    _placeholderImageName = name;
}

- (void)setImagePath:(NSString*)p
{
    if ([p isEqualToString: _path])
        return;
    
    _path = p;
    
    if ((p == nil) || ([p isKindOfClass: [NSNull class]])) {
        [self setImage: [UIImage arCoreImageNamed: _placeholderImageName]];
        return;
    } 
    
    if ([NSThread currentThread] != [NSThread mainThread]) {
        @throw @"You can only setImagePath: from the main thread!";
    }
    
    if (_downloadsRequestQueue == nil) {
        // create the network queue
        _downloadsRequestQueue = [[NSOperationQueue alloc] init];
        [_downloadsRequestQueue setMaxConcurrentOperationCount: 5];
    }

    if (_downloadOperation != nil) {
        [_downloadOperation cancel];
        _downloadOperation = nil;
    }
    
    if (!_imageCache) {
        _imageCache = [[NSCache alloc] init];
        [_imageCache setCountLimit: 60];
        [_imageCache setName: @"RAM Image Cache"];
    }
    
    NSString * resourceKey = [p substringFromIndex:7];
    BOOL resourceExists = ([_imageCache objectForKey: resourceKey] != nil);
    NSString * cachePath = [[NSString stringWithFormat:@"~/tmp/%@", resourceKey] stringByExpandingTildeInPath];
    
    if (!resourceExists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[cachePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"Seeking at: %@", cachePath);
        resourceExists = [[NSFileManager defaultManager] fileExistsAtPath: cachePath];
    }
    
    if (resourceExists == NO) {
        _downloadCompleted = NO;
        _downloadOperation = [NSBlockOperation blockOperationWithBlock:^(void) {
            NSString * fetchedPath = [NSString stringWithString: p];
            NSData * d = nil;
            UIImage * i = nil;

            d = [NSData dataWithContentsOfURL: [NSURL URLWithString: fetchedPath]];
            if (d != nil) {
                [d writeToFile:cachePath atomically:NO];
                i = [UIImage imageWithData: d];
                if (i) 
                    [_imageCache setObject: i forKey: resourceKey];
                else
                    i = [UIImage arCoreImageNamed: _placeholderImageName];
                    
            } else {
                [[NSData data] writeToFile:cachePath atomically:NO];
                
            }
            if (([fetchedPath isEqualToString: _path]) && (_downloadCompleted == NO)) {
                _downloadCompleted = YES;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock: ^(void){
                    [UIView transitionWithView:self duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        self.image = i;
                    } completion:^(BOOL finished) {
                        if (_loadCompletionBlock) {
                            _loadCompletionBlock(i);
                        }
                    }];
                }];
            }
            
            _downloadOperation = nil;
        }];
              
        [self setImage: nil];
        [_downloadsRequestQueue addOperation: _downloadOperation];
    
    } else {
        UIImage * i = [_imageCache objectForKey: resourceKey];
        if (!i) {
            i = [UIImage imageWithContentsOfFile: cachePath];
            if (i) 
                [_imageCache setObject: i forKey: resourceKey];
            else
                i = [UIImage arCoreImageNamed: _placeholderImageName];

        }
        _downloadCompleted = YES;
        [self setImage: i];
    }
}

- (void)removeFromSuperview
{
    [_downloadOperation cancel];
    [super removeFromSuperview];
}

- (void)dealloc
{
    [_downloadOperation cancel];
    _downloadOperation = nil;
}

@end
