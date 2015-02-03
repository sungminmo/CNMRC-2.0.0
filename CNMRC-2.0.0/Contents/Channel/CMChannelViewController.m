//
//  CMChannelViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 17..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMChannelViewController.h"
#import "CMChannelTableViewCell.h"
#import "CMEPGViewController.h"
#import "CMChannelListViewController.h"
#import "DQAlertView.h"

@interface CMChannelViewController ()

@end

@implementation CMChannelViewController

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
    
    // 제목: 메뉴의 첫번째 인덱스.
    self.titleLabel.text = [self.menus objectAtIndex:0];
    
    // 데이터 요청.
    [self requestData:self.menuType subMenuIndex:0 withDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        return [self.lists count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.listTable)
    {
        if (self.selectedMenuIndex == 1)
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
            cell.textLabel.text = [[self.lists objectAtIndex:indexPath.row] valueForKey:@"genreName"];
            
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"ListCell";
            CMChannelTableViewCell *cell = (CMChannelTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[CMChannelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                [cell setSeparatorColor:[UIColor redColor]];
                [cell setDashWidth:1 dashGap:0 dashStroke:1];
                [cell setBackgroundViewColor:UIColorFromRGB(0xe5e5e5)];
                [cell setSelectedBackgroundViewColor:UIColorFromRGB(0xd7cfe1)];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            // 채널 번호.
            cell.channelNoLabel.text = [[self.lists objectAtIndex:indexPath.row] valueForKey:@"Channel_number"];
            
            
            // 채널 로고.
            NSURL *url = [NSURL URLWithString:[[self.lists objectAtIndex:indexPath.row] valueForKey:@"Channel_logo_img"]];
            cell.channelIcon.imageURL = url;
            
            // 현재 프로그램명과 방송 시간.
            NSString *programTime = [self programTime:[[self.lists objectAtIndex:indexPath.row] valueForKey:@"Channel_Program_onAir_Time"]];
            cell.programLabel.text = [NSString stringWithFormat:@"%@ %@",
                                      programTime,
                                      [[self.lists objectAtIndex:indexPath.row] valueForKey:@"Channel_Program_onAir_Title"]];
            
            // 다음 프로그램명과 방송 시간.
            NSString *nextProgramTime = [self programTime:[[self.lists objectAtIndex:indexPath.row] valueForKey:@"Channel_Program_next_Time"]];
            cell.nextProgramLabel.text = [NSString stringWithFormat:@"%@ %@",
                                          nextProgramTime,
                                          [[self.lists objectAtIndex:indexPath.row] valueForKey:@"Channel_Program_next_Title"]];
            
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.listTable)
    {
        if (self.selectedMenuIndex == 1)
        {
            // 장르별채널.
            CMChannelListViewController *viewController = [[CMChannelListViewController alloc] initWithNibName:@"CMChannelListViewController" bundle:nil];
            viewController.menuType = CMMenuTypeChannel;
            viewController.viewControllerType = CMViewControllerTypeList;
            viewController.data = [self.lists objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else
        {
            // 전체채널/HD채널/유료채널.
            CMEPGViewController *viewController = [[CMEPGViewController alloc] initWithNibName:@"CMEPGViewController" bundle:nil];
            viewController.menuType = CMMenuTypeChannel;
            viewController.viewControllerType = CMViewControllerTypeList;
            viewController.data = [self.lists objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:viewController animated:YES];
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
            case 0: // 전체채널.
                itemKey = @"All_Channel_Item";
                break;
                
            case 1: // 장르별채널.
                itemKey = @"genre_item";
                break;
                
            case 2: // HD채널.
                itemKey = @"All_Channel_Item";
                break;
                
            case 3: // 유로채널.
                itemKey = @"All_Channel_Item";
                break;
                
            default:
                break;
        }
        
        // !!!: 서버 이슈로 임시 처리함(유료채널일 경우 데이터에 문제가 있음, 전체채널도 역시 유료채널을 폼함하므로...).
        if (self.selectedMenuIndex == 0 || self.selectedMenuIndex == 3)
        {
            // 중복 제거.
            NSMutableArray *temp = [NSMutableArray arrayWithArray:[dict valueForKey:itemKey]];
            NSMutableArray *uniques = [NSMutableArray array];
            
            [temp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (idx == 0)
                {
                    [uniques addObject:obj];
                }
                else
                {
                    if (![obj isEqual:[temp objectAtIndex:idx-1]])
                    {
                        [uniques addObject:obj];
                    }
                }
            }];
            
            self.lists = [NSMutableArray arrayWithArray:uniques];
        }
        else
        {
            self.lists = [NSMutableArray arrayWithArray:[dict valueForKey:itemKey]];
        }
        
        // !!!: 정상 코드.
        //self.lists = [NSMutableArray arrayWithArray:[dict valueForKey:itemKey]];
        
        if ([self.lists count] == 0)
        {
            DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알람"
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
