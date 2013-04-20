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
#import "AROverlayUtil.h"
#import "AROverlayView.h"
#import "AROverlayPoint.h"
#import "ARCentroidView.h"
#import "AROverlay.h"


@implementation AROverlayView

#pragma mark - Lifecycle
+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithPoints:(NSArray *)points
{
    AROverlay *overlay = [[AROverlay alloc] initWithDictionary:nil];
    overlay.points = [NSMutableArray arrayWithArray:points];
    return [self initWithOverlay:overlay];
}

- (id)initWithFrame:(CGRect)frame points:(NSArray *)points
{
    AROverlay *overlay = [[AROverlay alloc] initWithDictionary:nil];
    overlay.points = [NSMutableArray arrayWithArray:points];
    return [self initWithFrame:frame overlay:overlay];
}

- (id)initWithOverlay:(AROverlay*)overlay
{
    CGRect frame = [self frameWithOverlayContentSize:overlay.contentSize];
    return [self initWithFrame:frame overlay:overlay];
}

- (id)initWithFrame:(CGRect)frame overlay:(AROverlay *)overlay
{
    self = [super initWithFrame:frame];
    if (self) {
        self.overlay = overlay;
        
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        layer.shouldRasterize = YES;
        layer.rasterizationScale = [UIScreen mainScreen].scale;
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.fillColor = [UIColor clearColor].CGColor;
        _attachmentStyle = AROverlayAttachmentStyle_Skew;
        
        CGRect overlayBounds = self.bounds;
        layer.anchorPoint = CGPointMake(0, 0);
        layer.frame = overlayBounds;
        
        [self updateLayerPath];
        [self setupCoverView];
        [self applyOverlayStyles];
    }
    return self;
}

- (void)setupCoverView
{
    if (_overlay.coverType == AROverlayCoverType_Centroid && !_overlay.coverProvider) {
        self.coverView = [[ARCentroidView alloc] initWithFrame: self.bounds];
        
    } else {
        self.coverView = [[UIView alloc] initWithFrame:self.bounds];
        _coverView.backgroundColor = _overlay.coverColor;
        _coverView.alpha = _overlay.coverTransparency/100.0;
        if (_overlay.coverProvider) {
            NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_overlay.coverProvider]];
            [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
                UIImage *img = [UIImage imageWithData:data];
                if (img != nil) {
                    self.coverView.layer.contents = (id)img.CGImage;
                }
            }];
         }
    }

    _coverView.userInteractionEnabled = NO;
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _coverView.hidden = (_overlay.coverType == AROverlayCoverType_Hidden);
    
    [self addSubview:_coverView];
}


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateLayerPath];
}


#pragma mark - Styling 
- (void)applyOverlayStyles
{
}

- (void)updateLayerPath
{
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    CGPathRef path = CGPathCreateWithRect(self.bounds, NULL);
    layer.path = path;
    CGPathRelease(path);
}


#pragma mark - Presentation
- (void)focusInParent:(ARAugmentedView *)parent
{
    CGRect f = self.frame;
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) && (f.size.height > f.size.width)) {
        float w = f.size.width;
        f.size.width = f.size.height;
        f.size.height = w;
        self.frame = f;
    }

    if (_animDelegate) {
        [_animDelegate focusOverlayView:self inParent:parent];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_OVERLAY_VIEW_FOCUSED object: self];
    }
    [UIView animateWithDuration:0.1 animations:^{
        _outlineView.alpha = 0.0;
    }];
}

- (void)unfocusInParent:(ARAugmentedView *)parent
{
    if (_animDelegate) {
        [_animDelegate unfocusOverlayView:self inParent:parent];
    }
    [UIView animateWithDuration:0.2 delay:0.6 options:UIViewAnimationOptionCurveLinear animations:^{
        _outlineView.alpha = 1.0;
    } completion:nil];
    [parent.overlayImageView bringSubviewToFront:_outlineView];
}


#pragma mark - Transforms
- (void)layoutWithinParent:(ARAugmentedView *)parent
{
    // Apply the transform
    NSArray *scaledPoints = [AROverlayUtil scaledOverlayPointsForPoints:_overlay.points withScaleFactor:parent.overlayScaleFactor];

    AROverlayPoint *tl = [scaledPoints objectAtIndex:0];
    AROverlayPoint *tr = [scaledPoints objectAtIndex:1];
    AROverlayPoint *br = [scaledPoints objectAtIndex:2];
    AROverlayPoint *bl = [scaledPoints objectAtIndex:3];
    
    if (_overlay.coverType == AROverlayCoverType_Centroid) {
        float scale = CENTROID_SIZE / fminf(self.bounds.size.width, self.bounds.size.height);
        
        CATransform3D t = CATransform3DMakeTranslation((tl.x + tr.x + br.x + bl.x) / 4, (tl.y + tr.y + br.y + bl.y) / 4, 0);
        t = CATransform3DScale(t, scale, scale, 1);
        t = CATransform3DTranslate(t, -self.bounds.size.width / 2, -self.bounds.size.height / 2, 0);
        self.layer.position = CGPointZero;
        self.layer.transform = t;
    } else {
        CATransform3D transform = [AROverlayUtil rectToQuad:self.bounds quadTLX:tl.x quadTLY:tl.y quadTRX:tr.x quadTRY:tr.y quadBLX:bl.x quadBLY:bl.y quadBRX:br.x quadBRY:br.y];
        self.layer.transform = transform;
    }
}

#pragma mark - Convenience
- (CGRect)frameWithOverlayContentSize:(AROverlayContentSize)size
{
    CGRect frame;
    switch (size) {
        case AROverlayContentSize_Small:
            frame = CGRectMake(0, 0, 150, 150);
            break;
        case AROverlayContentSize_Medium:
            frame = CGRectMake(0, 0, 200, 200);
            break;
        case AROverlayContentSize_Large:
            frame = CGRectMake(0, 0, 300, 420);
            break;
        case AROverlayContentSize_Fullscreen:
            frame = CGRectMake(0, 0, 320, 480);
            break;
        default:
            break;
    }
    
    return frame;
}

@end