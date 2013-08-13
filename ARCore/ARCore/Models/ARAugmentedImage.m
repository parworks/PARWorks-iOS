//
//  ARAugmentedImage.m
//  ARCore
//
//  Created by Demetri Miller on 8/6/13.
//  Copyright (c) 2013 PARWorks. All rights reserved.
//

#import "ARAugmentedImage.h"
#import "ARSite.h"

@implementation ARAugmentedImage

#pragma mark - Overrides
- (NSDictionary *)output
{
    return _dict[@"output"];
}

- (NSArray *)overlays
{
    NSMutableArray *overlays;
    NSArray *rawOverlays = _dict[@"output"][@"overlays"];
    
    if (rawOverlays && rawOverlays.count > 0) {
        overlays = [NSMutableArray array];
        for (NSDictionary *dict in rawOverlays) {
            AROverlay *o = [[AROverlay alloc] initWithDictionary:dict];
            [overlays addObject:o];
        }
    }
    
    return overlays;
}

- (NSURL *)urlForSize:(int)size
{
    NSString * url = nil;
    if (size < 333)
        url = _dict[@"imgGalleryPath"];
    else if (size < 768)
        url = _dict[@"imgContentPath"];
    else
        url = _dict[@"imgPath"];
    
    url = [url substringFromIndex: [url rangeOfString:@"http" options:NSBackwardsSearch].location];
    return [NSURL URLWithString: url];
}

- (NSString *)urlStringForSiteImageSize:(ARSiteImageSize)sizeType
{
    NSString *key;
    switch (sizeType) {
        case ARSiteImageSize_Gallery:
            key = @"imgGalleryPath";
            break;
        case ARSiteImageSize_Content:
            key = @"imgContentPath";
            break;
        case ARSiteImageSize_Full:
            key = @"imgPath";
            break;
        default:
            NSLog(@"Invalid size type... returning content size.");
            key = @"content_size";
            break;
    }
    
    return _dict[key];
}

- (NSTimeInterval)timestamp {
    // Dividing by 1000 since the API returns timestamps in milliseconds.
    return ([[_dict objectForKey: @"time"] doubleValue]/1000.0);
}

@end
