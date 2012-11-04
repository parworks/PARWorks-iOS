//
//  UIViewAdditions.m
//  PAR Works iOS SDK
//
//  This class contains convenience functions for manipulating the frame of a view,
//  just to make things a little bit cleaner. (Plus, you can't beat Obj-C categories)
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


#import "UIViewAdditions.h"

@implementation UIView (UIViewAdditions)

- (void)setFrameY:(float)y
{
    CGRect frame = [self frame];
    frame.origin.y = y;
    [self setFrame: frame];
}

- (void)setFrameX:(float)x
{
    CGRect frame = [self frame];
    frame.origin.x = x;
    [self setFrame: frame];
}

- (void)shiftFrame:(CGPoint)offset
{
    CGRect frame = [self frame];
    [self setFrame: CGRectMake(frame.origin.x + offset.x, frame.origin.y + offset.y, frame.size.width, frame.size.height)];
}

- (void)shiftFrameUsingTransform:(CGPoint)offset
{
    CGAffineTransform t = [self transform];
    t = CGAffineTransformTranslate(t,offset.x, offset.y);
    [self setTransform: t];
}

- (void)setFrameOrigin:(CGPoint)origin
{
    CGRect frame = [self frame];
    [self setFrame: CGRectMake(origin.x, origin.y, frame.size.width, frame.size.height)];
}

- (void)setFrameSize:(CGSize)size
{
    CGRect frame = [self frame];
    [self setFrame: CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height)];
}

- (void)setFrameCenter:(CGPoint)p
{
    CGRect frame = [self frame];
    [self setFrame: CGRectMake(p.x - frame.size.width / 2, p.y - frame.size.height / 2, frame.size.width, frame.size.height)];
}

- (void)setFrameWidth:(float)w
{    
    CGRect frame = [self frame];
    frame.size.width = w;
    [self setFrame: frame];
}

- (void)setFrameHeight:(float)h
{    
    CGRect frame = [self frame];
    frame.size.height = h;
    [self setFrame: frame];
}

- (void)setFrameSizeAndRemainCentered:(CGSize)desired
{
    CGRect current = [self frame];
    CGRect fixed = CGRectMake(current.origin.x - (desired.width - current.size.width) / 2,
        current.origin.y - (desired.height - current.size.height) / 2, desired.width, desired.height);
        
    [self setFrame: fixed];
}

- (void)multiplyFrameBy:(float)t
{
    CGRect f = [self frame];
    f.origin.x *= t;
    f.origin.y *= t;
    f.size.width *= t;
    f.size.height *= t;
    
    [self setFrame:f];
}

- (void)logViewStackFromTop
{
    // if we have a parent, move the log command up to him
    if ([self superview])
        [[self superview] logViewStackFromTop];
    else 
        [self logViewStack];
}

- (void)logViewStack
{
    NSDictionary * r = [self logViewStackToDictionary];
    [r writeToFile:@"/data.ar" atomically:NO];
}

- (NSMutableDictionary*)logViewStackToDictionary
{

    UIGraphicsBeginImageContext([self bounds].size);
    
    if ([self backgroundColor] != nil){
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(c, [[self backgroundColor] CGColor]);
        CGContextFillRect(c, [self bounds]);
    }
    
    [self drawRect: [self bounds]];
    
    UIImage * i = UIGraphicsGetImageFromCurrentImageContext();
    NSData * rep = UIImagePNGRepresentation(i);
    UIGraphicsEndImageContext();
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if (rep) [dict setObject: rep forKey: @"image"];
    [dict setObject: @([self frame].origin.x) forKey: @"x"];
    [dict setObject: @([self frame].origin.y) forKey: @"y"];
    [dict setObject: @([self frame].size.width) forKey: @"w"];
    [dict setObject: @([self frame].size.height) forKey: @"h"];
    
    if ([[self subviews] count] > 0){
        NSMutableArray * subviewDicts = [NSMutableArray array];
        for (UIView * v in [self subviews]){
            [subviewDicts addObject: [v logViewStackToDictionary]];
        }
        [dict setObject: subviewDicts forKey: @"subviews"];
    }
    
    return dict;
}

- (CGPoint)topRight
{
    return CGPointMake([self frame].origin.x + [self frame].size.width, [self frame].origin.y);
}

- (CGPoint)bottomRight
{
    return CGPointMake([self frame].origin.x + [self frame].size.width, [self frame].origin.y + [self frame].size.height);
}

- (CGPoint)bottomLeft
{
    return CGPointMake([self frame].origin.x, [self frame].origin.y + [self frame].size.height);
}

@end
