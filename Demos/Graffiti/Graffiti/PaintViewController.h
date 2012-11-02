//
//  ViewController.h
//  SimplePaint
//
//  Created by Ben Gotow on 10/12/12.
//  Copyright (c) 2012 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaintViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;
@property (weak, nonatomic) IBOutlet UIView *paintView;

@end
