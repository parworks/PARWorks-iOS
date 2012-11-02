//
//  UILabel+Loading.m
//  SIDemo
//
//  Created by Demetri Miller on 10/9/12.
//  Copyright (c) 2012 Demetri Miller. All rights reserved.
//
#import <objc/runtime.h>
#import "UILabel+Loading.h"

@implementation UILabel (Loading)

NSString * const timerKey = @"timerKey";

- (void)startLoadingAnimation
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(appendPeriod) userInfo:nil repeats:YES];
    objc_setAssociatedObject(self, (__bridge const void *)(timerKey), timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)appendPeriod
{
    NSMutableString *text = [self.text mutableCopy];
    int count = [self numEndingPeriodsForString:text];
    
    [text replaceCharactersInRange:NSMakeRange(text.length-count, count) withString:@""];
    count = (count+1)%4;
    for (int i=0; i<count; i++) {
        [text appendString:@"."];
    }
    
    self.text = text;
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
    int count = [self numEndingPeriodsForString:self.text];
    self.text = [self.text stringByReplacingCharactersInRange:NSMakeRange(self.text.length-count, count) withString:@""];
}

- (void)stopLoadingAnimation
{
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(self, (__bridge const void *)(timerKey));
    [timer invalidate];
    [self clearEndingPeriods];
    
}


@end
