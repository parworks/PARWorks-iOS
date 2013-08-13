//
//  ARAugmentedImage.h
//  ARCore
//
//  Created by Demetri Miller on 8/6/13.
//  Copyright (c) 2013 PARWorks. All rights reserved.
//

#import "ARSiteImage.h"
#import "ARConstants.h"

@class ARSite;

/**
    Model object for the "/ar/site/image/augmented/list" endpoint.
    Why aren't we resuing the other augmented image models? For some
    reason the key-value pairs are different. It's just easier this way.
 */
@interface ARAugmentedImage : ARSiteImage

- (NSDictionary *)output;

@end
