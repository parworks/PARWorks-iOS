//
//  GridCellView.m
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


#import <QuartzCore/QuartzCore.h>

#import "GridCellView.h"

@implementation GridCellView

@synthesize dataProvider = _dataProvider;
@synthesize parent = _parent;

- (id)initWithDataProvider:(NSObject<GridCellViewDataProvider> *)dp
{
    self = [super initWithFrame: CGRectMake(0, 0, 100, 100)];
    if (self) {
        CGRect imageViewFrame = self.bounds;
        _imageView = [[CachedImageView alloc] initWithFrame: imageViewFrame];
        [_imageView setContentMode: UIViewContentModeScaleAspectFit];
        [self addSubview: _imageView];
        
        UIButton * _button = [[UIButton alloc] initWithFrame: self.bounds];
        [_button addTarget:self action:@selector(tapDown) forControlEvents:UIControlEventTouchDown];
        [_button addTarget:self action:@selector(tapTriggered) forControlEvents:UIControlEventTouchUpInside];
        [_button addTarget:self action:@selector(tapUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        [self addSubview: _button];
        
        [self setBackgroundColor: [UIColor whiteColor]];
        [[self layer] setCornerRadius: 3];
        [[self layer] setBorderColor: [[UIColor clearColor] CGColor]];
        [[self layer] setBorderWidth: 1];
        
        [self setDataProvider: dp];
    }
    return self;
}

- (void)setDataProvider:(NSObject<GridCellViewDataProvider> *)dp
{
    _dataProvider = dp;
    
    if ([dp respondsToSelector: @selector(imagePathForCell:)])
        [_imageView setImagePath: [dp imagePathForCell: self]];
    else
        [_imageView setImage: [dp imageForCell: self]];
    if ([dp respondsToSelector: @selector(applyExtraStylesToCell:)])
        [dp applyExtraStylesToCell: self];
}

- (void)tapDown
{
    [[self layer] setBorderColor: [[UIColor blueColor] CGColor]];
    [[self layer] setBorderWidth: 3];
}

- (void)tapUp
{
    [self performSelector:@selector(tapUpDeferred) withObject:nil afterDelay:0.2];
}

- (void)tapUpDeferred 
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [[self layer] setBorderColor: [[UIColor clearColor] CGColor]];
    [[self layer] setBorderWidth: 1];
    [UIView commitAnimations];
}

- (void)tapTriggered
{
    [_parent performSelectorOnMainThread:@selector(drillDownOnCell:) withObject:self waitUntilDone:NO];
}


@end
