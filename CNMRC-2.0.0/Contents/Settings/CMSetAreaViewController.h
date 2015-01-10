//
//  CMSetAreaViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 8..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBaseViewController.h"

@interface CMSetAreaViewController : CMBaseViewController <UITableViewDataSource, UITableViewDelegate, CMHTTPClientDelegate>

@property (weak, nonatomic) IBOutlet UITableView *listTable;
@property (strong, nonatomic) NSMutableArray *areas;

@end
