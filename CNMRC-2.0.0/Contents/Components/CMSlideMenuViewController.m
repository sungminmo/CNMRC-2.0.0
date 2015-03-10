 //
//  CMSlideMenuViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 5..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMSlideMenuViewController.h"
#import "CMTableViewCell.h"
#import "DQAlertView.h"
#import "CMAuthAdultViewController.h"

#define BOTTOM_PADDING 20

@interface CMSlideMenuViewController ()
{
    BOOL _isMenuOpened;
    CGFloat _originContentViewX;
}

@end

@implementation CMSlideMenuViewController

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
	
    // 메뉴 설정.
    [self setupMenu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 상속 메서드

- (void)setupLayout
{
    [super setupLayout];
    
    self.view.backgroundColor = UIColorFromRGB(0x484848);
    
    CGFloat paddingY = 0.0;
    if (isiOS7)
    {
        paddingY = 20.0;
    }
    
    // 메뉴 테이블.
    CGFloat menuTableX = 0;
    switch ([LPPhoneVersion deviceSize]) {
        case iPhone55inch:
            menuTableX = 274.0;
            break;
            
        case iPhone47inch:
            menuTableX = 235.0;
            break;
            
        default:
            menuTableX = 180.0;
            break;
    }
    
    self.menuTable = [[UITableView alloc] initWithFrame:CGRectMake(menuTableX, 0.0 + paddingY, 140.0, 548.0) style:UITableViewStylePlain];
    self.menuTable.dataSource = self;
    self.menuTable.delegate= self;
    self.menuTable.backgroundColor = [UIColor clearColor];
    self.menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.menuTable];

    // 컨텐츠뷰.
    CGRect contentViewFrame = CGRectMake(0, 0, 0, 0);
    switch ([LPPhoneVersion deviceSize]) {
        case iPhone55inch:
            contentViewFrame = CGRectMake(0, 0, 414, 701);
            break;
            
        case iPhone47inch:
            contentViewFrame = CGRectMake(0, 0, 375, 632);
            break;
            
        case iPhone4inch:
            contentViewFrame = CGRectMake(0, 0, 320, 533);
            break;
            
        default:
            contentViewFrame = CGRectMake(0, 0, 320, 445);
            break;
    }
    
    self.contentView = [[UIView alloc] initWithFrame:contentViewFrame];
    self.contentView.backgroundColor = UIColorFromRGB(0xe5e5e5);
    [self.view addSubview:self.contentView];
    
    // 컨텐츠뷰 그림자.
    self.contentView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.contentView.layer.shadowOpacity = 1.0;
    self.contentView.layer.shadowRadius = 2.0;
    self.contentView.layer.shadowOffset = CGSizeMake(0.1, 0);
    self.contentView.clipsToBounds = NO;
    
    if (self.viewControllerType == CMViewControllerTypeList)
    {
        // 목록 테이블.
        self.listTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 55.0 + paddingY, self.contentView.bounds.size.width, self.contentView.bounds.size.height - (55.0 + 2*paddingY)) style:UITableViewStylePlain];
        self.listTable.dataSource = self;
        self.listTable.delegate= self;
        self.listTable.backgroundColor = [UIColor clearColor];
        self.listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contentView addSubview:self.listTable];
        
        // 목록 데이터  갱신.
        UIRefreshControl *refreshControlForList = [[UIRefreshControl alloc] init];
        [refreshControlForList addTarget:self action:@selector(handleRefreshList:) forControlEvents:UIControlEventValueChanged];
        [self.listTable addSubview:refreshControlForList];
        
        // 슬라이드메뉴 스와이프 제스처 추가.
        
        // 좌.
        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeSwipeGesture:)];
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        left.numberOfTouchesRequired = 1;
        [self.listTable addGestureRecognizer:left];
        
        // 우.
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeSwipeGesture:)];
        right.direction = UISwipeGestureRecognizerDirectionRight;
        right.numberOfTouchesRequired = 1;
        [self.listTable addGestureRecognizer:right];
    }
}

- (void)setupNavigation
{
    [super setupNavigation];
    
    if (self.menuType == CMMenuTypeVOD || self.menuType == CMMenuTypeChannel)
    {
        [self.contentView addSubview:self.naviBar];
    }
    
    // VOD/채널 -> 검색/슬라이딩 메뉴 버튼.
    if (self.menuType == CMMenuTypeVOD || self.menuType == CMMenuTypeChannel)
    {
        CGFloat searchButtonX = 0;
        switch ([LPPhoneVersion deviceSize]) {
            case iPhone55inch:
                searchButtonX = 310;
                break;
                
            case iPhone47inch:
                searchButtonX = 281;
                break;
                
            default:
                searchButtonX = 224.0;
                break;
        }
        
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        searchButton.frame = CGRectMake(searchButtonX, 4.0, 49.0, 47.0);
        [searchButton setImage:[UIImage imageNamed:@"Search_D"] forState:UIControlStateNormal];
        [searchButton setImage:[UIImage imageNamed:@"Search_H"] forState:UIControlStateHighlighted];
        [searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.naviBar addSubview:searchButton];
        
        CGFloat slideButtonX = 0;
        switch ([LPPhoneVersion deviceSize]) {
            case iPhone55inch:
                slideButtonX = 365;
                break;
                
            case iPhone47inch:
                slideButtonX = 331;
                
            default:
                slideButtonX = 271.0;
                break;
        }
        
        UIButton *slideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        slideButton.frame = CGRectMake(slideButtonX, 4.0, 49.0, 47.0);
        [slideButton setImage:[UIImage imageNamed:@"List_D"] forState:UIControlStateNormal];
        [slideButton setImage:[UIImage imageNamed:@"List_H"] forState:UIControlStateHighlighted];
        [slideButton addTarget:self action:@selector(slideAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.naviBar addSubview:slideButton];
    }
}

- (void)setupMenu
{
    if (self.menuType == CMMenuTypeVOD)
    {
        self.menus = @[@"예고편", @"최신영화", @"TV다시보기", @"장르별"];
    }
    else if (self.menuType == CMMenuTypeChannel)
    {
         self.menus = @[@"전체채널", @"장르별채널", @"HD채널", @"유료채널"];
    }
}

- (void)handleRefreshList:(UIRefreshControl *)refreshControl
{
    Debug(@"데이터 갱신");
    
    // 데이터 요청.
    [self requestData:self.menuType subMenuIndex:self.selectedMenuIndex withDelegate:self];

    [refreshControl endRefreshing];
}

// 목록의 좌/우 스와이프 제스처.
- (void)recognizeSwipeGesture:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.view == self.listTable)
    {
        [self slideAction:recognizer];
    }
}

// 슬라이드 메뉴.
- (IBAction)slideAction:(id)sender
{
    if (_isMenuOpened)
    {
        // 메뉴를 닫는다.
        [UIView setAnimationDelegate:self];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.contentView.transform =  CGAffineTransformMakeTranslation (0, 0);
        [UIView commitAnimations];
        
        CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        bounceAnimation.duration = 0.2;
        bounceAnimation.fromValue = [NSNumber numberWithInt:0];
        bounceAnimation.toValue = [NSNumber numberWithInt:20];
        bounceAnimation.repeatCount = 2;
        bounceAnimation.autoreverses = YES;
        bounceAnimation.fillMode = kCAFillModeForwards;
        bounceAnimation.removedOnCompletion = NO;
        bounceAnimation.additive = YES;
        [self.contentView.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.contentView.alpha = 1.0;
        [UIView commitAnimations];
    }
    else
    {
        // 메뉴를 연다.
        [UIView setAnimationDelegate:self];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.contentView.transform =  CGAffineTransformMakeTranslation (-140, 0);
        [UIView commitAnimations];
        
        CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        bounceAnimation.duration = 0.2;
        bounceAnimation.fromValue = [NSNumber numberWithInt:0];
        bounceAnimation.toValue = [NSNumber numberWithInt:-20];
        bounceAnimation.repeatCount = 2;
        bounceAnimation.autoreverses = YES;
        bounceAnimation.fillMode = kCAFillModeForwards;
        bounceAnimation.removedOnCompletion = NO;
        bounceAnimation.additive = YES;
        [self.contentView.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.contentView.alpha = 1.0;
        [UIView commitAnimations];
    }
    
    _isMenuOpened = !_isMenuOpened;
}

// 선택된 메뉴 및 서브메뉴에 따른 데이터를 요청한다.
- (void)requestData:(CMMenuType)menuType subMenuIndex:(NSInteger)index withDelegate:(id)delegate
{    
    NSString *interfaceName = nil;
    NSURL *url = nil;
    NSDictionary *dict = nil;
    
    if (menuType == CMMenuTypeVOD)
    {
        switch (index)
        {
            case 0: // 예고편.
            {
                interfaceName = CNM_OPEN_API_INTERFACE_GetVodTrailer;
                url = [CMGenerator genURLWithInterface:interfaceName];
                dict = @{
                         CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                         CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                         CNM_OPEN_API_TRANSACTION_ID_KEY : @"0"
                         };
            }
                break;
                
            case 1: // 최신영화.
            {
                interfaceName = CNM_OPEN_API_INTERFACE_GetVodMovie;
                url = [CMGenerator genURLWithInterface:interfaceName];
                dict = @{
                         CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                         CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                         CNM_OPEN_API_TRANSACTION_ID_KEY : @"0"
                         };
            }
                break;
                
            case 2: // TV다시보기.
            {
                interfaceName = CNM_OPEN_API_INTERFACE_GetVodTv;
                url = [CMGenerator genURLWithInterface:interfaceName];
                dict = @{
                         CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                         CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                         CNM_OPEN_API_TRANSACTION_ID_KEY : @"0"
                         };
            }
                break;
                
            case 3: // 장르별.
            {
                interfaceName = CNM_OPEN_API_INTERFACE_GetVodGenre;
                url = [CMGenerator genURLWithInterface:interfaceName];
                dict = @{
                         CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                         CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                         CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                         @"genreId" : @""
                         };
            }
                break;
                
            default:
                break;
        }
    }
    else if (menuType == CMMenuTypeChannel)
    {
        NSString *mode = @"";
        
        switch (index)
        {
            case 0: // 전체채널.
            {
                interfaceName = CNM_OPEN_API_INTERFACE_GetChannelList;
                url = [CMGenerator genURLWithInterface:interfaceName];
                dict = @{
                         CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                         CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                         CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                         CNM_OPEN_API_AREA_CODE_KEY : AppInfo.areaCode,
                         CNM_OPEN_API_PRODUCE_CODE_KEY : AppInfo.productCode,
                         @"geneCode" : @"",
                         @"mode" : mode
                         };
            }
                break;
                
            case 1: // 장르별채널.
            {
                interfaceName = CNM_OPEN_API_INTERFACE_GetChannelGenre;
                url = [CMGenerator genURLWithInterface:interfaceName];
                dict = @{
                         CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                         CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                         CNM_OPEN_API_TRANSACTION_ID_KEY : @"0"
                         };
            }
                break;
                
            case 2: // HD채널.
            {
                interfaceName = CNM_OPEN_API_INTERFACE_GetChannelList;
                url = [CMGenerator genURLWithInterface:interfaceName];
                mode = @"HD";
                dict = @{
                         CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                         CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                         CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                         CNM_OPEN_API_AREA_CODE_KEY : AppInfo.areaCode,
                         CNM_OPEN_API_PRODUCE_CODE_KEY : AppInfo.productCode,
                         @"geneCode" : @"",
                         @"mode" : mode
                         };
            }
                break;
                
            case 3: // 유료채널.
            {
                interfaceName = CNM_OPEN_API_INTERFACE_GetChannelList;
                url = [CMGenerator genURLWithInterface:interfaceName];
                mode = @"PAY";
                dict = @{
                         CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                         CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                         CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                         CNM_OPEN_API_AREA_CODE_KEY : AppInfo.areaCode,
                         CNM_OPEN_API_PRODUCE_CODE_KEY : AppInfo.productCode,
                         @"geneCode" : @"",
                         @"mode" : mode
                         };
            }
                break;
                
            default:
                break;
        }
    }
    
    request(url, delegate, dict, YES);
}

#pragma mark - 퍼블릭 메서드

// 채널의 방송 시간은 반환 한다.
- (NSString *)programTime:(NSString *)date
{
    if ([date isEmpty]) return nil;

    return [date substringWithRange:NSMakeRange(11, 5)];
}

// !!!: 문서에는 0 ~ 6이나 실제는 1 ~ 7 이다.
// GetChannelSchedule에서 사용할 날짜 인덱스(DateIndex: 1 ~ 7) 반환.
- (NSString *)dateIndex:(NSDate *)date
{
    NSInteger weekday = [date weekday];
    
    NSString *dateIndex = @"";
    switch (weekday)
    {
        case 1: // 일요일.
            dateIndex = @"7";
            break;
            
        case 2: // 월요일.
            dateIndex = @"1";
            break;
            
        case 3: // 화요일.
            dateIndex = @"2";
            break;
            
        case 4: // 수요일.
            dateIndex = @"3";
            break;
            
        case 5: // 목요일.
            dateIndex = @"4";
            break;
            
        case 6: // 금요일.
            dateIndex = @"5";
            break;
            
        case 7: // 토요일.
            dateIndex = @"6";
            break;
            
        default:
            break;
    }
    
    return dateIndex;
}

// TODO: 비교 로직을 시간 기준으로 변경해야 한다!
// 현재시간 기준으로 시청 가능한 프로그램 여부 판다.
- (BOOL)isPossibleWatchTV:(NSString *)currentTime andNextTime:(NSString *)nextTime
{
    NSString *ct = [[self programTime:currentTime] stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *nt = [[self programTime:nextTime] stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *n = [NSString stringWithFormat:@"%@", [[NSDate date] toLocalTime]];
    n = [[self programTime:n] stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSInteger current = [ct integerValue];
    NSInteger next = [nt integerValue];
    NSInteger now = [n integerValue];
    
    if (now >= current && now <= next)
    {
        return YES;
    }
    
    return NO;
}

// 프로그램 방송시간(문자열)을 NSDate로 변환한다.
- (NSDate *)dateFromStringBroadcastingTime:(NSString *)broadcastingTime
{
    if ([broadcastingTime isEmpty])
         return nil;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *date = [dateFormatter dateFromString:[broadcastingTime trim]];
         
    return date;
}

// 성인인증 확인.
- (void)checkAdult
{
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                        message:@"성인인증이 필요한 컨텐츠 입니다.\n 성인인증을 하시겠습니까?"
                                              cancelButtonTitle:@"취소"
                                               otherButtonTitle:@"확인"];
    alertView.shouldDismissOnActionButtonClicked = YES;
    alertView.otherButtonAction = ^{
        Debug(@"OK Clicked");
        // 성인인증.
        CMAuthAdultViewController *viewControlelr = [[CMAuthAdultViewController alloc] initWithNibName:@"CMAuthAdultViewController" bundle:nil];
        viewControlelr.menuType = CMMenuTypeAuthAdult;
        viewControlelr.authAdultViewType = CMAuthAdultViewTypeVOD;
        [self.navigationController pushViewController:viewControlelr animated:YES];
    };
    
    [alertView show];
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
        return [self.menus count];
    }
    if (tableView == self.listTable)
    {
        return [self.lists count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.menuTable)
    {
        static NSString *CellIdentifier = @"Cell";
        CMTableViewCell *cell = (CMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[CMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            // TODO: 만약 현재 선택된 메뉴 이면 -> 7961aa.
            [cell.textLabel setTextColor:UIColorFromRGB(0xa4a3a3)];
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
            [cell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
            [cell setBackgroundViewColor:UIColorFromRGB(0x484848)];
            [cell setSelectedBackgroundViewColor:UIColorFromRGB(0x9d84bd)];
            [cell setSeparatorColor:UIColorFromRGB(0x333333)];
            [cell setLineCount:2];
        }
        
        // Configure the cell...
        cell.textLabel.text = [self.menus objectAtIndex:indexPath.row];
        
        return cell;
    }
    else return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.menuTable)
    {
        // 메뉴 처리.
        Debug(@"Selected menu index: %d", indexPath.row);
        
        // 현재 선택된 슬라이드메뉴 인덱스.
        self.selectedMenuIndex = indexPath.row;
        
        // 최상위로 네비게이션 컨트롤러 이동.
        if ([CMAppDelegate.container.viewControllers count] > 2)
        {
            CMSlideMenuViewController *viewController = [CMAppDelegate.container.viewControllers objectAtIndex:1];
            [CMAppDelegate.container popToViewController:viewController animated:YES];
            viewController.selectedMenuIndex = indexPath.row;
            viewController.titleLabel.text = self.titleLabel.text = [self.menus objectAtIndex:indexPath.row];
            [viewController requestData:self.menuType subMenuIndex:indexPath.row withDelegate:viewController];
        }
        else
        {
            // 제목 변경.
            self.titleLabel.text = [self.menus objectAtIndex:indexPath.row];
        }
    
        // 슬라이드 메뉴 닫기.
        [self slideAction:nil];
    }
}

@end
