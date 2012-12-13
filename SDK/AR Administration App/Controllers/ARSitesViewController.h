//
//  ARSitesViewController.h
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


#import <UIKit/UIKit.h>
#import "UIAlertInputView.h"

@class MBProgressHUD;

@interface ARSitesViewController : UIViewController <UIActionSheetDelegate, UIAlertInputViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSIndexPath     *_deleteIndexPath;
    MBProgressHUD   *_progressHUD;
    NSTimer         *_refreshTimer;
}

@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UILabel *apiKeyLabel;

@end
