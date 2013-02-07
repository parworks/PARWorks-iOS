//
//  AROverlayView.m
//  PAR Works iOS SDK
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


#import "ARAugmentedView.h"
#import "AROverlay.h"
#import "AROverlayAnimation.h"
#import "AROverlayViewFactory.h"
#import "AROverlayOutlineView.h"
#import "AROverlayPoint.h"
#import "AROverlayUtil.h"
#import "AROverlayView.h"
#import "ARTotalAugmentedImagesView.h"
#import "UIViewAdditions.h"

#define AROverlayZoomWidth 120.0
#define AROverlayZoomHeight 120.0


@interface ARAugmentedView()
@property(nonatomic, strong) UIControl *dimView;
@property(nonatomic, strong) AROverlayAnimation *overlayAnimation;
@end


@implementation ARAugmentedView


#pragma mark - Lifecycle
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
    self.showOutlineViewsOnly = NO;
    self.animateOutlineViewDrawing = YES;
    self.overlayImageViewContentMode = UIViewContentModeScaleAspectFit;
    [self addTarget:self action:@selector(blackBackgroundTapped) forControlEvents:UIControlEventTouchUpInside];

    self.overlayAnimation = [[AROverlayAnimation alloc] init];
    _overlayViews = [[NSMutableArray alloc] init];
    _outlineViews = [[NSMutableArray alloc] init];
    
    self.overlayImageView = [[UIImageView alloc] initWithFrame: self.bounds];
    _overlayImageView.userInteractionEnabled = YES;
    [self addSubview: _overlayImageView];
    
    self.dimView = [[UIControl alloc] initWithFrame:_overlayImageView.bounds];
    [_dimView addTarget:self action:@selector(dimViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    _dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    _dimView.alpha = 0.0;
    [_overlayImageView addSubview: _dimView];
    
    self.totalAugmentedImagesView = [[ARTotalAugmentedImagesView alloc] init];
    _totalAugmentedImagesView.hidden = YES;
    [self addSubview: _totalAugmentedImagesView];
}

- (void)setAugmentedPhoto:(ARAugmentedPhoto*)p
{
    _augmentedPhoto = p;
    _overlayZoomed = NO;
        
    [self updateOverlays];
    [self updateOutlines];
    _overlayImageView.frame = [self centeredAspectScaleFrameForImage: _augmentedPhoto.image];
    _overlayImageView.image = _augmentedPhoto.image;
    
    CGFloat x = (self.bounds.size.width - _totalAugmentedImagesView.frame.size.width - 10);
    [_totalAugmentedImagesView setFrameX:x];
    [_totalAugmentedImagesView setFrameY:10];
}


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_dimView setFrame: [self bounds]];
    [self repositionOverlays];
}

- (void)setShowOutlineViewsOnly:(BOOL)showOutlineViewsOnly
{
    _showOutlineViewsOnly = showOutlineViewsOnly;
    if (_showOutlineViewsOnly) {
        [_overlayViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_overlayViews removeAllObjects];
    } else {
        [self updateOverlays];
    }
}

- (void)updateOverlays
{
    if (_showOutlineViewsOnly)
        return;
    
    [_overlayViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_overlayViews removeAllObjects];
     
    _overlayScaleFactor = [self scaleFactorForBounds:self.bounds withImage:_augmentedPhoto.image];
    
    for (AROverlay *overlay in [_augmentedPhoto overlays]) {
        AROverlayView * view = nil;
        
        if (_delegate && [_delegate respondsToSelector:@selector(overlayViewForOverlay:)]) {
            view = [_delegate overlayViewForOverlay:overlay];
        } else {
            view = [AROverlayViewFactory viewWithOverlay:overlay];
        }
        
        // the delegate has the option of returning nil to hide the overlay
        if (view) {
            [view addTarget:self action:@selector(overlayTapped:) forControlEvents:UIControlEventTouchUpInside];
            [view applyAttachmentStyleWithParent:self];
            [_overlayImageView addSubview: view];
            [_overlayViews addObject: view];
        }
    }    
}

- (void)updateOutlines
{
    [_outlineViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_outlineViews removeAllObjects];
    
    _overlayScaleFactor = [self scaleFactorForBounds:self.bounds withImage:_augmentedPhoto.image];
    
    for (int i=0; i<_augmentedPhoto.overlays.count; i++) {
        AROverlay *overlay = _augmentedPhoto.overlays[i];
        AROverlayOutlineView *view;
        
        if (_delegate && [_delegate respondsToSelector:@selector(outlineViewForOverlay:)]) {
            view = [_delegate outlineViewForOverlay:overlay];
        } else {
            view = [[AROverlayOutlineView alloc] initWithOverlay:overlay scaleFactor:_overlayScaleFactor];
        }
        
        if (view) {
            if (i < _overlayViews.count) {
                AROverlayView *overlayView = _overlayViews[i];
                overlayView.outlineView = view;
            }

            [view drawAnimated:_animateOutlineViewDrawing];
            [_overlayImageView addSubview:view];
            [_outlineViews addObject:view];
        }
        
    }
}

- (void)repositionOverlays
{
    _overlayScaleFactor = [self scaleFactorForBounds:self.bounds withImage:_augmentedPhoto.image];
    [_overlayImageView setFrame: [self centeredAspectScaleFrameForImage: _augmentedPhoto.image]];
    
    [self resetFocusedOverlay];
    for (AROverlayView * view in _overlayViews)
        [view applyAttachmentStyleWithParent:self];

    [self updateOutlines];
}

#pragma mark - Dim View User Interaction
- (void)dimViewTapped:(id)sender
{
    if (_focusedOverlayView)
        [self overlayTapped:_focusedOverlayView];
}


#pragma mark - Overlay User Interaction

- (void)blackBackgroundTapped
{
    [self resetFocusedOverlay];
}

- (void)overlayTapped:(AROverlayView *)sender
{
    if (_focusedOverlayView) {
        [self resetFocusedOverlay];
    } else {
        _focusedOverlayView = sender;
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

- (void)resetFocusedOverlay
{
    if (!_focusedOverlayView)
        return;
    
    [UIView animateWithDuration:0.3 animations:^{
        _dimView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _overlayZoomed = NO;
    }];
    
    // TODO: Animation needs a completion block.
    [_focusedOverlayView unfocusInParent:self];
    _focusedOverlayView = nil;
}

- (void)setVisibile:(BOOL)visible forOverlayViewsWithName:(NSString *)name
{
    for (AROverlayView *v in _overlayViews) {
        if ([v.overlay.name isEqualToString:name]) {
            v.hidden = !visible;
        }
    }
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
    
    switch (_overlayImageViewContentMode) {
        case UIViewContentModeScaleAspectFill:
            scale = (widthRatio > heightRatio) ? widthRatio : heightRatio;
            break;
        case UIViewContentModeScaleAspectFit:
        default:
            scale = (widthRatio > heightRatio) ? heightRatio : widthRatio;
            break;
    }

    return scale;
}

- (CGRect)centeredAspectScaleFrameForImage:(UIImage *)image
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
