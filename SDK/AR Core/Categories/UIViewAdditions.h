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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (UIViewAdditions)

- (void)setFrameY:(float)y;
- (void)setFrameX:(float)x;
- (void)shiftFrame:(CGPoint)offset;
- (void)shiftFrameUsingTransform:(CGPoint)offset;

- (void)setFrameOrigin:(CGPoint)origin;
- (void)setFrameSize:(CGSize)size;
- (void)setFrameCenter:(CGPoint)p;
- (void)setFrameWidth:(float)w;
- (void)setFrameHeight:(float)h;
- (void)setFrameSizeAndRemainCentered:(CGSize)desired;
- (void)multiplyFrameBy:(float)t;

- (void)logViewStackFromTop;
- (void)logViewStack;
- (NSMutableDictionary*)logViewStackToDictionary;

- (CGPoint)topRight;
- (CGPoint)bottomRight;
- (CGPoint)bottomLeft;

@end
