//
//  SimplePaintView.m
//  Graffiti
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


#import "SimplePaintView.h"
#import <QuartzCore/QuartzCore.h>

#define NO_PREVIOUS -1

@implementation SimplePaintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(stroked:)];
        [self addGestureRecognizer:pan];

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
    _brushSize = 32;
    _camera.zoom = 1;
    _pending.zoom = 1;
    _previousLocationInView.x = NO_PREVIOUS;
    self.strokeColor = [UIColor blackColor];

    [[self layer] setDrawsAsynchronously: YES];
}

- (void)setImage:(UIImage*)img
{
    _sourceImage = CGImageRetain([img CGImage]);
}

- (UIImage*)getImage
{
    CGSize s = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height * 2);
    if (_sourceImage)
        s = CGSizeMake(CGImageGetWidth(_sourceImage), CGImageGetHeight(_sourceImage));
    
    UIGraphicsBeginImageContext(s);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, s.height);
    CGContextScaleCTM(c, 1, -1);
    if (_sourceImage)
        CGContextDrawImage(c, CGRectMake(0, 0, s.width, s.height), _sourceImage);
    CGContextDrawLayerInRect(c, CGRectMake(0, 0, s.width, s.height), _brushLayer);
    UIImage * i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    if (_brushLayer == nil)
        _brushLayer = CGLayerCreateWithContext(c, CGSizeMake(rect.size.width * [[UIScreen mainScreen] scale], rect.size.height * [[UIScreen mainScreen] scale]), NULL);
    
    CGSize size = [self bounds].size;
    CGContextTranslateCTM(c, -size.width / 2, -size.height / 2);
    CGContextScaleCTM(c, _camera.zoom * _pending.zoom, _camera.zoom * _pending.zoom);
    CGContextTranslateCTM(c, _camera.x + _pending.x, _camera.y + _pending.y);
    CGContextTranslateCTM(c, size.width / 2, size.height / 2);
    
    if (_sourceImage)
        CGContextDrawImage(c, self.bounds, _sourceImage);
    CGContextDrawLayerInRect(c, self.bounds, _brushLayer);
}

- (IBAction)zoomed:(UIPinchGestureRecognizer*)recognizer
{
    _pending.zoom = [recognizer scale];
    
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        _camera.zoom *= _pending.zoom;
        _pending.zoom = 1;
    }

    [self setNeedsDisplay];
}

- (IBAction)panned:(UIPanGestureRecognizer*)recognizer
{
    CGPoint t = [recognizer translationInView: self];
    _pending.x = t.x;
    _pending.y = t.y;
    
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        _camera.x += _pending.x;
        _camera.y += _pending.y;
        _pending.x = 0;
        _pending.y = 0;
    }
    
    [self setNeedsDisplay];
}

- (void)strokedToPoint:(CGPoint)point
{
    CGContextRef c = CGLayerGetContext(_brushLayer);
    
    // Step 1: Determine the point onscreen  we are currently touching,
    // compute the brush radius.
    int steps = 1;
    float radius = 80;
    CGPoint center = point;
    center.x *= [[UIScreen mainScreen] scale];
    center.y *= [[UIScreen mainScreen] scale];
    
    // Step 2: Find out how far the brush has travelled since our last touch event
    CGPoint diff = CGPointMake(center.x - _previousLocationInView.x, center.y - _previousLocationInView.y);
    
    // If this is not the first touch event, let's compute a number of stamps to make
    // between the old touch point and the new touch point
    if (_previousLocationInView.x != NO_PREVIOUS)
        steps = ceilf(sqrtf(powf(diff.y, 2) + powf(diff.x, 2))) / 6;
    
    CGPoint step = CGPointMake(diff.x / steps, diff.y / steps);
    CGRect dirtyRect = CGRectZero;
//    float a = 1.0 - sqrtf((float)steps) * 0.125;
    
    // Step 3: Draw a stamp at each step along the way from the old touch point to the
    // new touch point
    for (int s = 0; s < steps; s ++) {
        _previousLocationInView.x += step.x;
        _previousLocationInView.y += step.y;
        
        CGRect r = CGRectMake(_previousLocationInView.x - radius, _previousLocationInView.y - radius, radius * 2, radius * 2);
        CGContextSetRGBFillColor(c, 1, 1, 1, 1);
        CGContextSaveGState(c);
        CGContextClipToMask(c, r, [[UIImage imageNamed: @"brush_1_texture.png"] CGImage]);
        CGContextFillRect(c, r);
        CGContextRestoreGState(c);
        
        dirtyRect = (s == 0) ? r : CGRectUnion(dirtyRect, r);
    }
    
    // Step 4: If this is the last touch event, reset our previous location
//    if ([recognizer state] == UIGestureRecognizerStateEnded)
//        _previousLocationInView.x = NO_PREVIOUS;
    [self setNeedsDisplayInRect: self.bounds];
}


- (IBAction)stroked:(UIPanGestureRecognizer*)recognizer
{    
    CGContextRef c = CGLayerGetContext(_brushLayer);
    
    // Step 1: Determine the point onscreen  we are currently touching,
    // compute the brush radius.
    int steps = 1;
    float radius = _brushSize / [[UIScreen mainScreen] scale];
    CGPoint center = [recognizer locationInView: self];
    center.x *= [[UIScreen mainScreen] scale];
    center.y *= [[UIScreen mainScreen] scale];
    
    // Step 2: Find out how far the brush has travelled since our last touch event
    CGPoint diff = CGPointMake(center.x - _previousLocationInView.x, center.y - _previousLocationInView.y);

    // If this is not the first touch event, let's compute a number of stamps to make
    // between the old touch point and the new touch point
    if (_previousLocationInView.x != NO_PREVIOUS)
        steps = ceilf(sqrtf(powf(diff.y, 2) + powf(diff.x, 2))) / fmaxf(1, (radius / 6));

    CGPoint step = CGPointMake(diff.x / steps, diff.y / steps);
    CGRect dirtyRect = CGRectZero;
    float a = 1.0 - sqrtf((float)steps) * 0.10;
    
    // Step 3: Draw a stamp at each step along the way from the old touch point to the
    // new touch point
    for (int s = 0; s < steps; s ++) {
        _previousLocationInView.x += step.x;
        _previousLocationInView.y += step.y;

        CGRect r = CGRectMake(_previousLocationInView.x - radius, _previousLocationInView.y - radius, radius * 2, radius * 2);
        CGContextSetFillColorWithColor(c, _strokeColor.CGColor);
        CGContextSaveGState(c);
        CGContextClipToMask(c, r, [[UIImage imageNamed: _brushName] CGImage]);
        CGContextFillRect(c, r);
        CGContextRestoreGState(c);
        
        dirtyRect = (s == 0) ? r : CGRectUnion(dirtyRect, r);
    }
    
    // Step 4: If this is the last touch event, reset our previous location
    if ([recognizer state] == UIGestureRecognizerStateEnded)
        _previousLocationInView.x = NO_PREVIOUS;
    
    [self setNeedsDisplayInRect: self.bounds];
}

@end
