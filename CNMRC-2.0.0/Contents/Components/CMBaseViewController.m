//
//  CMBaseViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBaseViewController.h"
#import "HTProgressHUD.h"
#import "CMSearchViewController.h"
#import "CMTableViewCell.h"
#import "SIAlertView.h"

@interface CMBaseViewController ()
{
    HTProgressHUD *_prgressHUD;
}
@end

@implementation CMBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 화면 셜정.
    [self setupLayout];
    
    // 네비게이션 설정.
    [self setupNavigation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 퍼블릭 메서드

- (void)setupLayout
{
    
}

- (void)setupNavigation
{
    // 네비게이션바 백그라운드.
    CGFloat widht = [[UIScreen mainScreen] bounds].size.width;
    self.naviBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, widht, 55.0)];
    self.naviBar.backgroundColor = UIColorFromRGB(0x252525);
    
    if (self.menuType != CMMenuTypeVOD || self.menuType != CMMenuTypeChannel)
    {
        [self.view addSubview:self.naviBar];
    }
    
    if (isiOS7)
    {
        self.naviBar.center = CGPointMake(self.naviBar.center.x, self.naviBar.center.y + 20);
        
        // 상태바 백그라운드.
        UIView *statusBarBackground = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] statusBarFrame]];
        statusBarBackground.backgroundColor = [UIColor whiteColor];//UIColorFromRGB(0x252525);
        [self.view addSubview:statusBarBackground];
    }
    
    // 백버튼.
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 4.0, 49.0, 47.0);
    [backButton setImage:[UIImage imageNamed:@"Back_D"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"Back_H"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.naviBar addSubview:backButton];
    
    // 타이틀.
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 140.0, 55.0)];
    self.titleLabel.center = CGPointMake(self.naviBar.frame.size.width/2, self.naviBar.frame.size.height/2);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.naviBar addSubview:self.titleLabel];
    
    // 설정/상품설정/성인인증 -> 완료 버튼.
    if (self.menuType == CMMenuTypeSettings || self.menuType == CMMenuTypeSetProduct || self.menuType == CMMenuTypeAuthAdult)
    {
        CGFloat doneButtonX = self.naviBar.frame.size.width - 49.0 - 10;
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        doneButton.frame = CGRectMake(doneButtonX, 13.0, 49.0, 29.0);
        [doneButton setTitle:@"완료" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton setBackgroundImage:[UIImage imageNamed:@"complete_normal.png"] forState:UIControlStateNormal];
        [doneButton setBackgroundImage:[UIImage imageNamed:@"complete_press.png"] forState:UIControlStateHighlighted];
        [doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.naviBar addSubview:doneButton];
    }
}

// 이전.
- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 검색.
- (IBAction)searchAction:(id)sender
{
    CMSearchViewController *viewController = [[CMSearchViewController alloc] initWithNibName:@"CMSearchViewController" bundle:nil];
    viewController.menuType = CMMenuTypeSearch;
    [self.navigationController pushViewController:viewController animated:YES];
}

// 완료.
- (IBAction)doneAction:(id)sender
{
    
}

// XIB를 사용하는 테이블뷰 재사용.
- (UITableViewCell *)cellWithTableView:(UITableView *)tableView cellIdentifier:(NSString *)cellIdentifier nibName:(NSString *)nibName
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell =  (UITableViewCell *)currentObject;
                break;
            }
        }
    }
    
    return cell;
}

- (void)show
{
    if (_prgressHUD)
    {
        [_prgressHUD showInView:self.view];
        [_prgressHUD hideAfterDelay:3];
    }
    else
    {
        _prgressHUD = [[HTProgressHUD alloc] init];
        [_prgressHUD showInView:self.view];
        [_prgressHUD hideAfterDelay:3];
    }
}

- (void)hide
{
    [_prgressHUD hide];
}

// 에러 메시지(C&M Open API 용).
- (void)showError:(NSInteger)errorCode
{
    NSString *msg = nil;
    switch (errorCode)
    {
        case 100:
            msg = @"성공";
            break;
            
        case 200:
            msg = @"알수없는 에러";
            break;
            
        case 201:
            msg = @"지원하지 않는 프로토콜";
            break;
            
        case 202:
            msg = @"인증실패";
            break;
            
        case 203:
            msg = @"지원하지 않는 프로파일";
            break;
            
        case 204:
            msg = @"잘못된 파라미터 값";
            break;
            
        case 205:
            msg = @"데이터가 없습니다.";
            break;
            
        case 206:
            msg = @"내부서버 에러";
            break;
            
        case 207:
            msg = @"네부프로세싱 에러";
            break;
            
        case 211:
            msg = @"일반 DB 에러";
            break;
            
        case 221:
            msg = @"이미 처리되었음";
            break;
            
        case 223:
            msg = @"이미 추가된 항목";
            break;
            
        case 231:
            msg = @"인증코드 발급 실패";
            break;
            
        case 232:
            msg = @"만료된인증코드";
            break;
            
        default:
            msg = @"서버에 문제가 있습니다.\n관리자에게 문의 바랍니다.";
            break;
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"알림" andMessage:msg];
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

// VOD 시청 등급 아이콘.
- (UIImage *)vodIcon:(NSInteger)vodGrade
{
    UIImage *vodIcon = nil;
    
    switch (vodGrade)
    {
        case 0:
            vodIcon = [UIImage imageNamed:@"ageall.png"];
            break;
            
        case 12:
            vodIcon = [UIImage imageNamed:@"age12.png"];
            break;
            
        case 15:
            vodIcon = [UIImage imageNamed:@"age15.png"];
            break;
            
        case 19:
            vodIcon = [UIImage imageNamed:@"age19.png"];
            break;
            
        default:
            vodIcon = [UIImage imageNamed:@"ageall.png"];
            break;
    }
    
    return vodIcon;
}

@end