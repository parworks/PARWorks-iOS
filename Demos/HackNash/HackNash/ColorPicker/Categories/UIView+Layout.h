//
//  UIViewAdditions.h
//

#import <UIKit/UIKit.h>


@interface UIView (Layout)

// Position of the top-left corner in superview's coordinates
@property CGPoint position;
@property CGFloat x;
@property CGFloat y;

// Setting size keeps the position (top-left corner) constant
@property CGSize size;
@property CGFloat width;
@property CGFloat height;

CGFloat distanceBetweenPoints(CGPoint p1, CGPoint p2);

@end