//
//  PointCloudView.h
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

#import <GLKit/GLKit.h>

@interface PointCloudView : GLKView <GLKViewDelegate>
{
    GLubyte * colorBuffer;
    GLfloat * vertexBuffer;
    int vertexCount;
    
    float objectRadius;
    float rotation;
    float rotationVelocity;
}

@property (nonatomic, strong) NSTimer * animationTimer;

- (id)initWithFrame:(CGRect)frame andPLYPath:(NSString*)path;
- (void)startAnimating;
- (void)stopAnimating;

@end
