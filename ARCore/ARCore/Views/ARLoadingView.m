//
//  ARLoadingView.m
//  LoadingView
//
//  Created by Ben Gotow on 2/13/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARLoadingView.h"

@implementation ARLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    [self setUserInteractionEnabled: NO];
    
    _block1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15,15)];
    _block1.layer.cornerRadius = 10;
    _block1.transform = CGAffineTransformMakeRotation(M_PI / 100);
    [self addSubview: _block1];
    
    _block2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15,15)];
    _block2.layer.cornerRadius = 10;
    _block2.transform = CGAffineTransformMakeRotation(M_PI / 100);
    [self addSubview: _block2];
    
    [self setClipsToBounds: YES];
    [self setBackgroundColor: [UIColor clearColor]];
    [self.layer setBorderWidth: 4];
    [self setAlpha: 0];
    
    [self setLoadingViewStyle:ARLoadingViewStyleWhite];
}

- (void)startAnimating
{
    [_block1 setCenter: CGPointMake(-15, self.frame.size.height + 15)];
    [_block2 setCenter: CGPointMake(self.frame.size.width + 15, -15)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration: 1];
    [UIView setAnimationRepeatCount: INFINITY];
    [self setTransform: CGAffineTransformMakeRotation(M_PI/2)];
    [_block1 setCenter: CGPointMake(self.frame.size.width + 15, -15)];
    [_block2 setCenter: CGPointMake(-15, self.frame.size.height + 15)];
    [UIView commitAnimations];
    
    [UIView beginAnimations: nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [self setAlpha: 0.6];
    [UIView commitAnimations];
}

- (void)stopAnimating
{
    [UIView beginAnimations: nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [self setAlpha: 0];
    [UIView commitAnimations];
}

- (void)setLoadingViewStyle:(ARLoadingViewStyle)loadingViewStyle{
    _loadingViewStyle = loadingViewStyle;
    switch (_loadingViewStyle) {
        case ARLoadingViewStyleBlack:
            _block1.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            _block2.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            [self.layer setBorderColor: [[UIColor colorWithWhite:0 alpha:1] CGColor]];
            break;
        case ARLoadingViewStyleWhite:
        default:
            _block1.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
            _block2.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
            [self.layer setBorderColor: [[UIColor colorWithWhite:1 alpha:1] CGColor]];
            break;
    }
}

@end