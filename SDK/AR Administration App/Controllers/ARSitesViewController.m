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


#import "ARSitesViewController.h"
#import "ARAppDelegate.h"
#import "ARSiteImagesViewController.h"
#import "ASIHTTPRequest+JSONAdditions.h"
#import "PARWorks.h"

#define ADD_EXISTING    0
#define ADD_NEW         1

@implementation ARSitesViewController

@synthesize tableView = _tableView;

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
    [self setTitle: @"Sites"];
    [self setTabBarItem: [[UITabBarItem alloc] initWithTabBarSystemItem: UITabBarSystemItemBookmarks tag:0]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteUpdated:) name:NOTIF_SITE_UPDATED object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_apiKeyLabel setText: PARWORKS_API_KEY];
    
    // create the upper right add button
    UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addSite:)];
    [self.navigationItem setRightBarButtonItem:add animated:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateSitesStatus) userInfo:nil repeats:YES];
}

- (void)updateSitesStatus
{
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    for (ARSite * s in [d sites]) {
        if ([s status] != ARSiteStatusProcessed)
            [s checkStatus];
    }
}

- (void)addSite:(id)sender
{
    UIActionSheet * s = [[UIActionSheet alloc] initWithTitle:@"Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New Site", @"Existing Site", nil];
    [s showFromTabBar: self.tabBarController.tabBar];
}

- (void)addExistingSite
{
    UIAlertInputView * v = [[UIAlertInputView alloc] initWithDelegate: self andTitle:@"Existing Site Identifier" andDefaultValue: @""];
    [v setTag: ADD_EXISTING];
    [v show];
    [v becomeFirstResponder];
}

- (void)addNewSite
{
    UIAlertInputView * v = [[UIAlertInputView alloc] initWithDelegate: self andTitle:@"Site Identifier" andDefaultValue: @""];
    [v setTag: ADD_NEW];
    [v show];
    [v becomeFirstResponder];
}


- (void)siteUpdated:(NSNotification*)notif
{
    [_tableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex])
        return;
        
    if (buttonIndex == 0)
        [self addNewSite];
    else
        [self addExistingSite];
}

-(void)alertInputView:(UIAlertInputView*)view clickedButtonAtIndex:(int)index
{
    if ((index == [view cancelButtonIndex]) || ([[view textValue] length] == 0))
        return;
        
    ARAppDelegate * delegate = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    ARSite * s = [[ARSite alloc] init];
    [s setIdentifier: [view textValue]];

    if ([view tag] == ADD_NEW)
        [s setStatus: ARSiteStatusCreating];
        [[ARManager shared] addSite: [s identifier] withCompletionBlock: ^(void) {
            [s setStatus: ARSiteStatusNotProcessed];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SITE_UPDATED object:s];
        }];

    [delegate addSite: s];
    [_tableView reloadData];
}

- (void)viewDidUnload
{
    [self setApiKeyLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark UITableViewDelegate Functions
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    ARSite *siteToDelete;
    for (ARSite *site in d.sites) {
        if ([[site.identifier lowercaseString] isEqualToString:[cell.textLabel.text lowercaseString]]) {
            siteToDelete = site;
            break;
        }
    }
    
    [d removeSite:siteToDelete];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [[d sites] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * c = [tableView dequeueReusableCellWithIdentifier: @"row"];
    if (!c) c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"row"];
    
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    ARSite * site = [[d sites] objectAtIndex: [indexPath row]];
    [[c textLabel] setText: [site identifier]];
    [[c detailTextLabel] setText: [site description]];
    
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    ARSite * site = [[d sites] objectAtIndex: [indexPath row]];
    ARSiteImagesViewController * vc = [[ARSiteImagesViewController alloc] initWithSite: site];
    if ([site status] != ARSiteStatusCreating)
        [self.navigationController pushViewController: vc animated:YES];
}

@end
