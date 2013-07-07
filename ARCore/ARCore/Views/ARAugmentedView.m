//
//  ARAugmentedView.m
//  PAR Works iOS SDK
//
//  Copyright 2013 PAR Works, Inc.
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

#import "ARSite.h"
#import "ARAugmentedPhoto.h"
#import "ARAugmentedView.h"
#import "ARLoadingView.h"
#import "AROverlay.h"
#import "AROverlayAnimation.h"
#import "AROverlayViewFactory.h"
#import "AROverlayOutlineView.h"
#import "AROverlayPoint.h"
#import "AROverlayUtil.h"
#import "AROverlayView.h"
#import "ARTotalAugmentedImagesView.h"
#import "UIViewAdditions.h"
#import "AROverlayTitleView.h"
#import <MediaPlayer/MediaPlayer.h>

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen) name:NOTIF_DISMISS_NAVCONTROLLER_FULLSCREEN object:nil];
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.showOutlineViewsOnly = NO;
    self.animateOutlineViewDrawing = YES;
    self.overlayImageViewContentMode = UIViewContentModeScaleAspectFit;
    [self addTarget:self action:@selector(blackBackgroundTapped) forControlEvents:UIControlEventTouchUpInside];

    self.overlayAnimation = [[AROverlayAnimation alloc] init];
    _overlayViews = [[NSMutableArray alloc] init];
    _outlineViews = [[NSMutableArray alloc] init];
    _overlayTitleViews = [[NSMutableArray alloc] init];
    
    self.overlayImageView = [[UIImageView alloc] initWithFrame: self.bounds];
    _overlayImageView.userInteractionEnabled = YES;
    [self addSubview: _overlayImageView];
    
    self.dimView = [[UIControl alloc] initWithFrame: CGRectMake(0, 0, 3000, 3000)];
    [_dimView addTarget:self action:@selector(dimViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    _dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _dimView.alpha = 0.0;
    [_overlayImageView addSubview: _dimView];
    
    self.totalAugmentedImagesView = [[ARTotalAugmentedImagesView alloc] init];
    _totalAugmentedImagesView.hidden = YES;
    [self addSubview: _totalAugmentedImagesView];
    
    self.loadingView = [[ARLoadingView alloc] initWithFrame: CGRectMake(0, 0, 36, 36)];
    [self addSubview: _loadingView];
    [_loadingView startAnimating];
}

- (void)setAugmentedPhoto:(ARAugmentedPhoto*)p
{
    _augmentedPhoto = p;
    _overlayZoomed = NO;
    _overlayImageView.image = _augmentedPhoto.image;
    if ((_augmentedPhoto) && (_augmentedPhoto.image)) {
        [_loadingView stopAnimating];
        [self attachOverlayViews];
    } else if (!_augmentedPhoto) {
        [self removeSupplementalViews];
    }
}

#pragma mark - Layout
- (void)setBounds:(CGRect)bounds
{
    CGFloat duration = _shouldAnimateViewLayout ? _viewLayoutAnimationDuration : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [super setBounds:bounds];
        [self layoutForCurrentViewMetrics];
    }];
}

- (void)setFrame:(CGRect)frame
{
    CGFloat duration = _shouldAnimateViewLayout ? _viewLayoutAnimationDuration : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [super setFrame:frame];
        [self layoutForCurrentViewMetrics];
    }];
}

- (void)setCenter:(CGPoint)center
{
    CGFloat duration = _shouldAnimateViewLayout ? _viewLayoutAnimationDuration : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [super setCenter:center];
        [self layoutForCurrentViewMetrics];
    }];
}

// Layout our subviews based on the current frame of the view
- (void)layoutForCurrentViewMetrics
{
    [_dimView setFrame: [self bounds]];
    [super layoutSubviews];

    if(CGPointEqualToPoint(_loadingViewPoint, CGPointMake(0, 0)))
        [_loadingView setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
    else
        [_loadingView setCenter:_loadingViewPoint];
    
    CGFloat x = (self.bounds.size.width - _totalAugmentedImagesView.frame.size.width - 10);
    [_totalAugmentedImagesView setFrameX:x];
    [_totalAugmentedImagesView setFrameY:10];
    
    _overlayScaleFactor = [self scaleFactorForBounds:self.bounds withImage:_augmentedPhoto.image];
    [_overlayImageView setBounds: [self centeredAspectScaleBoundsForImage: _augmentedPhoto.image]];
    [_overlayImageView setCenter: CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
    
    // reattach the overlay views
    [self resetFocusedOverlay];
    [_overlayViews makeObjectsPerformSelector:@selector(layoutWithinParent:) withObject:self];
    [_outlineViews makeObjectsPerformSelector:@selector(layoutWithinParent:) withObject:self];
    [_overlayTitleViews makeObjectsPerformSelector:@selector(layoutWithinParent:) withObject: self];
}

- (void)setShowOutlineViewsOnly:(BOOL)showOutlineViewsOnly
{
    _showOutlineViewsOnly = showOutlineViewsOnly;
    if (_augmentedPhoto)
        [self attachOverlayViews];
}

- (void)attachOverlayViews
{
    [self removeSupplementalViews];

    for (int i=0; i < _augmentedPhoto.overlays.count; i++) {
        AROverlay *overlay = _augmentedPhoto.overlays[i];
        AROverlayView * overlayView = nil;
        AROverlayOutlineView * outlineView = nil;
        
        if (!_showOutlineViewsOnly) {
            if (_delegate && [_delegate respondsToSelector:@selector(overlayViewForOverlay:)]) {
                overlayView = [_delegate overlayViewForOverlay:overlay];
            } else {
                overlayView = [AROverlayViewFactory viewWithOverlay:overlay];
            }
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(outlineViewForOverlay:)]) {
            outlineView = [_delegate outlineViewForOverlay:overlay];
        } else {
            outlineView = [[AROverlayOutlineView alloc] initWithOverlay:overlay];
        }
        
        // the delegate has the option of returning nil to hide the overlay
        if (overlayView) {
            [overlayView addTarget:self action:@selector(overlayTapped:) forControlEvents:UIControlEventTouchUpInside];
            [overlayView setTag: i];
            [_overlayViews addObject: overlayView];
            [_overlayImageView addSubview: overlayView];
        }

        if (outlineView) {
            overlayView.outlineView = outlineView;
            [_outlineViews addObject: outlineView];
            [_overlayImageView addSubview: outlineView];
        }
        
        if (!_showOutlineViewsOnly && overlay.title) {
            AROverlayTitleView * tv = [[AROverlayTitleView alloc] initWithOverlay: overlay];
            [tv addTarget:self action:@selector(overlayTapped:) forControlEvents:UIControlEventTouchUpInside];
            [tv setTag: i];
            [_overlayTitleViews addObject: tv];
            [_overlayImageView addSubview: tv];
        }
    }
    [self setNeedsLayout];
    [self layoutForCurrentViewMetrics];
}

- (void)removeSupplementalViews
{
    [_overlayViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_overlayViews removeAllObjects];
    
    [_outlineViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_outlineViews removeAllObjects];
    
    [_overlayTitleViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_overlayTitleViews removeAllObjects];
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

- (void)overlayTapped:(UIView *)sender
{
    int overlayIndex = [sender tag];
    
    if (_focusedOverlayView) {
        [self resetFocusedOverlay];
    } else {
        _focusedOverlayView = [_overlayViews objectAtIndex: overlayIndex];
        [self zoomSingleOverlay: _focusedOverlayView];
    }
}

- (void)zoomSingleOverlay:(AROverlayView *)overlay
{
    [UIView animateWithDuration:0.3 animations:^{
        _dimView.alpha = 1.0;
        _overlayZoomed = YES;
        [_overlayTitleViews makeObjectsPerformSelector:@selector(dismiss)];
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
        [_overlayTitleViews makeObjectsPerformSelector:@selector(layoutWithinParent:) withObject: self];
    }];
    
    // TODO: Animation needs a completion block.
    [_focusedOverlayView unfocusInParent:self];
    _focusedOverlayView = nil;
}

- (void)setOverlaysVisibleWithNames:(NSArray *)names animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:@"overlayVisibility" context:nil];
        [UIView setAnimationDuration:0.3];
    }

    for (AROverlayView *v in _overlayViews) {
        NSString *name = v.overlay.name;
        if (name && [names containsObject:name]) {
            v.alpha = 1.0;
        } else {
            v.alpha = 0.0;
        }
    }
    
    if (animated) {
        [UIView commitAnimations];
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
    
    if (scale < 0.2)
        NSLog(@"WARNING Huge image in ARAugmentedView: %f", scale);

    return scale;
}

- (CGRect)centeredAspectScaleBoundsForImage:(UIImage *)image
{
    if (_augmentedPhoto.image == nil)
        return [self bounds];
    
    return CGRectMake(0, 0, image.size.width * _overlayScaleFactor, image.size.height * _overlayScaleFactor);
}

- (CGRect)centeredAspectScaleFrameForImage:(UIImage *)image
{
    if (_augmentedPhoto.image == nil)
        return [self bounds];
    
    CGRect frame = CGRectMake(0, 0, image.size.width * _overlayScaleFactor, image.size.height * _overlayScaleFactor);
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    frame.origin.x = center.x - (frame.size.width/2);
    frame.origin.y = center.y - (frame.size.height/2);
    return frame;
}

- (void)presentFullscreenNavigationController:(UINavigationController*)controller{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PRESENT_NAVCONTROLLER_FULLSCREEN object:controller];
}

- (void)willExitFullscreen {
    [self resetFocusedOverlay];
}


@end
