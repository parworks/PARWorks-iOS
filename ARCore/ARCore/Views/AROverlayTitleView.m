//
//  AROverlayTitleView.m
//  ARCore
//
//  Created by Ben Gotow on 2/10/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "AROverlayTitleView.h"
#import "ARAugmentedView.h"
#import "AROverlayUtil.h"
#import "UIViewAdditions.h"
#import "AROverlayView.h"

@implementation AROverlayTitleView

@synthesize point;

- (id)initWithOverlay:(AROverlay*)overlay
{
    self = [super initWithFrame: CGRectMake(0, 0, 27, 45)];
    if (self) {
        self.overlay = overlay;
        
        UIImage * i = [UIImage imageNamed: @"tooltip_background_up.png"];
        i = [i resizableImageWithCapInsets:UIEdgeInsetsMake(11, 11, 28, 11)];
        [self setBackgroundImage:i forState:UIControlStateNormal];
        [self setContentEdgeInsets: UIEdgeInsetsMake(0, 0, 17, 0)];
        
        [self setTitleColor: [UIColor darkGrayColor] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[self titleLabel] setFont: [UIFont boldSystemFontOfSize: 14]];
        [[self titleLabel] setShadowOffset: CGSizeMake(0, 1)];
        
        _arrowView = [[UIButton alloc] initWithFrame:CGRectMake(0, 24, 8, 8)];
        [_arrowView setBackgroundImage: [UIImage imageNamed: @"tooltip_arrow_background.png"] forState: UIControlStateNormal];
        [_arrowView setUserInteractionEnabled: NO];
        [self addSubview: _arrowView];
        
        [self setAlpha: 0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected: selected];
    [_arrowView setSelected: selected];
}
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted: highlighted];
    [_arrowView setHighlighted: highlighted];
}

- (NSString*)text
{
    return [self titleForState: UIControlStateNormal];
}

- (void)layoutWithinParent:(ARAugmentedView *)parent
{
    NSArray * points = [AROverlayUtil scaledOverlayPointsForPoints:_overlay.points withScaleFactor:parent.overlayScaleFactor];
    CGRect rect = [AROverlayUtil boundingFrameForPoints: points];
    
    CGPoint p;
    if (_overlay.coverType == AROverlayCoverType_Centroid)
        p = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect) - CENTROID_SIZE / 2 + 10);
    else
        p = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
    [self showWithText:_overlay.title atPoint:p withinBounds:[parent bounds] animated:[parent animateOutlineViewDrawing]];
}

- (BOOL)showWithText:(NSString*)text atPoint:(CGPoint)p withinBounds:(CGRect)b
{
    return [self showWithText:text atPoint:p withinBounds:b animated: YES];
}

- (BOOL)showWithText:(NSString*)text atPoint:(CGPoint)p withinBounds:(CGRect)b animated:(BOOL)animated
{
    if (p.x < 0)
        return NO;
    
    [self setTitle:text forState:UIControlStateNormal];
    [self setPoint: p];
    
    // let's figure out how to optimally position ourselves within the bounds. First, compute
    // our width so that we are the correct size for our content.
    CGSize s = [text sizeWithFont:[[self titleLabel] font] constrainedToSize:CGSizeMake(b.size.width, 25) lineBreakMode:NSLineBreakByClipping];
    CGRect f = [self frame];
    
    f.size.width = ceilf(s.width / 2) * 2 + 26;
    
    CGPoint d = CGPointMake(f.size.width / 2, f.size.height * 0.65 + 8);
    f.origin.x = roundf(p.x - d.x);
    f.origin.y = roundf(p.y - d.y);
    
    if (f.origin.x < 0) {
        f.origin.x = 0;
    }
    if (f.origin.x + f.size.width > b.size.width) {
        f.origin.x = b.size.width - f.size.width;
    }
    
    float arrowPoint = p.x - f.origin.x;
    [_arrowView setFrameX: roundf(arrowPoint - _arrowView.frame.size.width / 2)];
    
    if (animated == NO) {
        [self setFrame: f];
        [self setAlpha: 1];
    } else {
        f.origin.y += 5;
        [self setFrame: f];
        [self setAlpha: 0];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration: 0.3];
        [self shiftFrame: CGPointMake(0, -5)];
        [self setAlpha: 1];
        [UIView commitAnimations];
    }
    
    if ((arrowPoint < 10) || (arrowPoint > f.size.width - 10))
        return NO;
    return YES;
}

- (void)dismiss
{
    if (self.alpha > 0) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration: 0.3];
        [self setAlpha: 0];
        [self shiftFrame: CGPointMake(0, 5)];
        [UIView commitAnimations];
    }
}



@end
