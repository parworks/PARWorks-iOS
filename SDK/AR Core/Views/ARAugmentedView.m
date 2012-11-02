//
//  AROverlayView.m
//  PARWorks iOS SDK
//
//  Copyright 2012 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "AROverlayUtil.h"
#import "AROverlayView.h"
#import "ARAugmentedView.h"
#import "AROverlay.h"
#import "AROverlayAnimation.h"
#import "AROverlayPoint.h"

#define AROverlayZoomWidth 120.0
#define AROverlayZoomHeight 120.0


@interface ARAugmentedView()
@property(nonatomic, strong) UIControl *dimView;
@property(nonatomic, strong) AROverlayAnimation *overlayAnimation;
@end


@implementation ARAugmentedView


#pragma mark - Lifecycle
// For now, we don't want to use this method ever...
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
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor blackColor];

    self.overlayAnimation = [[AROverlayAnimation alloc] init];
    _overlayViews = [[NSMutableArray alloc] init];
    
    self.overlayImageView = [[UIImageView alloc] initWithFrame: self.bounds];
    _overlayImageView.userInteractionEnabled = YES;
    [self addSubview: _overlayImageView];
    
    self.dimView = [[UIControl alloc] initWithFrame:_overlayImageView.bounds];
    [_dimView addTarget:self action:@selector(dimViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    _dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    _dimView.alpha = 0.0;
    [_overlayImageView addSubview: _dimView];
}

- (void)setAugmentedPhoto:(ARAugmentedPhoto*)p
{
    _augmentedPhoto = p;
    _overlayZoomed = NO;
        
    [self updateOverlays];
}


#pragma mark - Layout

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_dimView setFrame: [self bounds]];
    [self repositionOverlays];
}

- (void)updateOverlays
{
    [_overlayViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_overlayViews removeAllObjects];
     
    _overlayScaleFactor = [self scaleFactorForBounds:self.bounds withImage:_augmentedPhoto.image];
    
    for (AROverlay *overlay in [_augmentedPhoto overlays]) {
        AROverlayView * view = nil;
        
        if (_delegate && [_delegate respondsToSelector:@selector(overlayViewForOverlay:)]) {
            view = [_delegate overlayViewForOverlay:overlay];
        } else {
            view = [[AROverlayView alloc] initWithOverlay: overlay];
            view.animDelegate = _overlayAnimation;
            [view addDemoSubviewToOverlay];
        }
        
        // the delegate has the option of returning nil to hide the overlay
        if (view) {
            [view addTarget:self action:@selector(overlayTapped:) forControlEvents:UIControlEventTouchUpInside];
            [view applyAttachmentStyleWithParent:self];
            [_overlayImageView addSubview: view];
            [_overlayViews addObject: view];
        }
    }
    
    _overlayImageView.frame = [self centeredAspectFitFrameForImage: _augmentedPhoto.image];
    _overlayImageView.image = _augmentedPhoto.image;
}

- (void)repositionOverlays
{
    _overlayScaleFactor = [self scaleFactorForBounds:self.bounds withImage:_augmentedPhoto.image];
    [_overlayImageView setFrame: [self centeredAspectFitFrameForImage: _augmentedPhoto.image]];
    for (AROverlayView * view in _overlayViews)
        [view applyAttachmentStyleWithParent:self];
}

#pragma mark - Dim View User Interaction
- (void)dimViewTapped:(id)sender
{
    if (_focusedView) {
        [self overlayTapped:_focusedView];
    }
}


#pragma mark - Overlay User Interaction
- (void)overlayTapped:(id)sender
{
    if (_focusedView) {
        [self resetFocusedOverlay:_focusedView];
        _focusedView = nil;
    } else {
        _focusedView = (AROverlayView *)sender;
        [self zoomSingleOverlay:sender];
    }
}

- (void)zoomSingleOverlay:(AROverlayView *)overlay
{
    [UIView animateWithDuration:0.3 animations:^{
        _dimView.alpha = 1.0;
        _overlayZoomed = YES;
    }];
 
    [_overlayImageView bringSubviewToFront:overlay];
    
    // TODO: Animation needs a completion block.
    [overlay focusInParent:self];
}

- (void)resetFocusedOverlay:(AROverlayView *)overlay
{
    [UIView animateWithDuration:0.3 animations:^{
        _dimView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _overlayZoomed = NO;
    }];
    
    // TODO: Animation needs a completion block.
    [overlay unfocusInParent:self];
}


#pragma mark - Convenience

- (CGPoint)focusedOverlayCenter:(AROverlayView *)overlay
{
    return CGPointMake((_overlayImageView.frame.size.width/2) - (overlay.frame.size.width/2), (_overlayImageView.frame.size.height/2) - (overlay.frame.size.height/2));
}

- (CGFloat)scaleFactorForBounds:(CGRect)bounds withImage:(UIImage *)image
{
    CGFloat scale = 1.0;
    CGFloat widthRatio = bounds.size.width / image.size.width;
    CGFloat heightRatio = bounds.size.height / image.size.height;
    
    scale = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    return scale;
}

- (CGRect)centeredAspectFitFrameForImage:(UIImage *)image
{
    if (_augmentedPhoto.image == nil)
        return [self bounds];
    
    CGRect frame = CGRectMake(0, 0, image.size.width * _overlayScaleFactor, image.size.height * _overlayScaleFactor);
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    frame.origin.x = center.x - (frame.size.width/2);
    frame.origin.y = center.y - (frame.size.height/2);
    return frame;
}

@end
