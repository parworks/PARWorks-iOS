//
//  AROverlayUtil.h
//  PARWorks iOS SDK
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


#import <Foundation/Foundation.h>
#import "AROverlayView.h"

@interface AROverlayUtil : NSObject

+ (CGFloat)scaleFactorForBounds:(CGRect)bounds withImage:(UIImage *)image;
+ (CGRect)centeredAspectFitFrameForBounds:(CGRect)bounds withImage:(UIImage *)image;
+ (CGPoint)focusedCenterForOverlayView:(AROverlayView *)overlayView withParent:(UIView *)parent;
+ (NSMutableArray *)scaledOverlayPointsForPoints:(NSArray *)points withScaleFactor:(float)scaleFactor;

/** 
 @param points The set of AROverlayPoint objects that you want to find a bounding rectangle for.
 
 @return The minimum bounding frame needed to hold all the points when
 transformed.
 */
+ (CGRect)boundingFrameForPoints:(NSArray *)points;

/** Creates a CATransform3D for fitting a CALayer to any quadrilateral. This basically allows you
to say "fit this UIView into the shape defined by these four points." Used for many of our overlays.

 @param rect The bounding rectangle of the view.
 @param x1a The x-coordinate of the first corner
 @param y1a The y-coordinate of the first corner
 @param x2a The x-coordinate of the second corner
 @param y2a The y-coordinate of the second corner
 @param x3a The x-coordinate of the third corner
 @param y3a The y-coordinate of the third corner
 @param x4a The x-coordinate of the fourth corner
 @param y4a The y-coordinate of the fourth corner
 
 @return A CATransform3D object for reshaping rect to fit within the quadrilateral defined by the
 other parameters.
*/
+ (CATransform3D)rectToQuad:(CGRect)rect quadTLX:(double)x1a quadTLY:(double)y1a quadTRX:(double)x2a quadTRY:(double)y2a quadBLX:(double)x3a quadBLY:(double)y3a quadBRX:(double)x4a quadBRY:(double)y4a;
@end
