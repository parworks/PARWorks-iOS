//
//  ARCentroidView.h
//  ARCore
//
//  Created by Ben Gotow on 4/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARCentroidView : UIView
{
    NSTimer * _timer;
    int _step;
}
@property (nonatomic, assign) BOOL drawPulsingCircle;

@end
