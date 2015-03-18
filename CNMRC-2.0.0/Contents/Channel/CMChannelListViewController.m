//
//  CMChannelListViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 6..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMChannelListViewController.h"
#import "CMChannelTableViewCell.h"
#import "CMEPGViewController.h"
#import "DQAlertView.h"

@interface CMChannelListViewController ()
- (void)requestDataWithGenreCode:(NSString *)genreCode;
@end

@implementation CMChannelListViewController

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
    
    self.titleLabel.text = [self.data valueForKey:@"genreName"];
    
    // 데이터 요청.
    [self requestDataWithGenreCode:[self.data valueForKey:@"genreCode"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma makr - 프라이빗 메서드

- (void)requestDataWithGenreCode:(NSString *)genreCode
{
    NSURL *url = [CMGenerator genURLWithInterface:CNM_OPEN_API_INTERFACE_GetChannelList];
    NSDictionary *dict = @{
                           CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                           CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                           CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                           CNM_OPEN_API_AREA_CODE_KEY : AppInfo.areaCode,
                           CNM_OPEN_API_PRODUCE_CODE_KEY : AppInfo.productCode,
                           @"genreCode" : genreCode,
                           @"mode" : @""
                           };
    
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
        return [self.lists count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.listTable)
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
        CMEPGViewController *viewController = [[CMEPGViewController alloc] initWithNibName:@"CMEPGViewController" bundle:nil];
        viewController.menuType = CMMenuTypeChannel;
        viewController.viewControllerType = CMViewControllerTypeList;
        viewController.data = [self.lists objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
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
    NSLog(@"Receive data: %@", dict);
    
    NSInteger errorCode = [[dict valueForKey:@"resultCode"] integerValue];
    
    if (errorCode == 100)
    {
        self.lists = [NSMutableArray arrayWithArray:[dict valueForKey:@"Genre_Channel_Item"]];
        
        if ([self.lists count] == 0)
        {
            DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알람"
                                                                message:@"데이터가 없습니다!"
                                                      cancelButtonTitle:nil
                                                       otherButtonTitle:@"확인"];
            alertView.shouldDismissOnActionButtonClicked = YES;
            alertView.otherButtonAction = ^{
                NSLog(@"OK Clicked");
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
