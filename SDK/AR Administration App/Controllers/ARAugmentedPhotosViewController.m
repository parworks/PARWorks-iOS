//
//  ARAugmentedPhotosViewController.m
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


#import "ARAugmentedPhotosViewController.h"
#import "ARPhotoViewController.h"
#import "ARAppDelegate.h"
#import "PARWorks.h"

@implementation ARAugmentedPhotosViewController

@synthesize tableView = _tableView;

- (id)init
{
    self = [super init];
    if (self) {
        [self setTitle: @"Photos"];
        
        UIImage * img = [UIImage imageNamed: @"tab-photos.png"];
        [self setTabBarItem: [[UITabBarItem alloc] initWithTitle:@"Photos" image:img tag:1]];

    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:NOTIF_AUGMENTED_PHOTO_UPDATED object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create the upper left clear button
    UIBarButtonItem * clear = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearPhotos:)];
    [self.navigationItem setLeftBarButtonItem:clear animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView reloadData];
}

- (void)reloadData
{
    [_tableView reloadData];
    
    // count the number of processing photos
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    int total = 0;
    for (ARSite * s in [d sites])
        for (ARAugmentedPhoto * p in [s augmentedPhotos])
            if ((p.response == BackendResponseProcessing) || (p.response == BackendResponseUploading))
                total ++;
    
    if (total > 0)
        [self.tabBarItem setBadgeValue: [NSString stringWithFormat: @"%d", total]];
    else
        [self.tabBarItem setBadgeValue: nil];
}

- (void)clearPhotos:(id)sender
{
    ARAppDelegate * d = (ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    for (ARSite * s in [d sites])
        [s removeAllAugmentedPhotos];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITableViewDelegate Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [[d sites] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    ARSite * s = [[d sites] objectAtIndex: section];
    return [s identifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    ARSite * s = [[d sites] objectAtIndex: section];
    return [[s augmentedPhotos] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    UITableViewCell * c = [tableView dequeueReusableCellWithIdentifier: @"row"];
    if (!c) c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"row"];
    
    ARSite * site = [[d sites] objectAtIndex: [indexPath section]];
    ARAugmentedPhoto * p = [[site augmentedPhotos] objectAtIndex: [indexPath row]];
    NSString * n = [p imageIdentifier];
    
    if ([n length] > 14)
        n = [n substringToIndex: 14];
        
    [[c textLabel] setText: n];
    [[c imageView] setImage: [p image]];
    
    if ([p response] == BackendResponseUploading)
        [[c detailTextLabel] setText: @"Uploading..."];
    else if ([p response] == BackendResponseProcessing)
        [[c detailTextLabel] setText: @"Processing..."];
    else if ([p response] == BackendResponseFailed)
        [[c detailTextLabel] setText: @"Failed"];
    else
        [[c detailTextLabel] setText: [NSString stringWithFormat: @"%d 📌", [[p overlays] count]]];
    
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ARAppDelegate * d = (ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    ARSite * site = [[d sites] objectAtIndex: [indexPath section]];
    ARAugmentedPhoto * p = [[site augmentedPhotos] objectAtIndex: [indexPath row]];
    
    ARPhotoViewController * vc = [[ARPhotoViewController alloc] initWithAugmentedPhoto: p];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
