//
//  CMDetailListViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 26..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMVODListViewController.h"
#import "CMTableViewCell.h"
#import "CMVODListTableViewCell.h"
#import "CMVODDetailViewController.h"
#import "DQAlertView.h"

@interface CMVODListViewController ()
{
    BOOL _isMoreCenre;  // 하위 장르 존재 유무.
}

- (void)requestDataWithGenreID:(NSString *)genreID andType:(BOOL)type;
@end

@implementation CMVODListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = [self.data valueForKey:@"Genre_Title"];
    
    // 글자수에 따라 타이틀의 폰트 크기를 조절한다.
    if ([self.titleLabel.text length] > 6)
    {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    
    if ([[self.data valueForKey:@"Genre_More"] isEqualToString:@"YES"])
    {
        _isMoreCenre = YES;
    }
    else
    {
        _isMoreCenre = NO;
    }
    
    [self requestDataWithGenreID:[self.data valueForKey:@"GenreId"] andType:_isMoreCenre];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 상속 메서드

// 데이터 갱신.
- (void)handleRefreshList:(UIRefreshControl *)refreshControl
{
    DDLogDebug(@"데이터 갱신");
    
    if ([[self.data valueForKey:@"Genre_More"] isEqualToString:@"YES"])
    {
        _isMoreCenre = YES;
    }
    else
    {
        _isMoreCenre = NO;
    }
    
    // 데이터 요청.
    [self requestDataWithGenreID:[self.data valueForKey:@"GenreId"] andType:_isMoreCenre];
    
    [refreshControl endRefreshing];
}

#pragma mark - 프라이빗 메서드

- (void)requestDataWithGenreID:(NSString *)genreID andType:(BOOL)type
{
    NSURL *url = nil;
    NSDictionary *dict = nil;
    
    if (type)
    {
        url = [CMGenerator genURLWithInterface:CNM_OPEN_API_INTERFACE_GetVodGenre];
        dict = @{
                 CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                 CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                 CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                 @"genreId" : genreID
                };
    }
    else
    {
        url = [CMGenerator genURLWithInterface:CNM_OPEN_API_INTERFACE_GetVodGenreInfo];
        dict = @{
                 CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                 CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                 CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                 @"genreId" : genreID
                 };
    }
    
    request(url, self, dict, YES);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.menuTable)
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    else if (tableView == self.listTable)
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.listTable)
    {
        if (_isMoreCenre)
        {
            static NSString *CellIdentifier = @"DefaultCell";
            CMTableViewCell *cell = (CMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[CMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                [cell.textLabel setTextColor:UIColorFromRGB(0x7961aa)];
                [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
                [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
                [cell setSeparatorColor:[UIColor redColor]];
                [cell setDashWidth:1 dashGap:0 dashStroke:1];
                [cell setBackgroundViewColor:UIColorFromRGB(0xe5e5e5)];
                [cell setSelectedBackgroundViewColor:UIColorFromRGB(0xd7cfe1)];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            // Configure the cell...
            cell.textLabel.text = [[self.lists objectAtIndex:indexPath.row] valueForKey:@"Genre_Title"];
            
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"ListCell";
            CMVODListTableViewCell *cell = (CMVODListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                cell = [[CMVODListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                [cell setDashWidth:1 dashGap:0 dashStroke:1];
                [cell setBackgroundViewColor:UIColorFromRGB(0xe5e5e5)];
                [cell setSelectedBackgroundViewColor:UIColorFromRGB(0xd7cfe1)];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            // HD 여부.
            cell.isHD = [[[self.lists objectAtIndex:indexPath.row] valueForKey:@"VOD_HD"] boolValue];
            
            // 시청등급.
            cell.vodGrade = [[[self.lists objectAtIndex:indexPath.row] valueForKey:@"VOD_Grade"] integerValue];
            
            // VOD 이미지.
            NSURL *url = [NSURL URLWithString:[[self.lists objectAtIndex:indexPath.row] valueForKey:@"VOD_IMG"]];
            cell.screenshotImageView.imageURL = url;
            
            cell.titleLabel.text = [[self.lists objectAtIndex:indexPath.row] valueForKey:@"VOD_Title"];
            cell.directorLabel.text = [NSString stringWithFormat:@"감독: %@",  [[self.lists objectAtIndex:indexPath.row] valueForKey:@"VOD_Director"]];
            cell.castingLabel.text = [NSString stringWithFormat:@"배우: %@", [[self.lists objectAtIndex:indexPath.row] valueForKey:@"VOD_Actor"]];
            
            return cell;
        }
    }
    else if (tableView == self.menuTable)
    {
        // 메뉴 테이블 처리.
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
        
    }
    else return nil;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 44.0;
    if (tableView == self.listTable && !_isMoreCenre)
    {
        cellHeight = 73.0;
    }
    
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.listTable)
    {
        if (_isMoreCenre)
        {
            // 하위 장르가 존재하는 경우.
            CMVODListViewController *viewController = [[CMVODListViewController alloc] initWithNibName:@"CMVODListViewController" bundle:nil];
            viewController.menuType = CMMenuTypeVOD;
            viewController.viewControllerType = CMViewControllerTypeList;
            viewController.data = [self.lists objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else
        {
            NSInteger grade = [[[self.lists objectAtIndex:indexPath.row] valueForKey:@"VOD_Grade"] integerValue];
            
            // VOD 등급과 성인인증 여부를 확인한다.
            if (grade == 19 && !AppInfo.isAdult)
            {
                [self checkAdult];
            }
            else
            {
                CMVODDetailViewController *viewController = [[CMVODDetailViewController alloc] initWithNibName:@"CMVODDetailViewController" bundle:nil];
                viewController.menuType = CMMenuTypeVOD;
                viewController.viewControllerType = CMViewControllerTypeView;
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
    }
    else if (tableView == self.menuTable)
    {
        // 메뉴 테이블 처리.
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CMHTTPClientDelegate

- (void)receiveData:(NSDictionary *)dict
{
    DDLogDebug(@"Receive data: %@", dict);
    
    NSInteger errorCode = [[dict valueForKey:@"resultCode"] integerValue];
    NSString *itemKey = nil;
    
    _isMoreCenre ? (itemKey = @"genre_item") : (itemKey = @"vod_Item");

    if (errorCode == 100)
    {
        self.lists = [NSMutableArray arrayWithArray:[dict valueForKey:itemKey]];
        
        if ([self.lists count] == 0)
        {
            DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                                message:@"데이터가 없습니다!"
                                                      cancelButtonTitle:nil
                                                       otherButtonTitle:@"확인"];
            alertView.shouldDismissOnActionButtonClicked = YES;
            alertView.otherButtonAction = ^{
                DDLogDebug(@"OK Clicked");
            };
            
            [alertView show];
        }
        
        [self.listTable reloadData];
    }
    else
    {
        // 에러 메시지.
        [self showError:errorCode];
        return;
    }
}

@end
