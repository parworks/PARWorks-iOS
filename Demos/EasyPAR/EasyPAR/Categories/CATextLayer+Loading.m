//
//  CATextLayer+Loading.m
//  EasyPAR
//
//  Created by Demetri Miller on 10/9/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//

#import <objc/runtime.h>
#import "CATextLayer+Loading.h"

@implementation CATextLayer (Loading)

NSString * const layerTimerKey = @"timerKey";

- (void)startLoadingAnimation
{
    [CATransaction begin];
    [CATransaction setAnimationDuration: 0.3];
    self.opacity = 1.0;
    [CATransaction commit];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(appendPeriod) userInfo:nil repeats:YES];
    objc_setAssociatedObject(self, (__bridge const void *)(layerTimerKey), timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)appendPeriod
{
    NSMutableString *text = [self.string mutableCopy];
    int count = [self numEndingPeriodsForString:text];
    
    [text replaceCharactersInRange:NSMakeRange(text.length-count, count) withString:@""];
    count = (count+1)%4;
    for (int i=0; i<count; i++) {
        [text appendString:@"."];
    }
    
    self.string = text;
}

- (int)numEndingPeriodsForString:(NSString *)str
{
    int count = 0;
    int loc = str.length - 1;
    while ([str characterAtIndex:loc] == '.') {
        count++;
        loc--;
    }
    return count;
}

- (void)clearEndingPeriods
{
    int count = [self numEndingPeriodsForString:self.string];
    self.string = [self.string stringByReplacingCharactersInRange:NSMakeRange(((NSString *)self.string).length-count, count) withString:@""];
}

- (void)stopLoadingAnimation
{
    self.opacity = 0.0;
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(self, (__bridge const void *)(layerTimerKey));
    [timer invalidate];    
}


@end
