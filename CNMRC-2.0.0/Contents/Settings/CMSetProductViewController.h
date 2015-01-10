//
//  CMSetProductViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 8..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBaseViewController.h"

@interface CMSetProductViewController : CMBaseViewController <UITableViewDataSource, UITableViewDelegate, CMHTTPClientDelegate>

@property (strong, nonatomic) NSString *areaCode;
@property (strong, nonatomic) NSString *areaName;
@property (weak, nonatomic) IBOutlet UITableView *listTable;
@property (strong, nonatomic) NSMutableArray *products;

@end
