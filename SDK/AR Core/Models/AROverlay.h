//
//  ARSiteOverlay.h
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

@class ARSite;

@interface AROverlay : NSObject <NSCoding>
{
    NSDictionary * _dict;
}

@property (nonatomic, strong) NSMutableArray * points;
@property (nonatomic, weak) ARSite * site;

// ========================
// @name Lifecycle
// ========================

/** Creates a new AROverlay object using JSON data provided by the server.

 @param dict - A dictionary of key-value pairs provided by the server.
 @return A newly initialized AROverlay instance
 */
- (id)initWithDictionary:(NSDictionary*)dict;

/** Initializes the points array using the vertex data in the object's _dict.
*/
- (void)setupVerticesFromDictionary;

- (NSString*)name;

- (NSDictionary*)dictionary;

- (BOOL)isEqual:(id)object;

@end
