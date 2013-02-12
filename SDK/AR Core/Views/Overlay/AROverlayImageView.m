//
//  AROverlayImageView.m
//  ViewerDemo
//
//  Created by Demetri Miller on 2/2/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import "AROverlayImageView.h"
#import "AROverlayView+Animations.h"

@implementation AROverlayImageView

- (id)initWithOverlay:(AROverlay *)overlay
{
    self = [super initWithOverlay:overlay];
    if (self) {        
        self.animDelegate = self;
    }
    return self;
}

#pragma mark - AROverlayViewAnimationDelegate
- (void)focusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    if (!_imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _imageView.alpha = 0.0;
        [self addSubview:_imageView];
        
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _activity.hidesWhenStopped = YES;
        [_activity stopAnimating];
        [self addSubview:_activity];
    }

    [_activity startAnimating];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.overlay.contentProvider]];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
        UIImage *img = [UIImage imageWithData:data];
        if (img != nil) {
            self.imageView.layer.contents = (id)img.CGImage;
        }
        [_activity stopAnimating];
    }];
    
    __weak AROverlayImageView * weakSelf = self;
    [self animateBounceFocusWithParent:parent centeredBlock:^{
        weakSelf.imageView.alpha = 1.0;
    } complete:nil];
}

- (void)unfocusOverlayView:(AROverlayView *)overlayView inParent:(ARAugmentedView *)parent
{
    __weak AROverlayImageView * weakSelf = self;
    [self animateBounceUnfocusWithParent:parent uncenteredBlock:^{
        weakSelf.imageView.alpha = 0.0;
    } complete:nil];
}

@end
