//
//  CMAuthAdultViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 8..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMAuthAdultViewController.h"
#import "DQAlertView.h"
#import "Setting.h"

#define CENTER_PADDING_Y 55.0

@interface CMAuthAdultViewController ()
- (void)requestAuthAdult;
- (BOOL)validateForm;
- (BOOL)checkSSN:(NSString *)ssn;
@end

@implementation CMAuthAdultViewController

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
    
    self.titleLabel.text = @"성인인증";
    
    // 백그라운드 컬러.
    self.view.backgroundColor = UIColorFromRGB(0xe5e5e5);
    
    CGFloat paddingY = 0.0;
    if (isiOS7)
    {
        paddingY = 20.0;
        self.warningView.center = CGPointMake(self.warningView.center.x, self.warningView.center.y + paddingY);
        self.backgroundView.center = CGPointMake(self.backgroundView.center.x, self.backgroundView.center.y + paddingY);
    }
    
    // 경고문구 표시 여부.
    switch (self.authAdultViewType)
    {
        case CMAuthAdultViewTypeVOD:
            self.warningView.hidden = NO;
            self.backgroundView.center = CGPointMake(self.view.center.x, self.view.center.y + CENTER_PADDING_Y + paddingY);
            break;
            
        case CMAuthAdultViewTypeSettings:
            self.warningView.hidden = YES;
            break;
            
        default:
            break;
    }
    
    // 자동성인인증하기 스위치 설정.
    Setting *setting = [[Setting all] objectAtIndex:0];
    self.autoAuthAdultSwitch.on = [setting.isAutoAuthAdult boolValue];
    
    // 키보드.
    [self.nameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setSsnTextField:nil];
    [self setNameTextField:nil];
    [self setWarningView:nil];
    [self setBackgroundView:nil];
    [super viewDidUnload];
}

#pragma mark - 상속 메서드

// 완료.
- (IBAction)doneAction:(id)sender
{
    if ([self validateForm])
    {
        [self requestAuthAdult];
    }
}

#pragma mark - 프라이빗 메서드

- (void)requestAuthAdult
{
    NSString *userInof = [NSString stringWithFormat:@"%@@%@", self.ssnTextField.text, [self.nameTextField.text stringByUrlEncoding]];
    
    NSURL *url = [CMGenerator genURLWithInterface:CNM_OPEN_API_INTERFACE_AuthenticateAdult];
    NSDictionary *dict = @{
                           CNM_OPEN_API_VERSION_KEY : CNM_OPEN_API_VERSION,
                           CNM_OPEN_API_TERMINAL_KEY_KEY : [CMHTTPClient sharedCMHTTPClient].terminalKey,
                           CNM_OPEN_API_TRANSACTION_ID_KEY : @"0",
                           @"UserInfo" : userInof
                           };
    
    request(url, self, dict, NO);
}

// 폼 검증.
- (BOOL)validateForm
{
    if ([self.nameTextField.text isEmpty])
    {
        DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알람"
                                                            message:@"이름을 입력해 주십시오!"
                                                  cancelButtonTitle:nil
                                                   otherButtonTitle:@"확인"];
        alertView.shouldDismissOnActionButtonClicked = YES;
        alertView.otherButtonAction = ^{
            Debug(@"OK Clicked");
            [self.nameTextField becomeFirstResponder];
        };
        
        [alertView show];
    
        return NO;
    }
    else if ([self.ssnTextField.text isEmpty])
    {
        DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알람"
                                                            message:@"주민등록번호를 입력해 주십시오!"
                                                  cancelButtonTitle:nil
                                                   otherButtonTitle:@"확인"];
        alertView.shouldDismissOnActionButtonClicked = YES;
        alertView.otherButtonAction = ^{
            Debug(@"OK Clicked");
            [self.ssnTextField becomeFirstResponder];
        };
        
        [alertView show];
    
        return NO;
    }
    else if (![self checkSSN:self.ssnTextField.text])
    {
        DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알람"
                                                            message:@"올바른 주민등록번호를 입력해 주십시오!"
                                                  cancelButtonTitle:nil
                                                   otherButtonTitle:@"확인"];
        alertView.shouldDismissOnActionButtonClicked = YES;
        alertView.otherButtonAction = ^{
            Debug(@"OK Clicked");
            [self.ssnTextField becomeFirstResponder];
        };
        
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

// 주민등록 유효성 검증.
/*
------------------------------------------------------------------------------
 마지막 숫자를 제외한 12자리의 각 숫자에
 각각 2,3,4,5,6,7,8,9,2,3,4,5 를 곱한 다음 그 값들을 서로 더해준다.
 그 다음 그 값을 11 로 나눈 나머지를 다시 11에서 빼준다.
 (단 11 로 나눈 나머지가 0 일 경우에는 1로, 1일 경우에는 0으로 해준다.)
 이 값을 마지막 숫자와 비교해 맞다면 유효한 주민등록번호이다.
------------------------------------------------------------------------------
 테스트 주민번호 : 320321-1234567
------------------------------------------------------------------------------
    3    2    0    3    2    1    1    2    3    4    5    6    7
    x    x    x    x    x    x    x    x    x    x    x    x
    2    3    4    5    6    7    8    9    2    3    4    5
------------------------------------------------------------------
    6 +  6 +  0 + 15 + 12 +  7 +  8 + 18 +  6 + 12 + 20 + 30 = 140

 140 mod 11 = 8
 11 - 8 = 3 <- 마지막 숫자와 불일치 -> 잘못된 주민등록번호다.
------------------------------------------------------------------------------
 */
- (BOOL)checkSSN:(NSString *)ssn
{
    NSArray *addNumber = @[@2, @3, @4, @5, @6, @7, @8, @9, @2, @3, @4, @5];
    
    // '-' 제거.
    ssn = [[ssn trim] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    // 길이가 13자리인지...
    if ([ssn length] < 13) return NO;
    
    int keyValue = 11;
    int compareNumber = 0;
    int sum = 0;
    int lastNumber = [[ssn substringWithRange:NSMakeRange(12, 1)] intValue];
    
    for (int i = 0; i < 12; i++)
    {
        int number = [[ssn substringWithRange:NSMakeRange(i, 1)] intValue];
        sum = sum + number * [addNumber[i] intValue];
    }
    
    int rest = sum % keyValue;
    switch (rest)
    {
        case 0:
            compareNumber = 1;
            break;
            
        case 1:
            compareNumber = 0;
            break;
            
        default:
            compareNumber = keyValue - rest;
            break;
    }
    
    if (compareNumber == lastNumber)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - 퍼블릭 메서드

- (IBAction)textFieldAction:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    if (textField == self.nameTextField)
    {
        [self.ssnTextField becomeFirstResponder];
    }
    else if (textField == self.ssnTextField)
    {
        [self doneAction:sender];
    }
}

- (IBAction)switchAction:(id)sender
{
    if (AppInfo.isAdult)
    {
        Setting *setting = [[Setting all] objectAtIndex:0];
        setting.isAutoAuthAdult = [NSNumber numberWithBool:self.autoAuthAdultSwitch.on];
        [setting save];
        [AppInfo resetSettings:setting];
    }
}

#pragma mark - UITextFieldDelegate



#pragma mark - CMHTTPClientDelegate

- (void)receiveData:(NSDictionary *)dict
{
    Debug(@"Receive data: %@", dict);
    
    NSString *errorCode = [dict valueForKey:@"resultCode"];
    
    if ([errorCode isEqualToString:@"ok"])
    {
        AppInfo.isAdult = YES;
        
        // 자동성인인증하기 설정.
        [self switchAction:nil];
        
        DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알람"
                                                            message:@"성인인증 성공!"
                                                  cancelButtonTitle:nil
                                                   otherButtonTitle:@"확인"];
        alertView.shouldDismissOnActionButtonClicked = YES;
        alertView.otherButtonAction = ^{
            Debug(@"OK Clicked");
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        [alertView show];
    }
    else
    {
        // 에러 메시지.
        [self showError:202];
        return;
    }
}

@end
