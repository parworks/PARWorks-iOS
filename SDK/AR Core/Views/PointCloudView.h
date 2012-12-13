//
//  PointCloudView.h
//  SpinningParticles
//
//  Created by Ben Gotow on 12/11/12.
//  Copyright (c) 2012 Ben Gotow. All rights reserved.
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
