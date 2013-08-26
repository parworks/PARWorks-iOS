//
//  AROverlayUtil.m
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


#import "AROverlayUtil.h"
#import "AROverlayPoint.h"

bool lineSegmentIntersection(double Ax, double Ay,double Bx, double By,double Cx, double Cy,double Dx, double Dy,double *X, double *Y) {
    
    double  distAB, theCos, theSin, newX, ABpos ;
    
    //  Fail if either line segment is zero-length.
    if ((Ax==Bx && Ay==By) || (Cx==Dx && Cy==Dy)) return NO;
    
    //  Fail if the segments share an end-point.
    if ((Ax==Cx && Ay==Cy) || (Bx==Cx && By==Cy)
        ||  (Ax==Dx && Ay==Dy) || (Bx==Dx && By==Dy)) {
        return NO; }
    
    //  (1) Translate the system so that point A is on the origin.
    Bx-=Ax; By-=Ay;
    Cx-=Ax; Cy-=Ay;
    Dx-=Ax; Dy-=Ay;
    
    //  Discover the length of segment A-B.
    distAB=sqrt(Bx*Bx+By*By);
    
    //  (2) Rotate the system so that point B is on the positive X axis.
    theCos=Bx/distAB;
    theSin=By/distAB;
    newX=Cx*theCos+Cy*theSin;
    Cy  =Cy*theCos-Cx*theSin; Cx=newX;
    newX=Dx*theCos+Dy*theSin;
    Dy  =Dy*theCos-Dx*theSin; Dx=newX;
    
    //  Fail if segment C-D doesn't cross line A-B.
    if ((Cy<0. && Dy<0.) || (Cy>=0. && Dy>=0.)) return NO;
    
    //  (3) Discover the position of the intersection point along line A-B.
    ABpos=Dx+(Cx-Dx)*Dy/(Dy-Cy);
    
    //  Fail if segment C-D crosses line A-B outside of segment A-B.
    if (ABpos<0. || ABpos>distAB) return NO;
    
    //  (4) Apply the discovered position to line A-B in the original coordinate system.
    if (X != NULL) {
        *X=Ax+ABpos*theCos;
        *Y=Ay+ABpos*theSin;
    }
    //  Success.
    return YES;
}

@implementation AROverlayUtil

+ (CGFloat)scaleFactorForBounds:(CGRect)bounds withImage:(UIImage *)image
{
    CGFloat scale = 1.0;
    
    CGFloat widthRatio = bounds.size.width / image.size.width;
    CGFloat heightRatio = bounds.size.height / image.size.height;
    
    scale = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    return scale;
}

+ (CGRect)centeredAspectFitFrameForBounds:(CGRect)bounds withImage:(UIImage *)image
{
    CGFloat scaleFactor = [AROverlayUtil scaleFactorForBounds:bounds withImage:image];
    CGRect frame = CGRectMake(0, 0, image.size.width * scaleFactor, image.size.height * scaleFactor);
    CGPoint center = CGPointMake(bounds.size.width/2, bounds.size.height/2);
    
    frame.origin.x = center.x - (frame.size.width/2);
    frame.origin.y = center.y - (frame.size.height/2);
    return frame;
}

+ (CGPoint)focusedCenterForOverlayView:(AROverlayView *)overlayView withParent:(UIView *)parent
{
    return CGPointMake((parent.frame.size.width/2) - (overlayView.frame.size.width/2), (parent.frame.size.height/2) - (overlayView.frame.size.height/2));
}

+ (NSMutableArray *)scaledOverlayPointsForPoints:(NSArray *)points withScaleFactor:(float)scaleFactor
{
    NSMutableArray *array = [NSMutableArray array];
    for (AROverlayPoint * point in points) {
        AROverlayPoint * p = [[AROverlayPoint alloc] init];
        p.x = point.x * scaleFactor;
        p.y = point.y * scaleFactor;
        p.z = point.z * scaleFactor;
        [array addObject: p];
    }
    return array;
}


// Determine the smallest bounding box that will
// contain all points. We're going to use this as a default for the
// frame of overlay view.
+ (CGRect)boundingFrameForPoints:(NSArray *)points
{
    if ([points count] == 0)
        return CGRectZero;
    
    AROverlayPoint * point = [points objectAtIndex:0];
    CGRect rect = CGRectMake(point.x, point.y, 1, 1);
    for (int i=1; i<points.count; i++) {
        AROverlayPoint * point = [points objectAtIndex: i];
        rect = CGRectUnion(rect, CGRectMake(point.x, point.y, 1, 1));
    }
    
    if (rect.size.width == NAN)
        return CGRectZero;
    
    return rect;
}


+ (CATransform3D)rectToQuad:(CGRect)rect quadTLX:(double)x1a quadTLY:(double)y1a quadTRX:(double)x2a quadTRY:(double)y2a quadBLX:(double)x3a quadBLY:(double)y3a quadBRX:(double)x4a quadBRY:(double)y4a
{
    double X = rect.origin.x;
    double Y = rect.origin.y;
    double W = rect.size.width;
    double H = rect.size.height;
    
    double y21 = y2a - y1a;
    double y32 = y3a - y2a;
    double y43 = y4a - y3a;
    double y14 = y1a - y4a;
    double y31 = y3a - y1a;
    double y42 = y4a - y2a;
    
    double a = -H*(x2a*x3a*y14 + x2a*x4a*y31 - x1a*x4a*y32 + x1a*x3a*y42);
    double b = W*(x2a*x3a*y14 + x3a*x4a*y21 + x1a*x4a*y32 + x1a*x2a*y43);
    double c = H*X*(x2a*x3a*y14 + x2a*x4a*y31 - x1a*x4a*y32 + x1a*x3a*y42) - H*W*x1a*(x4a*y32 - x3a*y42 + x2a*y43) - W*Y*(x2a*x3a*y14 + x3a*x4a*y21 + x1a*x4a*y32 + x1a*x2a*y43);
    
    double d = H*(-x4a*y21*y3a + x2a*y1a*y43 - x1a*y2a*y43 - x3a*y1a*y4a + x3a*y2a*y4a);
    double e = W*(x4a*y2a*y31 - x3a*y1a*y42 - x2a*y31*y4a + x1a*y3a*y42);
    double f = -(W*(x4a*(Y*y2a*y31 + H*y1a*y32) - x3a*(H + Y)*y1a*y42 + H*x2a*y1a*y43 + x2a*Y*(y1a - y3a)*y4a + x1a*Y*y3a*(-y2a + y4a)) - H*X*(x4a*y21*y3a - x2a*y1a*y43 + x3a*(y1a - y2a)*y4a + x1a*y2a*(-y3a + y4a)));
    
    double g = H*(x3a*y21 - x4a*y21 + (-x1a + x2a)*y43);
    double h = W*(-x2a*y31 + x4a*y31 + (x1a - x3a)*y42);
    double i = W*Y*(x2a*y31 - x4a*y31 - x1a*y42 + x3a*y42) + H*(X*(-(x3a*y21) + x4a*y21 + x1a*y43 - x2a*y43) + W*(-(x3a*y2a) + x4a*y2a + x2a*y3a - x4a*y3a - x2a*y4a + x3a*y4a));
    
    //Transposed matrix
    CATransform3D transform;
    transform.m11 = a / i;
    transform.m12 = d / i;
    transform.m13 = 0;
    transform.m14 = g / i;
    transform.m21 = b / i;
    transform.m22 = e / i;
    transform.m23 = 0;
    transform.m24 = h / i;
    transform.m31 = 0;
    transform.m32 = 0;
    transform.m33 = 1;
    transform.m34 = 0;
    transform.m41 = c / i;
    transform.m42 = f / i;
    transform.m43 = 0;
    transform.m44 = i / i;
    return transform;
}

+ (BOOL)isPoint:(CGPoint)p withinOverlay:(AROverlay*)overlay
{
    AROverlayPoint * previous = [[overlay points] lastObject];
    
    NSAssert( lineSegmentIntersection(50, 50, 0, 0, 0, 50, 50, 0, NULL, NULL) == 1, @"Crossing lines == 1");
    NSAssert( lineSegmentIntersection(350,509, 524,514, 416,0, 416,617, NULL, NULL) == 1, @"Crossing lines == 1");
    NSAssert( lineSegmentIntersection(50, 50, 0, 0, 100, 150, 150, 100, NULL, NULL) == 0, @"Non crossing lines == 0");
     
    int intersections = 0;

    for (int ii = 0; ii < [[overlay points] count]; ii++) {
        AROverlayPoint * current = [[overlay points] objectAtIndex: ii];
        if (lineSegmentIntersection(current.x, current.y, previous.x, previous.y, p.x, 0, p.x, p.y, NULL, NULL) == YES)
            intersections ++;
        
        previous = current;
    }
    
    if ((intersections & 1) == 1) {
        return YES;
    } else {
        return NO;
    }
}


@end
