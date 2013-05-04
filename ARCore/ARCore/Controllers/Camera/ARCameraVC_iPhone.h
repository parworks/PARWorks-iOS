//
//  ARCameraVC_iPhone.h
//  SquareCam 
//
//  Created by Demetri Miller on 5/2/13.
//
//

#import "ARCameraVC.h"

@class ARCameraOverlayTooltip;
@class GRCameraOverlayToolbar;

@interface ARCameraVC_iPhone : ARCameraVC

@property(nonatomic, strong) GRCameraOverlayToolbar *toolbar;
@property(nonatomic, strong) ARCameraOverlayTooltip *tooltip;

@end
