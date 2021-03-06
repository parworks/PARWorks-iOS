//
//  AROverlayBuilderAnnotationView.m
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


#import <objc/runtime.h>

#import "AROverlay.h"
#import "AROverlayPoint.h"
#import "AROverlayBuilderAnnotationView.h"
#import "UIImage+ARCoreResources.h"
#import "UIView+ContentScaling.h"

@implementation AROverlayBuilderAnnotationView

- (id)initWithFrame:(CGRect)frame andSiteImage:(ARSiteImage*)siteImage backingImageView:(UIImageView *)imageView
{
    self = [super initWithFrame:frame];
    if (self) {
        _editing = NO;
        _backingImageView = imageView;
        
        _pointViews = [[NSMutableArray alloc] init];
        _lockViews = [[NSMutableArray alloc] init];

        self.siteImage = siteImage;
    }
    return self;
}


- (void)setSiteImage:(ARSiteImage*)s
{
    _siteImage = s;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // Connect the dots and fill each overlay.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSaveGState(context);
        
    // Create / place point views for our overlays
    for (AROverlay * overlay in _siteImage.overlays) {
        NSArray * scaledPoints = [self scaledPointsForOverlay: overlay];

        if (([overlay isSaved]) && ([overlay processed])) {
            [[[UIColor greenColor] colorWithAlphaComponent:0.4] set];
        } else if ([overlay isSaved]) {
            [[[UIColor redColor] colorWithAlphaComponent:0.4] set];
        } else {
            [[UIColor colorWithRed:1 green:0.6 blue:0 alpha:0.5] set];
        }
        
        for (int i = 0; i < scaledPoints.count; i++) {
            AROverlayPoint * point = scaledPoints[i];
            
            // Place a point view centered at our point.
            UIImage *image = [UIImage arCoreImageNamed:@"bubble.png"];
            CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
            rect.origin.x = point.x - floorf(image.size.width/2.0);
            rect.origin.y = point.y - floorf(image.size.height/2.0);
            CGContextDrawImage(context, rect, image.CGImage);
            
            // Add a point to the path we're drawing
            if (i==0) {
                CGContextMoveToPoint(context, point.x, point.y);
            } else {
                CGContextAddLineToPoint(context, point.x, point.y);
            }
        }
    
        CGContextFillPath(context);
    }
}


#pragma mark - Layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageScale = [_backingImageView aspectFitScaleForCurrentImage];
}

- (void)createAndLayoutOverlayPoints
{
    // TODO: Refactor how the dots showing corners are handled.
    
    // Create any points needed.
//    NSInteger totalPointCount = 0;
//    for (int i=0; i<_siteImage.overlays.count; i++) {
//        AROverlay *overlay = _siteImage.overlays[i];
//        totalPointCount += overlay.points.count;
//    }
    
    
}

#pragma mark - Convenience

- (AROverlay*)currentOverlay
{
    return [[_siteImage overlays] lastObject];
}

- (NSArray *)scaledPointsForOverlay:(AROverlay *)overlay
{
    NSMutableArray *a = [NSMutableArray array];
    for (AROverlayPoint *p in overlay.points) 
        [a addObject: [AROverlayPoint pointWithX: p.x*_imageScale y: p.y*_imageScale z:0]];
    
    return a;
}

#pragma mark - Point Management

- (void)beginNewOverlay:(CGPoint)center
{
    float size = 45;
    AROverlay * overlay = [[AROverlay alloc] initWithSiteImage: self.siteImage];
    [overlay addPointWithX:center.x - size andY:center.y - size];
    [overlay addPointWithX:center.x - size andY:center.y + size];
    [overlay addPointWithX:center.x + size andY:center.y + size];
    [overlay addPointWithX:center.x + size andY:center.y - size];
    [_siteImage.site addOverlay: overlay];
    [self setNeedsDisplay];
}

- (void)updatePoint:(int)index ofOverlay:(int)oindex to:(CGPoint)point
{
    AROverlay * o = [[_siteImage overlays] objectAtIndex: oindex];
    CGPoint fullPoint = CGPointMake(point.x/_imageScale, point.y/_imageScale);
    AROverlayPoint * arpoint = [[o points] objectAtIndex: index];
    arpoint.x = fullPoint.x;
    arpoint.y = fullPoint.y;
    [self setNeedsDisplay];
}

@end
