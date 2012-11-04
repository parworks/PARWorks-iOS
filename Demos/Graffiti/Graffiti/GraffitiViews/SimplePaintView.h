//
//  SimplePaintView.h
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


#import <UIKit/UIKit.h>

typedef struct Transforms {
    float x;
    float y;
    float zoom;
} Transforms;

@interface SimplePaintView : UIView
{
    Transforms _camera;
    Transforms _pending;
    
    
    CGImageRef _brushStamp;
    CGLayerRef _brushLayer;
    
    CGImageRef  _sourceImage;
    
    CGPoint _previousLocationInView;
}

@property(nonatomic, strong) UIColor *strokeColor;
@property(nonatomic, copy) NSString *brushName;
@property(nonatomic, assign) float brushSize;

- (IBAction)zoomed:(UIGestureRecognizer*)recognizer;
- (IBAction)panned:(UIGestureRecognizer*)recognizer;
- (IBAction)stroked:(UIGestureRecognizer*)recognizer;

- (void)strokedToPoint:(CGPoint)point;
- (void)setImage:(UIImage*)img;
- (UIImage*)getImage;

@end
