//
//  ARCentroidView.m
//  ARCore
//
//  Created by Ben Gotow on 4/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARCentroidView.h"

@implementation ARCentroidView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        [self setBackgroundColor: [UIColor clearColor]];
        [self setUserInteractionEnabled: NO];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/28.0 target:self selector:@selector(step) userInfo: nil repeats: YES];
        _step = 0;
    }
    return self;
}

- (void)removeFromSuperview
{
    [_timer invalidate];
    _timer = nil;

    [super removeFromSuperview];
}

- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
}

- (void)step
{
    _step = (_step + 1) % 50;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    float width = self.bounds.size.width / 10;
    float fraction = _step / 50.0;
    float alpha = sinf(fraction * M_PI);
    float inset = rect.size.width * 0.45 * (1.0 - fraction);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextClearRect(c, rect);
    
    float s = fminf(rect.size.width, rect.size.height);
    rect = CGRectMake((rect.size.width - s) / 2, (rect.size.height - s) / 2, s, s);
    
    CGContextSetLineWidth(c, width);
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:0.3 alpha: alpha] CGColor]);
    CGContextBeginPath(c);
    CGContextAddEllipseInRect(c, CGRectInset(rect, inset, inset));
    CGContextStrokePath(c);
    CGContextTranslateCTM(c, 0, -2);
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:0.7 + fraction * 0.2 alpha: alpha] CGColor]);
    CGContextAddEllipseInRect(c, CGRectInset(rect, inset, inset));
    CGContextStrokePath(c);
}

@end
