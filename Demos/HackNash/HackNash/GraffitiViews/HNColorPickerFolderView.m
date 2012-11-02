//
//  HNColorPickerFolderView.m
//  HackNash
//
//  Created by Demetri Miller on 10/29/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import "DMColorPickerView.h"
#import "HNColorPickerFolderView.h"

@implementation HNColorPickerFolderView

- (id)initWithButtonOffsetY:(CGFloat)offsetY image:(UIImage *)image frame:(CGRect)frame
{
    self = [super initWithButtonOffsetY:offsetY image:image frame:frame];
    if (self) {
        // Add the color picker to the view offset to account for the button.
        _picker = [[DMColorPickerView alloc] initWithFrame:CGRectMake(0, 0, 280, 280)];
        _picker.center = CGPointMake(self.width/2 + 30, self.height/2);
        [self addSubview:_picker];        
    }
    return self;
}

@end
