//
//  ARCameraVC_iPad.m
//  SquareCam 
//
//  Created by Demetri Miller on 5/2/13.
//
//

#import "ARCameraVC_iPad.h"
#import "DMRotatableCameraHUD.h"

#define kRotationMaskHeight 200

@implementation ARCameraVC_iPad
{
    // Sits above the toolbar masking the preview layer during rotations.
    UIView *_rotationMask;
    BOOL _isFirstLoad;
}


#pragma mark - Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isFirstLoad = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isFirstLoad) {
        _isFirstLoad = NO;
        
        [self.view bringSubviewToFront:_hud];
        _rotationMask = [[UIView alloc] initWithFrame:CGRectMake(0, -kRotationMaskHeight, self.view.bounds.size.width, kRotationMaskHeight)];
        _rotationMask.backgroundColor = [UIColor blackColor];
        _rotationMask.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_toolbarView addSubview:_rotationMask];
    }
    
}
@end
