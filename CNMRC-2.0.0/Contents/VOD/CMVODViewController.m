//
//  CMVODViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 17..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMVODViewController.h"
#import "CMTableViewCell.h"
#import "CMVODListTableViewCell.h"
#import "CMVODDetailViewController.h"
#import "CMVODListViewController.h"
#import "DQAlertView.h"

@interface CMVODViewController ()

@end

@implementation CMVODViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 제목: 메뉴의 첫번째 인덱스.
    self.titleLabel.text = [self.menus objectAtIndex:0];
    
    // 데이터 요청.
    [self requestData:self.menuType subMenuIndex:0 withDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.listTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 상속 메서드


#pragma mark - 프라이빗 메서드

#pragma mark - 퍼블릭 메서드


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
        return [self.lists count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.listTable)
    {        
        if (self.selectedMenuIndex == 3)
        {
            static NSString *CellIdentifier = @"DefaultCell";
            CMTableViewCell *cell = (CMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[CMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                [cell.textLabel setTextColor:UIColorFromRGB(0x7961aa)];
                [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
                [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
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
            NSInteger grade = [[[self.lists objectAtIndex:indexPath.row] valueForKey:@"VOD_Grade"] integerValue];
            if (grade == 19 && !AppInfo.isAdult)
            {
                cell.screenshotImageView.image = [UIImage imageNamed:@"vodlist19.jpg"];
            }
            else
            {
                NSURL *url = [NSURL URLWithString:[[self.lists objectAtIndex:indexPath.row] valueForKey:@"VOD_IMG"]];
                cell.screenshotImageView.imageURL = url;
            }
            
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
    if (tableView == self.listTable && (self.selectedMenuIndex == 0 || self.selectedMenuIndex == 1 || self.selectedMenuIndex == 2))
    {
        cellHeight = 73.0;
    }
    
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.listTable)
    {
        if (self.selectedMenuIndex == 3)
        {
            // 장르별.
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
                // 예고편/최신영화/TV다시보기.
                CMVODDetailViewController *viewController = [[CMVODDetailViewController alloc] initWithNibName:@"CMVODDetailViewController" bundle:nil];
                viewController.menuType = CMMenuTypeVOD;
                viewController.viewControllerType = CMViewControllerTypeView;
                viewController.data = [self.lists objectAtIndex:indexPath.row];
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
    }
    else if (tableView == self.menuTable)
    {
        // 메뉴 테이블 처리.
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        
        // 데이터 요청.
        [self requestData:self.menuType subMenuIndex:indexPath.row withDelegate:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CMHTTPClientDelegate

- (void)receiveData:(NSDictionary *)dict
{
    Debug(@"Receive data: %@", dict);
    
    NSInteger errorCode = [[dict valueForKey:@"resultCode"] integerValue];
    NSString *itemKey = nil;
    if (errorCode == 100)
    {
        switch (self.selectedMenuIndex)
        {
            case 0: // 예고편.
                itemKey = @"Trailer_Item";
                break;
                
            case 1: // 최신영화.
                itemKey = @"NewMovie_Item";
                break;
                
            case 2: // TV다시보기.
                itemKey = @"Tv_Item";
                break;
                
            case 3: // 장르별.
                itemKey = @"genre_item";
                break;
                
            default:
                break;
        }
        
        self.lists = [NSMutableArray arrayWithArray:[dict valueForKey:itemKey]];
        
        if ([self.lists count] == 0)
        {
            DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                                message:@"데이터가 없습니다!"
                                                      cancelButtonTitle:nil
                                                       otherButtonTitle:@"확인"];
            alertView.shouldDismissOnActionButtonClicked = YES;
            alertView.otherButtonAction = ^{
                Debug(@"OK Clicked");
            };
            
            [alertView show];
            return;
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