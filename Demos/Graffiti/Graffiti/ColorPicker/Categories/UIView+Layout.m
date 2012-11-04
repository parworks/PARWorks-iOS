//
//  UIViewAdditions.m
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