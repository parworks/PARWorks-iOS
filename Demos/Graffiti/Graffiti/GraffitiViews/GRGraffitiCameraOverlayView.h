//
//  GRGraffitiCameraOverlayView.h
//  Graffiti
//
//  Created by Demetri Miller on 3/6/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "GRCameraOverlayView.h"

@interface GRGraffitiCameraOverlayView : GRCameraOverlayView

- (ARAugmentedPhoto *)augmentedPhoto;

/// Methods overridden from superclass.
- (void)resetToLiveCameraInterface;
- (void)setAugmentedPhoto:(ARAugmentedPhoto *)augmentedPhoto;

@end
