//
//  PointCloudView.m
//  SpinningParticles
//
//  Created by Ben Gotow on 12/11/12.
//  Copyright (c) 2012 Ben Gotow. All rights reserved.
//

#import "PointCloudView.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define DEGREES_TO_RADIANS(x) (3.14159265358979323846 * x / 180.0)
#define RANDOM_FLOAT_BETWEEN(x, y) (((float) rand() / RAND_MAX) * (y - x) + x)

@implementation PointCloudView

- (id)initWithFrame:(CGRect)frame andPLYPath:(NSString*)path
{
    EAGLContext * c = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES1];
    self = [super initWithFrame:frame context: c];
    if (self) {
        [self setDelegate: self];
        [self setOpaque: NO];
        [self setBackgroundColor: [UIColor clearColor]];
        
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer: pan];
        [self loadPLYFile: path];
    }
    return self;
}

- (void)makeModelInvisible
{
    for (int i = 0; i < vertexCount; i++)
        colorBuffer[i * 4 + 3] = 0;
}

- (void)startAnimating
{
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1/32.0 target:self selector:@selector(display) userInfo:nil repeats:YES];
    [self makeModelInvisible];
    rotationVelocity = 0.2;
}

- (void)stopAnimating
{
    [self.animationTimer invalidate];
}

- (void)pan:(UIPanGestureRecognizer*)recognizer
{
    rotationVelocity = fmaxf(-30, fminf(30, [recognizer velocityInView: self].x / 32.0));
}

- (void)loadPLYFile:(NSString*)path
{
    // open ply file
    NSArray * lines = [[NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil] componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    vertexBuffer = malloc(sizeof(GLfloat) * 3 * [lines count]);
    colorBuffer = malloc(sizeof(GLubyte) * 4 * [lines count]);
    objectRadius = 0;
    
    for (NSString * line in lines) {
        NSArray * components = [line componentsSeparatedByString: @" "];
        float sumOfSquares = 0;
        if ([[components objectAtIndex: 0] floatValue] == 0)
            continue;
        if ([[components objectAtIndex: 0] floatValue] == 3.0)
            continue;
        
        if ([components count] >= 3) {
            for (int i = 0; i < 3; i++) {
                float f = [[components objectAtIndex: i] floatValue];
                vertexBuffer[vertexCount * 3 + i] = f;
                sumOfSquares += f * f;
            }
        }
        if ([components count] == 6) {
            for (int i = 0; i < 3; i++)
                colorBuffer[vertexCount * 4 + i] = [[components objectAtIndex: 3 + i] intValue];
        } else {
            for (int i = 0; i < 3; i++)
                colorBuffer[vertexCount * 4 + i] = 0;
        }
        objectRadius = fmaxf(objectRadius, sumOfSquares);
        vertexCount ++;
    }
    
    objectRadius = sqrtf(objectRadius);

    [self makeModelInvisible];
    [self display];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    float backingWidth = self.bounds.size.width * [[UIScreen mainScreen] scale];
    float backingHeight = self.bounds.size.height * [[UIScreen mainScreen] scale];
    float backingAspect =(rect.size.width / rect.size.height);
    
    glClearColor(0, 0, 0, 0);
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, backingWidth, backingHeight);
    glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
    
    const GLfloat zNear = 0.01;
    const GLfloat zFar = 10000.0;
    const GLfloat fieldOfView = 45.0;
    
    rotation += rotationVelocity;
    rotationVelocity = rotationVelocity * 0.8 + 0.2 * 0.2;
    
    GLfloat size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
    rect.origin = CGPointMake(0.0, 0.0);
    rect.size = CGSizeMake(backingWidth, backingHeight);
    glFrustumf(-size, size, -size / backingAspect, size / backingAspect, zNear, zFar);
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    glTranslatef(0, 0, -objectRadius * 3);
    glRotatef(25, 1, 0, 0);
    glRotatef(rotation, 0, 1, 0);
    glPointSize(1.2 * [[UIScreen mainScreen] scale]);
    glColor4f(1, 0, 0, 1);
    glVertexPointer(3, GL_FLOAT, 0, vertexBuffer);
	glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorBuffer);
    glEnableClientState(GL_COLOR_ARRAY);
    glDrawArrays(GL_POINTS, 0, vertexCount);
    
    for (int i = 0; i < 13; i ++) {
        int index = rand() % vertexCount;
        colorBuffer[index * 4 + 3] = 150;
    }
}
    

@end
