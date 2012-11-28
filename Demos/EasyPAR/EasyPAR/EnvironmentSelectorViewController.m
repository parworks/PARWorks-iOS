//
//  EnvironmentSelectorViewController.m
//
//  Created by Ben Gotow on 11/15/12.
//  Copyright (c) 2012 Foundry376. All rights reserved.
//

#import "EnvironmentSelectorViewController.h"
#import "UIViewAdditions.h"


@implementation EnvironmentSelectorViewController


- (id)init
{
    self = [super init];
    if (self) {
        [self setModalPresentationStyle: UIModalPresentationFullScreen];
        [self setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary * plist = [[NSBundle mainBundle] infoDictionary];
    
    [_iconView setImage: [UIImage imageNamed: @"icon.png"]];
    [_nameLabel setText: [plist objectForKey: @"CFBundleDisplayName"]];
    [_versionLabel setText: [plist objectForKey: @"CFBundleVersion"]];
    
    servers = [[[NSUserDefaults standardUserDefaults] objectForKey: @"servers"] mutableCopy];
    if (!servers)
        servers = [[NSMutableArray alloc] init];
    
    NSObject<ServerSettingContainer> * delegate = (NSObject<ServerSettingContainer>*)[[UIApplication sharedApplication] delegate];
    if ([servers indexOfObject: [delegate APIServer]] == NSNotFound)
        [servers addObject: [delegate APIServer]];
    
    [_serversTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:servers forKey:@"servers"];
}

- (void)dealloc
{
    [servers release];
    [_iconView release];
    [_nameLabel release];
    [_versionLabel release];
    [_serversTableView release];
    [_serversContainer release];
    [_addContainer release];
    [_newServerField release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setIconView:nil];
    [self setNameLabel:nil];
    [self setVersionLabel:nil];
    [self setServersTableView:nil];
    [self setServersContainer:nil];
    [self setAddContainer:nil];
    [self setNewServerField:nil];
    [super viewDidUnload];
}

- (IBAction)saveChanges:(id)sender
{
    [self dismissModalViewControllerAnimated: YES];
}

- (IBAction)dismissNewServer:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.25];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    [_addContainer setAlpha: 0];
    [_addContainer shiftFrame: CGPointMake(0, -10)];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration: 0.25];
    [UIView setAnimationDelay: 0.3];
    [_serversContainer setAlpha: 1];
    [_serversContainer shiftFrame: CGPointMake(0, 10)];
    [UIView commitAnimations];
    
    [_newServerField resignFirstResponder];
}

- (IBAction)saveNewServer:(id)sender
{
    NSObject<ServerSettingContainer> * delegate = (NSObject<ServerSettingContainer>*)[[UIApplication sharedApplication] delegate];
    
    [servers addObject: [_newServerField text]];
    [delegate setAPIServer: [_newServerField text]];
    
    [_serversTableView reloadData];
    [self dismissNewServer: nil];
}

- (void)addCustomServer
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.25];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    [_serversContainer setAlpha: 0];
    [_serversContainer shiftFrame: CGPointMake(0, -10)];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration: 0.25];
    [UIView setAnimationDelay: 0.3];
    [_addContainer setAlpha: 1];
    [_addContainer shiftFrame: CGPointMake(0, 10)];
    [UIView commitAnimations];
    
    [_newServerField becomeFirstResponder];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [servers count] + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject<ServerSettingContainer> * delegate = (NSObject<ServerSettingContainer>*)[[UIApplication sharedApplication] delegate];
    UITableViewCell * c = [tableView dequeueReusableCellWithIdentifier:@"servercell"];
    int i = [indexPath row];
    
    if (!c)
        c = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"servercell"];
   
    [c setAccessoryType: UITableViewCellAccessoryNone];

    if (i < [servers count]) {
        [[c textLabel] setText: [servers objectAtIndex: i]];
        if ([[servers objectAtIndex: i] isEqualToString: [delegate APIServer]])
            [c setAccessoryType: UITableViewCellAccessoryCheckmark];
    } else
        [[c textLabel] setText: @"Add Site..."];
    
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject<ServerSettingContainer> * delegate = (NSObject<ServerSettingContainer>*)[[UIApplication sharedApplication] delegate];
    int current = [servers indexOfObject: [delegate APIServer]];
    
    if (current != NSNotFound)
        [[tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:current inSection:0]] setAccessoryType: UITableViewCellAccessoryNone];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([indexPath row] < [servers count]) {
        NSString * s = [servers objectAtIndex: [indexPath row]];
        [delegate setAPIServer: s];

        [[tableView cellForRowAtIndexPath: indexPath] setAccessoryType: UITableViewCellAccessoryCheckmark];
    } else {
        [self addCustomServer];
    }
}

@end
