//
//  AROverlayDataEditorViewController.m
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


#import "AROverlayDataEditorViewController.h"

@interface AROverlayDataEditorViewController ()

@end

@implementation AROverlayDataEditorViewController

- (id)initWithOverlay:(AROverlay *)overlay
{
    self = [super initWithNibName:@"AROverlayDataEditorViewController" bundle:nil];
    if (self) {
        _overlay = overlay;
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
    NSURL *jqueryURL = [[NSBundle mainBundle] URLForResource:@"jquery-1.9.0.min" withExtension:@"js"];
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"overlay_editor_form" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    html = [html stringByReplacingOccurrencesOfString:@"{{JQUERY_FILEPATH}}" withString:jqueryURL.absoluteString];
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)doneTapped:(id)sender
{

    [_overlay save];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *)dictionaryFromFormString:(NSString *)formString
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *components = [formString componentsSeparatedByString:@"&"];
    for (NSString *s in components) {
        NSArray *tuple = [s componentsSeparatedByString:@"="];
        if (tuple.count == 2) {
            [dict setObject:tuple[1] forKey:tuple[0]];
        }
    }
    return dict;
}

- (NSString *)jsonStringFromFormString:(NSString *)formString
{
    NSDictionary *formDict = [self dictionaryFromFormString:formString];
    NSData *data = [NSJSONSerialization dataWithJSONObject:formDict options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return jsonString;
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStart = YES;
    if ([request.URL.scheme isEqualToString:@"parworks"]) {
        shouldStart = NO;
        NSString *formString = [webView stringByEvaluatingJavaScriptFromString:@"showValues()"];
        NSString *json = [self jsonStringFromFormString:formString];
        NSLog(@"%@",json);
    }
    return shouldStart;
}

@end
