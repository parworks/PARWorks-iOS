//
//  BROverlayView.h
//  PAR Works iOS SDK
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


#import "AROverlayView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AdOverlayView : AROverlayView <AROverlayViewAnimationDelegate>

- (id)initWithFrame:(CGRect)frame points:(NSArray *)points andMedia:(NSString*)media ofType:(NSString*)mediaType withWebTarget:(NSURL*)webURL;

@property(nonatomic, strong) MPMoviePlayerController * player;
@property(nonatomic, strong) UIWebView * webView;

@property(nonatomic, strong) UIImageView *thumbnail;
@property(nonatomic, strong) NSURL * webURL;
@property(nonatomic, strong) NSString * media;
@property(nonatomic, strong) NSString * mediaType;

@end
