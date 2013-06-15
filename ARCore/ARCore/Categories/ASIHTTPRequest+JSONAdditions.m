//
//  ASIHTTPRequest+JSONAdditions.m
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


#import "ASIHTTPRequest+JSONAdditions.h"
#import "SBJSON.h"

@implementation ASIHTTPRequest (JSONAdditions)


- (id)responseJSON
{
    // parse the JSON
    // discover any new streams and update existing ones
    SBJsonParser * parser = [SBJsonParser new];
    id obj = nil;
    
    @try {
        obj = [parser objectWithString: [self responseString]];
    } @catch (NSException * e) {
        NSLog(@"JSON parse error: %@", [e description]);
        return [NSError errorWithDomain:@"JSONParseError" code:200 userInfo: nil];
    }
    
    if ((obj == nil) || ([parser errorTrace] != nil)) {
        NSLog(@"JSON parse error: %@", [[parser errorTrace] description]);
        return [NSError errorWithDomain:@"JSONParseError" code:200 userInfo: nil];
    }
    
//    NSLog(@"JSON parsed: %@ %@", [[self url] absoluteString], [obj description]);
    return obj;
}

- (void)setPostJSONObject:(id)obj
{
    SBJsonWriter * w = [SBJsonWriter new];
    NSData * d =  [[w stringWithObject: obj] dataUsingEncoding: NSUTF8StringEncoding];
    if (d) {
        [self setPostBody: [d mutableCopy]];
    } else {
        NSLog(@"Could not generate JSON from %@", [obj description]);
    }
}

@end
