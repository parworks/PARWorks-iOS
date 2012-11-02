//
//  UIViewAdditions.m
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+Layout.h"

@implementation UIView (Layout)

- (CGPoint)position {
	return [self frame].origin;
}

- (void)setPosition:(CGPoint)position {
	CGRect rect = [self frame];
	rect.origin = position;
	[self setFrame:rect];
}

- (CGFloat)x {
	return [self frame].origin.x;
}

- (void)setX:(CGFloat)x {
	CGRect rect = [self frame];
	rect.origin.x = x;
	[self setFrame:rect];
}

- (CGFloat)y {
	return [self frame].origin.y;
}

- (void)setY:(CGFloat)y {
	CGRect rect = [self frame];
	rect.origin.y = y;
	[self setFrame:rect];
}

- (CGSize)size {
	return [self frame].size;
}

- (void)setSize:(CGSize)size {
	CGRect rect = [self frame];
	rect.size = size;
	[self setFrame:rect];
}

- (CGFloat)width {
	return [self frame].size.width;
}

- (void)setWidth:(CGFloat)width {
	CGRect rect = [self frame];
	rect.size.width = width;
	[self setFrame:rect];
}

- (CGFloat)height {
	return [self frame].size.height;
}

- (void)setHeight:(CGFloat)height {
	CGRect rect = [self frame];
	rect.size.height = height;
	[self setFrame:rect];
}

CGFloat distanceBetweenPoints(CGPoint p1, CGPoint p2)
{
    CGFloat dist = sqrtf(powf(p1.x - p2.x, 2) + powf(p1.y - p2.y, 2));
    return dist;
}

@end