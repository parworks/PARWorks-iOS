//
//  GRColorPickerFolderView.m
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


#import "DMColorPickerView.h"
#import "GRColorPickerFolderView.h"

@implementation GRColorPickerFolderView

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
