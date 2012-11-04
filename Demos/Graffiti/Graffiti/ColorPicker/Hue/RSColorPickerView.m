//
//  RSColorPickerView.m
//  RSColorPicker
//
//  Created by Ryan Sullivan on 8/12/11.
//  Copyright 2011 Freelance Web Developer. All rights reserved.
//

#import "DMColorPickerConstants.h"
#import "DMColorPickerMask.h"
#import "DMIndicatorView.h"
#import "RSColorPickerView.h"
#import "RSColorPickerView+CircularTracking.h"
#import "BGRSLoupeLayer.h"
#import "UIView+Layout.h"

// point-related macros
#define INNER_P(x) (x < 0 ? ceil(x) : floor(x))
#define IS_INSIDE(p) (round(p.x) >= 0 && round(p.x) < self.frame.size.width && round(p.y) >= 0 && round(p.y) < self.frame.size.height)
#define MY_MIN3(x,y,z) MIN(x,MIN(y,z))
#define MY_MAX3(x,y,z) MAX(x,MAX(y,z))

// Concept-code from http://www.easyrgb.com/index.php?X=MATH&H=21#text21
BMPixel pixelFromHSV(CGFloat H, CGFloat S, CGFloat V) {
	if (S == 0) {
		return BMPixelMake(V, V, V, 1.0);
	}
	CGFloat var_h = H * 6.0;
	if (var_h == 6.0) {
		var_h = 0.0;
	}
	CGFloat var_i = floor(var_h);
	CGFloat var_1 = V * (1.0 - S);
	CGFloat var_2 = V * (1.0 - S * (var_h - var_i));
	CGFloat var_3 = V * (1.0 - S * (1.0 - (var_h - var_i)));
	
	if (var_i == 0) {
		return BMPixelMake(V, var_3, var_1, 1.0);
	} else if (var_i == 1) {
		return BMPixelMake(var_2, V, var_1, 1.0);
	} else if (var_i == 2) {
		return BMPixelMake(var_1, V, var_3, 1.0);
	} else if (var_i == 3) {
		return BMPixelMake(var_1, var_2, V, 1.0);
	} else if (var_i == 4) {
		return BMPixelMake(var_3, var_1, V, 1.0);
	}
	return BMPixelMake(V, var_1, var_2, 1.0);
}

void HSVFromPixel(BMPixel pixel, CGFloat* h, CGFloat* s, CGFloat* v) {
    CGFloat rgb_min, rgb_max;
    CGFloat hsv_hue, hsv_val, hsv_sat;
    rgb_min = MY_MIN3(pixel.red, pixel.green, pixel.blue);
    rgb_max = MY_MAX3(pixel.red, pixel.green, pixel.blue);
    
    if (rgb_max == rgb_min) {
        hsv_hue = 0;
    } else if (rgb_max == pixel.red) {
        hsv_hue = 60.0f * ((pixel.green - pixel.blue) / (rgb_max - rgb_min));
        hsv_hue = fmodf(hsv_hue, 360.0f);
    } else if (rgb_max == pixel.green) {
        hsv_hue = 60.0f * ((pixel.blue - pixel.red) / (rgb_max - rgb_min)) + 120.0f;
    } else if (rgb_max == pixel.blue) {
        hsv_hue = 60.0f * ((pixel.red - pixel.green) / (rgb_max - rgb_min)) + 240.0f;
    }
    
    hsv_val = rgb_max;
    if (rgb_max == 0) {
        hsv_sat = 0;
    } else {
        hsv_sat = 1.0 - (rgb_min / rgb_max);
    }
    
    *h = hsv_hue;
    *s = hsv_sat;
    *v = hsv_val;
}


@interface RSColorPickerView (Private)
-(void)initRoutine;
-(void)updateSelectionLocation;
-(CGPoint)validPointForTouch:(CGPoint)touchPoint;
@end


@implementation RSColorPickerView

- (id)initWithFrame:(CGRect)frame
{
	CGFloat sqr = fmin(frame.size.height, frame.size.width);
	frame.size = CGSizeMake(sqr, sqr);
	
	self = [super initWithFrame:frame];
	if (self) {
		[self initRoutine];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initRoutine];
    }
    return self;
}

-(void)initRoutine
{
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    
    CGRect frame = self.frame;
    CGFloat sqr = fmin(frame.size.height, frame.size.width);
    
    _cropToCircle = YES;
    _badTouch = NO;
    _bitmapNeedsUpdate = YES;
    self.backgroundColor = [UIColor clearColor];
    
    // Add the white strokes to each edge of the view.
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = self.bounds.size.width/2;
    
    CAShapeLayer *outerStroke = [CAShapeLayer layer];
    outerStroke.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius-1 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
    outerStroke.contentsScale = [UIScreen mainScreen].scale;
    outerStroke.fillColor = [UIColor clearColor].CGColor;
    outerStroke.strokeColor = [UIColor whiteColor].CGColor;
    outerStroke.lineWidth = 3.0;
    [self.layer addSublayer:outerStroke];
    
    CAShapeLayer *innerStroke = [CAShapeLayer layer];
    innerStroke.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius - kDMColorPickerMaskStrokeWidth + 2 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
    innerStroke.contentsScale = [UIScreen mainScreen].scale;
    innerStroke.fillColor = [UIColor clearColor].CGColor;
    innerStroke.strokeColor = [UIColor whiteColor].CGColor;
    innerStroke.lineWidth = 3.0;
    [self.layer addSublayer:innerStroke];

    
    _selection = CGPointMake(sqr/2, sqr/2);
    _indicator = [[DMIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, kDMColorPickerIndicatorRadius*2, kDMColorPickerIndicatorRadius*2)];
    [self updateSelectionLocationDisableActions:NO];
    [self addSubview:_indicator];
    
    self.brightness = 1.0;
    _rep = [[ANImageBitmapRep alloc] initWithSize:BMPointFromSize(frame.size)];
    
    _mask = [[DMColorPickerMask alloc] initWithFrame:self.bounds];
    self.layer.mask = _mask.layer;
}

-(void)setBrightness:(CGFloat)bright {
	_brightness = bright;
	_bitmapNeedsUpdate = YES;
	[self setNeedsDisplay];
	[_delegate colorPickerDidChangeSelection:self];
}

-(void)setCropToCircle:(BOOL)circle {
	if (circle == _cropToCircle) { return; }
	_cropToCircle = circle;
    _bitmapNeedsUpdate = YES;
	[self setNeedsDisplay];
}

-(void)genBitmap {
	if (!_bitmapNeedsUpdate) return;
    
	CGFloat radius = (_rep.bitmapSize.x / 2.0);
	CGFloat relX = 0.0;
	CGFloat relY = 0.0;
	
	for (int x = 0; x < _rep.bitmapSize.x; x++) {
		relX = x - radius;
		
		for (int y = 0; y < _rep.bitmapSize.y; y++) {
			relY = radius - y;
			
			CGFloat r_distance = sqrt((relX * relX)+(relY * relY));
			if (fabsf(r_distance) > radius && _cropToCircle == YES) {
				[_rep setPixel:BMPixelMake(0.0, 0.0, 0.0, 0.0) atPoint:BMPointMake(x, y)];
				continue;
			}
			r_distance = fmin(r_distance, radius);
			
			CGFloat angle = atan2(relY, relX);
			if (angle < 0.0) { angle = (2.0 * M_PI)+angle; }
			
			CGFloat perc_angle = angle / (2.0 * M_PI);
			BMPixel thisPixel = pixelFromHSV(perc_angle, r_distance/radius, self.brightness);
			[_rep setPixel:thisPixel atPoint:BMPointMake(x, y)];
		}
	}
	_bitmapNeedsUpdate = NO;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	[self genBitmap];
	[[_rep image] drawInRect:rect];
    
    // Draw the strokes around the circular path
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextRestoreGState(context);
}


-(UIColor*)selectionColor {
    [self genBitmap];
	return UIColorFromBMPixel([_rep getPixelAtPoint:BMPointFromPoint(_selection)]);
}
-(CGPoint)selection {
	return _selection;
}
-(void)setSelectionColor:(UIColor *)selectionColor {
    const float* comps = CGColorGetComponents(selectionColor.CGColor);
    BMPixel pixel = BMPixelMake(comps[0], comps[1], comps[2], 1);
    
    // convert to HSV
    CGFloat h, s, v;
    HSVFromPixel(pixel, &h, &s, &v);
    
    // extract the original point
    CGFloat radius = (_rep.bitmapSize.x / 2.0);
    CGFloat angle = h * (M_PI / 180);
    CGFloat centerDistance = s * radius;
    
    CGFloat pointX = cos(angle) * centerDistance + radius;
    CGFloat pointY = radius - sin(angle) * centerDistance;
    _selection = CGPointMake(pointX, pointY);
    
    [self updateSelectionLocation];
    [self setBrightness:v];
}

/**
 * Hue saturation and briteness of the selected point
 * @Reference: Taken from ars/uicolor-utilities 
 * http://github.com/ars/uicolor-utilities
 */
-(void)selectionToHue:(CGFloat *)pH saturation:(CGFloat *)pS brightness:(CGFloat *)pV{
	
	//Get red green and blue from selection
	BMPixel pixel = [_rep getPixelAtPoint:BMPointFromPoint(_selection)];
	CGFloat r = pixel.red, b = pixel.blue, g = pixel.green;
	
	CGFloat h,s,v;
	
	// From Foley and Van Dam
	CGFloat max = MAX(r, MAX(g, b));
	CGFloat min = MIN(r, MIN(g, b));
	
	// Brightness
	v = max;
	
	// Saturation
	s = (max != 0.0f) ? ((max - min) / max) : 0.0f;
	
	if (s == 0.0f) {
		// No saturation, so undefined hue
		h = 0.0f;
	} else {
		// Determine hue
		CGFloat rc = (max - r) / (max - min);		// Distance of color from red
		CGFloat gc = (max - g) / (max - min);		// Distance of color from green
		CGFloat bc = (max - b) / (max - min);		// Distance of color from blue
		
		if (r == max) h = bc - gc;					// resulting color between yellow and magenta
		else if (g == max) h = 2 + rc - bc;			// resulting color between cyan and yellow
		else /* if (b == max) */ h = 4 + gc - rc;	// resulting color between magenta and cyan
		
		h *= 60.0f;									// Convert to degrees
		if (h < 0.0f) h += 360.0f;					// Make non-negative
		h /= 360.0f;                                // Convert to decimal
	}
	
	if (pH) *pH = h;
	if (pS) *pS = s;
	if (pV) *pV = v;
}

-(UIColor*)colorAtPoint:(CGPoint)point {
    if (IS_INSIDE(point)){
        return UIColorFromBMPixel([_rep getPixelAtPoint:BMPointFromPoint(point)]);
    }
    return self.backgroundColor;
}

-(CGPoint)validPointForTouch:(CGPoint)touchPoint {
	if (!_cropToCircle) {
		//Constrain point to inside of bounds
		touchPoint.x = MIN(CGRectGetMaxX(self.bounds)-1, touchPoint.x);
		touchPoint.x = MAX(CGRectGetMinX(self.bounds),   touchPoint.x);
		touchPoint.y = MIN(CGRectGetMaxX(self.bounds)-1, touchPoint.y);
		touchPoint.y = MAX(CGRectGetMinX(self.bounds),   touchPoint.y);
		return touchPoint;
	}
	
	BMPixel pixel = BMPixelMake(0.0, 0.0, 0.0, 0.0);
    touchPoint = [self circularPointForTouchPoint:touchPoint withRadius:(self.width/2)-kDMColorPickerIndicatorRadius];
    
	if (IS_INSIDE(touchPoint)) {
		pixel = [_rep getPixelAtPoint:BMPointFromPoint(touchPoint)];
	}
	
	if (pixel.alpha > 0.0) {
		return touchPoint;
	}
	
	// the point is invalid, so we will put it in a valid location.
	CGFloat radius = (self.frame.size.width / 2.0);
	CGFloat relX = touchPoint.x - radius;
	CGFloat relY = radius - touchPoint.y;
	CGFloat angle = atan2(relY, relX);
	
	if (angle < 0) { angle = (2.0 * M_PI) + angle; }
	relX = INNER_P(cos(angle) * radius);
	relY = INNER_P(sin(angle) * radius);
	
	while (relX >= radius)  { relX -= 1; }
	while (relX <= -radius) { relX += 1; }
	while (relY >= radius)  { relY -= 1; }
	while (relY <= -radius) { relY += 1; }
	return CGPointMake(round(relX + radius), round(radius - relY));
}

-(void)updateSelectionLocation {
    [self updateSelectionLocationDisableActions:YES];
}

-(void)updateSelectionLocationDisableActions: (BOOL)disable {
   _indicator.center = _selection;
   if(disable) {
       [CATransaction setDisableActions:YES];
   }
    _indicator.color = [self selectionColor];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   
   //Lazily load loupeLayer
    if (!_indicator){
        _indicator = [[DMIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kDMColorPickerIndicatorRadius*2, kDMColorPickerIndicatorRadius*2)];
        [self addSubview:_indicator];
    }
    
	CGPoint point = [[touches anyObject] locationInView:self];
	CGPoint circlePoint = [self validPointForTouch:point];
    
    CGFloat distance = distanceBetweenPoints(point, circlePoint);
    
	BMPixel checker = [_rep getPixelAtPoint:BMPointFromPoint(point)];
	if (!(checker.alpha > 0.0) || distance > 20) {
		_badTouch = YES;
		return;
	}
	_badTouch = NO;
	
	BMPixel pixel = [_rep getPixelAtPoint:BMPointFromPoint(circlePoint)];
	NSAssert(pixel.alpha >= 0.0, @"-validPointForTouch: returned invalid point.");
	
	_selection = circlePoint;
	[_delegate colorPickerDidChangeSelection:self];
	
    [self updateSelectionLocation];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_badTouch) return;
	
	CGPoint point = [[touches anyObject] locationInView:self];
	CGPoint circlePoint = [self validPointForTouch:point];
	
	BMPixel pixel = [_rep getPixelAtPoint:BMPointFromPoint(circlePoint)];
	NSAssert(pixel.alpha >= 0.0, @"-validPointForTouch: returned invalid point.");
	
	_selection = circlePoint;
	[_delegate colorPickerDidChangeSelection:self];
	[self updateSelectionLocation];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_badTouch) return;
	
	CGPoint point = [[touches anyObject] locationInView:self];
	CGPoint circlePoint = [self validPointForTouch:point];
	
	BMPixel pixel = [_rep getPixelAtPoint:BMPointFromPoint(circlePoint)];
	NSAssert(pixel.alpha >= 0.0, @"-validPointForTouch: returned invalid point.");
	
	_selection = circlePoint;
	[_delegate colorPickerDidChangeSelection:self];
    [self updateSelectionLocation];
}

@end
