//
//  ARCameraVC_iPad.h
//  SquareCam 
//
//  Created by Demetri Miller on 5/2/13.
//
//

#import "ARCameraVC.h"

@class DMRotatableCameraHUD;

@interface ARCameraVC_iPad : ARCameraVC

@property(nonatomic, weak) IBOutlet DMRotatableCameraHUD *hud;
@property(nonatomic, weak) IBOutlet UIView *toolbarView;
@property(nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic, weak) IBOutlet UIButton *doneButton;

@property(nonatomic, weak) IBOutlet UIView *projectView;
@property(nonatomic, weak) IBOutlet UILabel *projectNameLabel;
@property(nonatomic, weak) IBOutlet UILabel *projectLocationLabel;

@property(nonatomic, weak) IBOutlet UIButton *cameraButton;



@end
