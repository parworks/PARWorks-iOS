//
//  ARSitesViewController.m
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

#import <objc/runtime.h>
#import "ARSitesViewController.h"
#import "ARAppDelegate.h"
#import "ARSiteImagesViewController.h"
#import "ASIHTTPRequest+JSONAdditions.h"
#import "MBProgressHUD.h"
#import "PARWorks.h"

#define ADD_EXISTING    0
#define ADD_NEW         1

@implementation ARSitesViewController
{
    BOOL _isFirstLoad;
    BOOL _isRefreshing;
}

#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    ARAppDelegate * delegate = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];

    _isRefreshing = NO;
    _isFirstLoad = ([delegate sites] == nil);
    
    [self setTitle: @"Sites"];
    UIImage * img = [UIImage imageNamed: @"tab-sites.png"];
    [self setTabBarItem: [[UITabBarItem alloc] initWithTitle:@"Sites" image:img tag:0]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sitesUpdated:) name:NOTIF_SITES_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sitesUpdated:) name:NOTIF_SITE_UPDATED object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // set our API key in the interface
    [_apiKeyLabel setText: PARWORKS_API_KEY];
    
    // create the upper right add button
    UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addNewSite)];
    add.enabled = NO;
    [self.navigationItem setRightBarButtonItem:add animated:YES];    
}

- (void)viewWillAppear:(BOOL)animated
{
    ARAppDelegate * delegate = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];

    [super viewWillAppear:animated];

    if (![ARManager shared].apiKey)
        return;
    
    if (_isFirstLoad) {
        _isFirstLoad = NO;
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:_progressHUD];
    }
    
     _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:delegate selector:@selector(refreshSites) userInfo:nil repeats:YES];

    if ([[delegate sites] count] == 0) {
        [self transitionContentLoading];
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [_tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}


#pragma mark - Convenience

- (void)transitionContentLoading
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    _progressHUD.labelText = @"Loading Sites";
    [_progressHUD show:YES];
}

- (void)transitionContentFinishedLoading
{
     self.navigationItem.rightBarButtonItem.enabled = YES;
    [_progressHUD hide:YES afterDelay:0.5];

    [UIView animateWithDuration:0.2 animations:^{
        _tableView.alpha = 1.0;
    }];
}


#pragma mark - Loading User Sites

- (void)sitesUpdated:(NSNotification*)notif
{
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self transitionContentFinishedLoading];
        _isRefreshing = NO;
    });
}

- (void)addNewSite
{
    UIAlertInputView * v = [[UIAlertInputView alloc] initWithDelegate: self andTitle:@"New Site Identifier" andDefaultValue: @""];
    [v setTag: ADD_NEW];
    [v show];
    [v becomeFirstResponder];
}


-(void)alertInputView:(UIAlertInputView*)view clickedButtonAtIndex:(int)index
{
    if ((index == [view cancelButtonIndex]) || ([[view textValue] length] == 0))
        return;
    
    // Create a new site with summary info. The site should be added to the table in alphabetical order.
    ARAppDelegate * delegate = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *summaryInfo = @{@"id" : [view textValue], @"numImages" : @0, @"numOverlays" : @0, @"siteState" : @"NOT_PROCESSED"};
    ARSite *s = [[ARSite alloc] initWithSummaryDictionary:summaryInfo];
    
    if ([view tag] == ADD_NEW) {
        [s setStatus: ARSiteStatusCreating];
        [[ARManager shared] addSite: [s identifier] withCompletionBlock: ^(void) {
            [s setStatus: ARSiteStatusNotProcessed];
            
            [_progressHUD hide:YES afterDelay:2.0];
            
            int row = [[delegate sites] indexOfObject:s];
            [self tableView:_tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object:s];
        }];
    }

    // Show the creation indicator.
    _progressHUD.labelText = @"Creating Site";
    [_progressHUD show:YES];
    
    [delegate addSite: s];
    [_tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    
    // Delete the site
    ARSite *site = objc_getAssociatedObject(alertView, @"site");
    NSIndexPath *indexPath = objc_getAssociatedObject(alertView, @"indexPath");

    ARAppDelegate * delegate = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate removeSite:site];
    
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView endUpdates];
    
    [[ARManager shared] removeSite:site.identifier withCompletionBlock:^{
        NSLog(@"Deleted site: %@", site);
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - UITableViewDelegate Functions

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARAppDelegate * delegate = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    ARSite *siteToDelete = [delegate sites][indexPath.row];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Deleting this site will remove all information including processed images. This operation cannot be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, I'm sure", nil];
    objc_setAssociatedObject(av, @"site", siteToDelete, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(av, @"indexPath", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [av show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    ARAppDelegate * delegate = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [delegate sites].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARAppDelegate * delegate = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    UITableViewCell * c = [tableView dequeueReusableCellWithIdentifier: @"row"];
    if (!c) c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"row"];
    
    ARSite * site = [delegate sites][indexPath.row];
    c.textLabel.text = site.identifier;
    c.detailTextLabel.text = [site description];
    
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ARAppDelegate * delegate = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    ARSite *site = [delegate sites][indexPath.row];

    ARSiteImagesViewController * vc = [[ARSiteImagesViewController alloc] initWithSite: site];
    if ([site status] != ARSiteStatusCreating)
        [self.navigationController pushViewController: vc animated:YES];
}

@end
