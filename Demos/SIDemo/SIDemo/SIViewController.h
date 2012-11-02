//
//  SIViewController.h
//  SIDemo
//
//  Created by Demetri Miller on 9/30/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SIViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UILabel *_loadingLabel;
    CATextLayer *_loadingLayer;
    
    UIImage *_image;
    UIImageView * _shrinking;
    CALayer * _shrinkingMask;
    UIImageView * _scanline;
    
    NSMutableArray *_layers;
    UIImagePickerController *_picker;
    IBOutlet UIView *_cameraOverlayView;
    BOOL _firstLoad;
}

- (IBAction)translateLayersOffscreen;
- (IBAction)resetLayerTransforms;
- (IBAction)takePicture:(id)sender;

@end
