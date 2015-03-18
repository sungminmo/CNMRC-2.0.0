//
//  CMChannelDetailViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 5..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMEPGViewController.h"
#import "CMEPGTableViewCell.h"
#import "DQAlertView.h"
#import "CMAlarmManager.h"

#define DATE_LABEL_WIDTH 150.0
#define NEXT_BUTTON_WIDTH 24.0

@interface CMEPGViewController ()
{
    NSString *_pageAnimationType;
}

@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) NSString *currentDateIndex; // 현재 선택된 요일 인덱스.
@property (strong, nonatomic) UIButton *previousButton;
@property (strong, nonatomic) UIButton *nextButton;

- (void)previousAction:(id)sender;
- (void)nextAction:(id)sender;
- (void)pageAnimation:(NSString *)animationType;
- (void)requestdataWithChannelID:(NSString *)channelID andDateIndex:(NSString *)index;

@end

@implementation CMEPGViewController

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
    
    self.titleLabel.text = [self.data valueForKey:@"Channel_name"];
    
    // 현재 선택된 날짜 및 요일 인덱스.
    self.currentDate = [NSDate date];
    
    // 데이터 요청.
    [self requestdataWithChannelID:[self.data valueForKey:@"Channel_ID"]
                      andDateIndex:self.currentDateIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 현재 선택된 날짜.
- (void)setCurrentDate:(NSDate *)currentDate
{
    if (_currentDate != currentDate)
    {
        _currentDate = currentDate;
        
        // 날짜 설정.
        self.dateLabel.text = [NSString stringWithFormat:@"%@ %@요일",
                               [_currentDate stringFromDateWithType:StringFromDateTypeMonthAndDayKorea],
                               [_currentDate weekFromDate]];
        
        // 날짜 인덱스 설정.
        self.currentDateIndex = [self dateIndex:_currentDate];
        
        // 버튼 감추기.
        if ([self.currentDate weekday] == 1)
        {
            self.previousButton.hidden = YES;
        }
        else if ([self.currentDate weekday] == 7)
        {
            self.nextButton.hidden = YES;
        }
        else
        {
            self.previousButton.hidden = NO;
            self.nextButton.hidden = NO;
        }
    }
}

#pragma mark - 상속 메서드

- (void)setupLayout
{
    [super setupLayout];
    
    // 초기값.
    _pageAnimationType = nil;
    
    CGFloat paddingY = 0.0;
    if (isiOS7)
    {
        paddingY = 20.0;
    }
    
    // EPG 일별 네비게이션.
    CGFloat subNavigationWidth = 0;
    switch ([LPPhoneVersion deviceSize]) {
        case iPhone55inch:
            subNavigationWidth = 414;
            break;
            
        case iPhone47inch:
            subNavigationWidth = 375;
            break;
            
        default:
            subNavigationWidth = 320;
            break;
    }
    
    UIView *subNavigation = [[UIView alloc] initWithFrame:CGRectMake(0.0, 55.0 + paddingY, subNavigationWidth, 34.0)];
    subNavigation.backgroundColor = UIColorFromRGB(0xd7cfe1);
    [self.contentView addSubview:subNavigation];
    
    // 날짜라벨.
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, DATE_LABEL_WIDTH, 34.0)];
    self.dateLabel.center = CGPointMake(subNavigationWidth/2, self.dateLabel.frame.size.height/2);
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = UIColorFromRGB(0x7a61aa);
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.font = [UIFont boldSystemFontOfSize:17];
    [subNavigation addSubview:self.dateLabel];
    self.dateLabel.text = @"08월 06일 화요일";
    
    // 이전 버튼.
    self.previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.previousButton.frame = CGRectMake(self.dateLabel.frame.origin.x - NEXT_BUTTON_WIDTH, 5.0, NEXT_BUTTON_WIDTH, NEXT_BUTTON_WIDTH);
    [self.previousButton addTarget:self action:@selector(previousAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.previousButton setImage:[UIImage imageNamed:@"DatePrevious_D"] forState:UIControlStateNormal];
    [self.previousButton setImage:[UIImage imageNamed:@"DatePrevious_H"] forState:UIControlStateHighlighted];
    [subNavigation addSubview:self.previousButton];
    
    // 다음 버튼.
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextButton.frame = CGRectMake(self.dateLabel.frame.origin.x + DATE_LABEL_WIDTH, 5.0, NEXT_BUTTON_WIDTH, NEXT_BUTTON_WIDTH);
    [self.nextButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setImage:[UIImage imageNamed:@"DateNext_D"] forState:UIControlStateNormal];
    [self.nextButton setImage:[UIImage imageNamed:@"DateNext_H"] forState:UIControlStateHighlighted];
    [subNavigation addSubview:self.nextButton];
    
    CGRect listTableFrame = CGRectMake(0, 0, 0, 0);
    switch ([LPPhoneVersion deviceSize]) {
        case iPhone55inch:
            listTableFrame = CGRectMake(0, 89.0 + paddingY, 414, 671 - (89.0 + paddingY));
            break;
            
        case iPhone47inch:
            listTableFrame = CGRectMake(0, 89.0 + paddingY, 375, 602 - (89.0 + paddingY));
            break;
            
        case iPhone4inch:
            listTableFrame = CGRectMake(0, 89.0 + paddingY, 320, 503 - (89.0 + paddingY));
            break;
            
        default:
            listTableFrame = CGRectMake(0, 89.0 + paddingY, 320, 415 - (89.0 + paddingY));
            break;
    }
    
    self.listTable.frame = listTableFrame;
}

// 데이터 갱신.
- (void)handleRefreshList:(UIRefreshControl *)refreshControl
{
    NSLog(@"데이터 갱신");
    
    // 데이터 요청.
    [self requestdataWithChannelID:[self.data valueForKey:@"Channel_ID"]
                      andDateIndex:self.currentDateIndex];
    
    [refreshControl endRefreshing];
}

#pragma mark - 프라이빗 메서드

- (void)previousAction:(id)sender
{
    // 날짜 설정.
    self.currentDate = [self.currentDate yesterday];
    
    // 데이터 요청.
    [self requestdataWithChannelID:[self.data valueForKey:@"Channel_ID"]
                      andDateIndex:self.currentDateIndex];
    
    _pageAnimationType = kCATransitionFromLeft;
}

- (void)nextAction:(id)sender
{
    // 날짜 설정.
    self.currentDate = [self.currentDate tomorrow];
    
    // 데이터 요청.
    [self requestdataWithChannelID:[self.data valueForKey:@"Channel_ID"]
                      andDateIndex:self.currentDateIndex];
    
    _pageAnimationType = kCATransitionFromRight;
}

// !!!: 애니메이션 타입은: kCATransitionFromLeft/kCATransitionFromRight
- (void)pageAnimation:(NSString *)animationType
{
    CATransition *animationObject = [CATransition animation];
    [animationObject setDelegate:self];
    [animationObject setType:kCATransitionPush];
    [animationObject setSubtype:animationType];
    [animationObject setDuration:0.1f];
    [animationObject setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.listTable layer] addAnimation:animationObject forKey:@"calendarAnimation"];
}

- (void)requestdataWithChannelID:(NSString *)channelID andDateIndex:(NSString *)index
{
    NSURL *url = [CMGenerator genURLWithInterface:CNM_OPEN_API_INTERFACE_GetChannelSchedule];
    NSDictionary *dict = @{
                           CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                           CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                           CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                           @"ChannelId" : channelID,
                           @"DateIndex" : index,
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
    if (tableView == self.listTable)
    {
        return [self.lists count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.listTable)
    {
        static NSString *CellIdentifier = @"EPGCell";
        CMEPGTableViewCell *cell = (CMEPGTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[CMEPGTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSeparatorColor:[UIColor redColor]];
            [cell setDashWidth:1 dashGap:0 dashStroke:1];
            [cell setBackgroundViewColor:UIColorFromRGB(0xe5e5e5)];
            [cell setSelectedBackgroundViewColor:UIColorFromRGB(0xd7cfe1)];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        // 셀 UI 초기화.
        [cell resetCell];
        
        // HD 여부.
        BOOL isHD = [[[self.lists objectAtIndex:indexPath.row] valueForKey:@"Program_HD"] boolValue];
        
        // 시청등급.
        NSInteger grade = [[[self.lists objectAtIndex:indexPath.row] valueForKey:@"Program_Grade"] integerValue];
        
        // 셀의 서브뷰 위치 조절.
        [cell adjustHDIcon:isHD andWatchingLevelIcon:grade];
        
        // 방송시간.
        NSString *programTime = [self programTime:[[self.lists objectAtIndex:indexPath.row] valueForKey:@"Program_Broadcasting_Time"]];
        cell.timeLabel.text = programTime;
        
        // 프로그램명.
        cell.programLabel.text = [[self.lists objectAtIndex:indexPath.row] valueForKey:@"Program_Title"];
        
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
        // !!!: 프로그램시간이 현재시간과 같으면(Hour/Minute 기준) TV에서 보기 얼럿을 띄우고 아니면 시청예약 알람을 등록한다.
        NSString *currentTime = [[self.lists objectAtIndex:indexPath.row] valueForKey:@"Program_Broadcasting_Time"];
        NSString *nextTime = nil;
        
        if (indexPath.row == ([self.lists count] - 1))
        {
            // 마지막 프로그램일 경우.
            nextTime = [NSString stringWithFormat:@"%@ %@",
                        [self.currentDate stringFromDateWithType:StringFromDateTypeDefault],
                        @"23:59:59"];
        }
        else
        {
            nextTime = [[self.lists objectAtIndex:indexPath.row + 1] valueForKey:@"Program_Broadcasting_Time"];
        }
        
        NSString *programTime = [NSString stringWithFormat:@"%@ ~ %@",
                                 [self programTime:currentTime],
                                 [self programTime:nextTime]];
        
        NSString *programTitle = [NSString stringWithFormat:@"%@\n%@",
                                  [[self.lists objectAtIndex:indexPath.row] valueForKey:@"Program_Title"],
                                  programTime];
        
        if ([self isPossibleWatchTV:currentTime andNextTime:nextTime])
        {
            // TV에서 시청하기 얼럿.
            NSLog(@"TV에서 시청하기!");
            DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"TV에서 시청 하시겠습니까?"
                                                                message:programTitle
                                                      cancelButtonTitle:@"취소"
                                                       otherButtonTitle:@"확인"];
            alertView.shouldDismissOnActionButtonClicked = YES;
            alertView.otherButtonAction = ^{
                NSLog(@"OK Clicked");
                // TV에서 시청하기.
            };
            
            [alertView show];
        }
        else
        {
            // 시청예약 알람 등록.
            DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"시청예약을 하시겠습니까?"
                                                                message:programTitle
                                                      cancelButtonTitle:@"취소"
                                                       otherButtonTitle:@"확인"];
            alertView.shouldDismissOnActionButtonClicked = YES;
            alertView.otherButtonAction = ^{
                NSLog(@"OK Clicked");
                // 알람 등록.
                [CMAlarmManager fireLocalNotificationWitTitle:programTitle andDate:[self dateFromStringBroadcastingTime:currentTime]];
                
                //  테스트.
                //[CMAlarmManager fireLocalNotificationWitTitle:programTitle andDate:[NSDate dateWithTimeIntervalSinceNow:5*60 + 5]];
            };
            
            [alertView show];
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
    NSLog(@"Receive data: %@", dict);
    
    NSInteger errorCode = [[dict valueForKey:@"resultCode"] integerValue];
    
    if (errorCode == 100)
    {
        self.lists = [NSMutableArray arrayWithArray:[dict valueForKey:@"Channel_Item"]];
        
        if ([self.lists count] == 0)
        {
            DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
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
        
        if (_pageAnimationType)
        {
            [self pageAnimation:_pageAnimationType];
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
