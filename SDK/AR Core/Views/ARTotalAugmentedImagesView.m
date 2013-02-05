//
//  ARTotalAugmentedImagesView.m
//  PARViewer
//
//  Created by Demetri Miller on 2/5/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARTotalAugmentedImagesView.h"
#import "UIViewAdditions.h"

@implementation ARTotalAugmentedImagesView

- (id)init
{
    CGRect frame = CGRectMake(0, 0, 54, 20);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        self.layer.cornerRadius = 6.0;
        self.layer.masksToBounds = YES;
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_countLabel];
        
        _cameraIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _cameraIconView.backgroundColor = [UIColor greenColor];
        [self addSubview:_cameraIconView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_cameraIconView setFrameX:10];
    [_cameraIconView setCenter:CGPointMake(_cameraIconView.center.x, self.bounds.size.height/2)];
    
    CGFloat maxX = CGRectGetMaxX(_cameraIconView.frame);
    [_countLabel setFrame:CGRectMake(maxX, 0, self.frame.size.width - maxX, self.frame.size.height)];
}

- (void)setCount:(NSInteger)count
{
    _countLabel.text = [NSString stringWithFormat:@"%d",count];
    [self setNeedsLayout];
}

@end
