//
//  DMRotatableView.h
//  SquareCam 
//
//  Created by Demetri Miller on 5/1/13.
//
//

#import <UIKit/UIKit.h>

@interface DMRotatableCameraHUD : UIView

- (void)rotateAccordingToDeviceOrientation;
- (UIInterfaceOrientation)currentDisplayedInterfaceOrientation;

@end
