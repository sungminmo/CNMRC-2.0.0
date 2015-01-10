//
//  CMSetProductViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 8..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMSetProductViewController.h"
#import "CMTableViewCell.h"
#import "Setting.h"

@interface CMSetProductViewController ()
- (void)requestProduct;
@end

@implementation CMSetProductViewController

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
    
    self.titleLabel.text = @"상품설정";
    
    self.listTable.backgroundColor = UIColorFromRGB(0xe5e5e5);
    
    // 상품정보 요청.
    [self requestProduct];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 상속 메서드

// 완료.
- (IBAction)doneAction:(id)sender
{

}

#pragma mark - 프라이빗 메서드

- (void)requestProduct
{    
    NSURL *url = [CMGenerator genURLWithInterface:CNM_OPEN_API_INTERFACE_GetChannelProduct];
    NSDictionary *dict = @{
                           CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                           CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                           CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                           @"areaCode" : self.areaCode
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
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CMTableViewCell *cell = (CMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[CMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    cell.textLabel.text = [[self.products objectAtIndex:indexPath.row] valueForKey:@"productName"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 상품설정.
    Setting *setting = [[Setting all] objectAtIndex:0];
    setting.areaCode = self.areaCode;
    setting.areaName = self.areaName;
    setting.productCode = [[self.products objectAtIndex:indexPath.row] valueForKey:@"productCode"];
    setting.productName = [[self.products objectAtIndex:indexPath.row] valueForKey:@"productName"];
    [setting save];
    
    // 설정화면으로 이동.
    [self.navigationController
     popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3]
     animated:YES];
}

#pragma mark - CMHTTPClientDelegate

- (void)receiveData:(NSDictionary *)dict
{
    Debug(@"Receive data: %@", dict);
    
    NSInteger errorCode = [[dict valueForKey:@"resultCode"] integerValue];
    if (errorCode == 100)
    {
        self.products = [NSMutableArray arrayWithArray:[dict valueForKey:@"product_item"]];
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
