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
        [self setupOverlay];
        [self setupCoverView];
    }
    return self;
}

- (void)setupOverlay
{
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
    [self styleWithOverlay:_overlay];
}

- (void)setupCoverView
{
    self.coverView = [[UIView alloc] initWithFrame:self.bounds];
    _coverView.userInteractionEnabled = NO;
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _coverView.alpha = _overlay.coverTransparency/100.0;
    _coverView.backgroundColor = _overlay.coverColor;
    _coverView.hidden = (_overlay.contentType == AROverlayCoverType_Hidden);
    
    // Load the image into the view.
    if (_overlay.coverType == AROverlayCoverType_Image && _overlay.coverProvider) {
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_overlay.coverProvider]];
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
            UIImage *img = [UIImage imageWithData:data];
            if (img != nil) {
                self.coverView.layer.contents = (id)img.CGImage;
            }
        }];
    }
    
    [self addSubview:_coverView];
}



#pragma mark - Layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateLayerPath];
}


#pragma mark - Styling 
- (void)styleWithOverlay:(AROverlay *)overlay
{
    /*
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.strokeColor = _overlay.boundaryColor.CGColor;
    layer.lineWidth = 12.0;
    
    switch (_overlay.boundaryType) {
        case AROverlayBoundaryType_Solid:
            layer.lineDashPattern = nil;
            break;
        case AROverlayBoundaryType_Dashed:
            layer.lineDashPattern = @[@12];
            
            break;
        default:
            break;
    }
     */
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
    if (_animDelegate) {
        [_animDelegate focusOverlayView:self inParent:parent];
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
    [UIView animateWithDuration:0.2 delay:0.6 options:UIViewAnimationCurveLinear animations:^{
        _outlineView.alpha = 1.0;
    } completion:nil];
    [parent.overlayImageView bringSubviewToFront:_outlineView];
}


#pragma mark - Transforms
- (void)addDemoSubviewToOverlay
{
    UIWebView *wv = [[UIWebView alloc] initWithFrame:self.bounds];
    wv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    wv.scalesPageToFit = YES;
    wv.opaque = NO;
    [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://foundry376.com/hdar/index.html"]]];
    wv.userInteractionEnabled = NO;
    [self addSubview:wv];
}

- (void)applyAttachmentStyleWithParent:(ARAugmentedView *)parent
{
    switch (_attachmentStyle) {
        case AROverlayAttachmentStyle_Skew:
            [self applySkewStyleWithParent:parent];
            break;
        case AROverlayAttachmentStyle_Bounded:
            [self applyBoundedStyleWithParent:parent];
            break;
        case AROverlayAttachmentStyle_Centered:
            [self applyCenteredStyleWithParent:parent];
            break;
            
        default:
            break;
    }
}

- (void)applySkewStyleWithParent:(ARAugmentedView *)parent
{
    // Apply the transform
    NSArray *scaledPoints = [AROverlayUtil scaledOverlayPointsForPoints:_overlay.points withScaleFactor:parent.overlayScaleFactor];

    AROverlayPoint *tl = [scaledPoints objectAtIndex:0];
    AROverlayPoint *tr = [scaledPoints objectAtIndex:1];
    AROverlayPoint *br = [scaledPoints objectAtIndex:2];
    AROverlayPoint *bl = [scaledPoints objectAtIndex:3];
    
    CATransform3D transform = [AROverlayUtil rectToQuad:self.bounds
                                                quadTLX:tl.x quadTLY:tl.y
                                                quadTRX:tr.x quadTRY:tr.y
                                                quadBLX:bl.x quadBLY:bl.y
                                                quadBRX:br.x quadBRY:br.y];
    self.layer.transform = transform;
}

- (void)applyBoundedStyleWithParent:(ARAugmentedView *)parent
{
    NSArray *scaledPoints = [AROverlayUtil scaledOverlayPointsForPoints:_overlay.points withScaleFactor:parent.overlayScaleFactor];
    CGRect frame = [AROverlayUtil boundingFrameForPoints:scaledPoints];
    self.frame = frame;
}

- (void)applyCenteredStyleWithParent:(ARAugmentedView *)parent
{
    
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
            frame = CGRectMake(0, 0, 250, 250);
            break;
        case AROverlayContentSize_Fullscreen:
            frame = self.bounds;
            break;
        default:
            break;
    }
    return frame;
}

@end