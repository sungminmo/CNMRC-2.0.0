//
//  CMSettingsViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 17..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Setting.h"

@interface CMSettingsViewController : CMBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Setting *setting;
@property (weak, nonatomic) IBOutlet UITableView *settingsTable;
@property (strong, nonatomic) NSMutableArray *settings;

@end
