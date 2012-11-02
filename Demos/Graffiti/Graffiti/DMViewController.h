//
//  DMViewController.h
//  Graffiti
//
//  Created by Demetri Miller on 10/12/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HNGraffitiView;
@class HNSprayCanLoadingView;

@interface DMViewController : UIViewController
{
    __weak IBOutlet UIButton *_btn;
    __weak IBOutlet UIButton *_loadButton;
    HNGraffitiView *_iv;
    HNSprayCanLoadingView *_loadingView;
    
}
- (IBAction)reveal:(id)sender;
- (IBAction)showLoadingView:(id)sender;


@end
