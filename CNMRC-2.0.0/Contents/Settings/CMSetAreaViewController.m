//
//  CMSetAreaViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 8..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMSetAreaViewController.h"
#import "CMSetProductViewController.h"
#import "CMTableViewCell.h"
#import "SIAlertView.h"

@interface CMSetAreaViewController ()
- (void)requestArea;
@end

@implementation CMSetAreaViewController

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
    
    self.titleLabel.text = @"지역설정";
    
    self.listTable.backgroundColor = UIColorFromRGB(0xe5e5e5);
    
    // 지역정보 요청.
    [self requestArea];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setListTable:nil];
    [super viewDidUnload];
}

#pragma mark - 프라이빗 메서드

- (void)requestArea
{
    NSURL *url = [CMGenerator genURLWithInterface:CNM_OPEN_API_INTERFACE_GetChannelArea];
    NSDictionary *dict = @{
                           CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                           CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                           CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
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
    return [self.areas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CMTableViewCell *cell = (CMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[CMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
        [cell setDashWidth:1 dashGap:0 dashStroke:1];
        [cell setBackgroundViewColor:UIColorFromRGB(0xe5e5e5)];
        [cell setSelectedBackgroundViewColor:UIColorFromRGB(0xd7cfe1)];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    // Configure the cell...
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.text = [[self.areas objectAtIndex:indexPath.row] valueForKey:@"areaName"];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = [[self.areas objectAtIndex:indexPath.row] valueForKey:@"areaNameDetail"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 상품설정화면으로 이동.
    CMSetProductViewController *viewControlelr = [[CMSetProductViewController alloc] initWithNibName:@"CMSetProductViewController" bundle:nil];
    viewControlelr.menuType = CMMenuTypeSetProduct;
    
    // 지역정보 설정.
    viewControlelr.areaCode = [[self.areas objectAtIndex:indexPath.row] valueForKey:@"areaCode"];
    viewControlelr.areaName = [[self.areas objectAtIndex:indexPath.row] valueForKey:@"areaName"];
    
    [self.navigationController pushViewController:viewControlelr animated:YES];
}

#pragma mark - CMHTTPClientDelegate

- (void)receiveData:(NSDictionary *)dict
{
    Debug(@"Receive data: %@", dict);
    
    NSInteger errorCode = [[dict valueForKey:@"resultCode"] integerValue];
    if (errorCode == 100)
    {
        self.areas = [NSMutableArray arrayWithArray:[dict valueForKey:@"area_item"]];
        [self.listTable reloadData];
        
        // 알람.
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"알람" andMessage:@"지역설정 후 상품설정을 꼭 확인해 주세요!"];
        [alertView addButtonWithTitle:@"확인"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  Debug(@"OK Clicked");
                    
                              }];
        alertView.cornerRadius = 10;
        alertView.buttonFont = [UIFont boldSystemFontOfSize:15];
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        
        [alertView show];
    }
    else
    {
        // 에러 메시지.
        [self showError:errorCode];
        return;
    }
}

@end
