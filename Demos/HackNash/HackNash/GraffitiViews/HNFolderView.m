//
//  HNColorPickerFolderView.m
//  HackNash
//
//  Created by Demetri Miller on 10/29/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "HNFolderView.h"

@implementation HNFolderView

- (id)initWithButtonOffsetY:(CGFloat)offsetY image:(UIImage *)image frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(50, 0, self.width, self.height)];
        background.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:225.0/255.0 blue:168.0/255.0 alpha:1.0];
        [self addSubview:background];
        
        self.folderButton = [[HNFolderButton alloc] initWithFrame:CGRectMake(0, offsetY, 50, 56)];
        [_folderButton setImage:image forState:UIControlStateNormal];
        _folderButton.contentMode = UIViewContentModeCenter;
        [self addSubview:_folderButton];
        
        self.layer.shouldRasterize = YES;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 4.0;
        self.layer.shadowOpacity = 1.0;
    }
    return self;
}

- (void)showInParent:(UIView *)view animated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.position = CGPointMake(view.bounds.size.width - self.width, 0);
    } completion:^(BOOL finished) {
        _showing = YES;
    }];
}

- (void)hideInParent:(UIView *)view animated:(BOOL)animated
{
    CGFloat duration = animated ? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.position = CGPointMake(view.bounds.size.width - _folderButton.width, 0);
    } completion:^(BOOL finished) {
        _showing = NO;
    }];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(_folderButton.frame, point)) {
        return YES;
    } else if (CGRectContainsPoint(CGRectOffset(self.bounds, _folderButton.width, 0), point)) {
        return YES;
    } else {
        return NO;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
