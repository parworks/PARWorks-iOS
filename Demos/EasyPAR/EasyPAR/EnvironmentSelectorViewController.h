//
//  EnvironmentSelectorViewController.h
//
//  Created by Ben Gotow on 11/15/12.
//  Copyright (c) 2012 Foundry376. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServerSettingContainer <NSObject>

- (void)setAPIServer:(NSString*)server;
- (NSString*)APIServer;

@end

@interface EnvironmentSelectorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * servers;
}

@property (retain, nonatomic) IBOutlet UIImageView *iconView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *versionLabel;
@property (retain, nonatomic) IBOutlet UITableView *serversTableView;
@property (retain, nonatomic) IBOutlet UIView *addContainer;
@property (retain, nonatomic) IBOutlet UIView *serversContainer;
@property (retain, nonatomic) IBOutlet UITextField *newServerField;

- (IBAction)saveChanges:(id)sender;
- (IBAction)saveNewServer:(id)sender;

@end
