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
#import "PARWorks.h"

#define ADD_EXISTING    0
#define ADD_NEW         1

@implementation ARSitesViewController
{
    BOOL _isFirstLoad;
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
    _isFirstLoad = YES;
    [self setTitle: @"Sites"];
    [self setTabBarItem: [[UITabBarItem alloc] initWithTabBarSystemItem: UITabBarSystemItemBookmarks tag:0]];
    
    _currentUserSites = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_apiKeyLabel setText: PARWORKS_API_KEY];
    
    // create the upper right add button
    UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addNewSite)];
    add.enabled = NO;
    [self.navigationItem setRightBarButtonItem:add animated:YES];
    
    // Show the loading label while we load the user's sites.
    _tableView.alpha = _loadingIndicator.alpha = _loadingLabel.alpha = 0.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteUpdated:) name:NOTIF_SITE_UPDATED object:nil];

    if (![ARManager shared].apiKey) {
        return;
    }
    
    if (_currentUserSites.count == 0) {
        [self transitionContentLoading];
    } else {
        [self refreshCurrentUserSites];
    }
    
    if (_currentUserSites.count > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Convenience
- (void)transitionContentLoading
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _loadingIndicator.alpha = 1.0;
        _loadingLabel.alpha = 1.0;
    }];
    [_loadingIndicator startAnimating];
}

- (void)transitionContentFinishedLoading
{
     self.navigationItem.rightBarButtonItem.enabled = YES;
    _loadingIndicator.alpha = 0.0;
    _loadingLabel.alpha = 0.0;

    [UIView animateWithDuration:0.2 animations:^{
        _tableView.alpha = 1.0;
    }];
}

#pragma mark - Loading User Sites
- (void)refreshCurrentUserSites
{
    __weak ARSitesViewController *blockSelf = self;
    __weak NSMutableArray *weakSites = _currentUserSites;
    [[ARManager shared] sitesForCurrentAPIKey:^(NSArray *sites) {
        [weakSites removeAllObjects];
        
        // TODO: Create site objects for each site returned.
        
        [weakSites addObjectsFromArray:sites];
        [blockSelf.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [blockSelf transitionContentFinishedLoading];
        });
    }];
}

- (void)siteUpdated:(NSNotification*)notif
{
    [self refreshCurrentUserSites];
}

- (void)updateSitesStatus
{
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    for (ARSite * s in [d sites]) {
        if ([s status] != ARSiteStatusProcessed)
            [s checkStatus];
    }
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
        
    ARAppDelegate * delegate = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    ARSite *s = [[ARSite alloc] init];
    [s setIdentifier: [view textValue]];

    if ([view tag] == ADD_NEW) {
        [s setStatus: ARSiteStatusCreating];
        [[ARManager shared] addSite: [s identifier] withCompletionBlock: ^(void) {
            [s setStatus: ARSiteStatusNotProcessed];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object:s];
        }];
    }
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
    [_currentUserSites removeObjectAtIndex:indexPath.row];
    
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView endUpdates];
    
    [[ARManager shared] removeSite:site.identifier withCompletionBlock:^{
        NSLog(@"Deleted site: %@", site);
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
    ARSite *siteToDelete = [[ARSite alloc] initWithIdentifier:_currentUserSites[indexPath.row]];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Deleting this site will remove all information including processed images. This operation cannot be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, I'm sure", nil];
    objc_setAssociatedObject(av, @"site", siteToDelete, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(av, @"indexPath", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [av show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _currentUserSites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * c = [tableView dequeueReusableCellWithIdentifier: @"row"];
    if (!c) c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"row"];
    
    ARSite * site = [[ARSite alloc] initWithIdentifier:_currentUserSites[indexPath.row]];
    site.status = ARSiteStatusUnknown;
    objc_setAssociatedObject(c, @"site", site, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    c.textLabel.text = _currentUserSites[indexPath.row];
    
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ARSite *site = objc_getAssociatedObject(c, @"site");

    ARSiteImagesViewController * vc = [[ARSiteImagesViewController alloc] initWithSite: site];
    if ([site status] != ARSiteStatusCreating)
        [self.navigationController pushViewController: vc animated:YES];
}

@end
