//
//  CMSearchViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 17..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

// 메뉴 타입.
typedef NS_ENUM(NSInteger, CMSearchType) {
    CMSearchTypeVOD = 0,
    CMSearchTypeProgram,
    CMSearchTypeNaver
};

@interface CMSearchViewController : CMBaseViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CMHTTPClientDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *vodButton;
@property (weak, nonatomic) IBOutlet UIButton *programButton;
@property (weak, nonatomic) IBOutlet UIButton *naverButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteSearchHistoryButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;

@property (weak, nonatomic) IBOutlet UITableView *resultTable;
@property (strong, nonatomic) NSMutableArray *results;

- (IBAction)searchTypeAction:(id)sender;
- (IBAction)deleteSearchHistoryAction:(id)sender;

@end
