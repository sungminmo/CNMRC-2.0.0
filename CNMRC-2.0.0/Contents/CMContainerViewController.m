//
//  CMContainerViewController.m
//  CNMRC-2.0.0
//
//  Created by ParkJong Pil on 2015. 1. 10..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMContainerViewController.h"
#import "CMOverlayView.h"
#import "CMRCViewController.h"
#import "CMMirrorTVViewController.h"
#import "CMQwertyViewController.h"
#import "CMSettingsViewController.h"
#import "LPAppStats.h"
#import "DQAlertView.h"

// 소켓 관련.
#import "CMTRGenerator.h"
#import "CM06.h"

// 블럭 채널 정보 URL.
#define BLOCK_CHANNEL_INFO_URL @"http://cms.cnm.co.kr/channelinfo.xml"

@interface CMContainerViewController ()
- (void)circleMenuAction;
- (void)showHelp;
- (BOOL)isSTBConnected;
- (void)checkMirrorTV;
- (void)blockChannel;
- (void)requestChannelStatus;
- (BOOL)isBlockedChannel:(NSString *)sourceID;
@end

@implementation CMContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showHelp];
    
    // 블럭 채널 정보.
    [self blockChannel];
    
    // 전문 수신용 옵저버 등록: CM06.
    //    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM06 object:nil];
}

- (void)viewDidUnload
{
    [self setCircleMenu:nil];
    [self setBackgroundView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 전문 수신용 옵저버 등록: CM06.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM06 object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 프라이빗 메서드

- (void)recognizeTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [recognizer.view removeFromSuperview];
    }
}

// 최초 실행 시 도움말 보여주기.
- (void)showHelp
{
    // 앱을 최초 실행했을 경우 도움말을 보여준다.
    if ([LPAppStats numAppOpens] == 1)
    {
        NSString *imageName = nil;
        
        if (AppInfo.isiPhoneFive)
        {
            imageName = @"coachmark01@2x.png";
        }
        else
        {
            imageName = @"coachmark@2x.png";
        }
        
        UIImageView *help = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        help.frame = self.view.frame;
        help.userInteractionEnabled = YES;
        [self.view addSubview:help];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeTapGesture:)];
        [help addGestureRecognizer:recognizer];
    }
}

- (void)circleMenuAction
{
    if (self.circleMenu)
    {
        self.backgroundView.hidden = NO;
        self.circleMenu.hidden = NO;
    }
    else
    {
        self.backgroundView = [[CMOverlayView alloc] initWithFrame:self.view.bounds];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.5f;
        [self.view addSubview:self.backgroundView];

        CMCircleMenu *cm = [[[NSBundle mainBundle] loadNibNamed:@"CMCircleMenu" owner:self options:nil] objectAtIndex:0];
        cm.frame = self.view.frame;
        cm.delegate = self;
        [self.view addSubview:cm];
        self.circleMenu = cm;
    }
    
    self.circleMenu.alpha = 0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.circleMenu.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    [self.view bringSubviewToFront:self.circleMenu];
    [self.circleMenu layoutSubviews];
}

// IP 주소가 공인IP 인지 사설IP인지 체크한다.
- (BOOL)isPrivateAddress:(NSString *)address
{
    return [address hasPrefix:@"192"];
}

// 박스의 이름에서 IP를 가져온다.
// 예: stb_catv_cnm-192-168-0-131
- (NSString *)genAddress:(NSString *)boxName
{
    // 앞의 박스 이름을 제외하고 IP 부분만 가져온다.
    NSString *address = [boxName substringFromIndex:13];
    
    // "-"를 "."로 치환한다.
    return [address stringByReplacingOccurrencesOfString:@"-" withString:@"."];
}

#pragma mark - 퍼블릭 메서드

- (void)toolbarAction:(id)sender
{
    CMMenuType menuType = [(UIButton *)sender tag];
    Debug(@"Selected menu: %d", menuType);
    
    switch (menuType)
    {
        case CMMenuTypePrevious:
        {
            CMRCViewController *viewController =  (CMRCViewController *)CMAppDelegate.container.visibleViewController;
            [viewController toolbarAction:sender];
        }
            break;
            
        case CMMenuTypeGreen:
        {
            CMRCViewController *viewController =  (CMRCViewController *)CMAppDelegate.container.visibleViewController;
            [viewController toolbarAction:sender];
        }
            break;
            
        case CMMenuTypeCircle:
        {
            [self circleMenuAction];
        }
            break;
            
        case CMMenuTypeYellow:
        {
            CMRCViewController *viewController =  (CMRCViewController *)CMAppDelegate.container.visibleViewController;
            [viewController toolbarAction:sender];
        }
            break;
            
        case CMMenuTypeOut:
        {
            CMRCViewController *viewController =  (CMRCViewController *)CMAppDelegate.container.visibleViewController;
            [viewController toolbarAction:sender];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - CMCircleMenuDelegate

- (void)circleMenu:(CMCircleMenu *)circleMenu menuItem:(UIButton *)item menuIndex:(NSUInteger)index
{
    Debug(@"Selected circle menu: %d", index);
    
    // 서클 메뉴 감추기.
    self.backgroundView.hidden = YES;
    self.circleMenu.hidden = YES;
    
    switch (index)
    {
        case 0:
        {
            if (CMAppDelegate.container.viewControllers.count > 1)
            {
                [CMAppDelegate.container popToRootViewControllerAnimated:YES];
            }
            
            // 채널/볼륨.
            CMRCViewController *viewController = (CMRCViewController *)CMAppDelegate.container.viewControllers[0];
            viewController.rcType = CMMRemoteControlTypeChannelVolume;
        }
            break;
            
        case 1:
        {
            if (CMAppDelegate.container.viewControllers.count > 1)
            {
                [CMAppDelegate.container popToRootViewControllerAnimated:YES];
            }
            
            // 사방향키.
            CMRCViewController *viewController = (CMRCViewController *)CMAppDelegate.container.viewControllers[0];
            viewController.rcType = CMMRemoteControlTypeFourDirection;
        }
            break;
            
        case 2:
        {
            // 미러TV 선택 팝업.
            [self checkMirrorTV];
        }
            break;
            
        case 3:
        {
            // 쿼티.
            CMQwertyViewController *viewController = [[CMQwertyViewController alloc] initWithNibName:@"CMQwertyViewController" bundle:nil];
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
            [self presentViewController:viewController animated:YES completion:nil];
        }
            break;
            
        case 4:
        {
            if ([CMAppDelegate.container.topViewController isKindOfClass:[NSClassFromString(@"CMSettingsViewController") class]])
            {
                return;
            }
            
            // 설정.
            CMSettingsViewController *viewController = [[CMSettingsViewController alloc] initWithNibName:@"CMSettingsViewController" bundle:nil];
            viewController.menuType = CMMenuTypeSettings;
            [self pushViewController:viewController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 미러TV 관련

// STB 연결 상태.
- (BOOL)isSTBConnected
{
    BOOL isConnected = NO;
    
    // STB 연결상태 확인.
    if (RemoteManager.appState == kAppStateConnected)
    {
        isConnected = YES;
        
        // 연결이 되어 있는 경우.
        // !!!: 공인IP가 잡히는 경우에 대한 예외 처리!
        // 사설IP(192로 시작...)  여부.
        NSString *address = nil;
        if ([self isPrivateAddress:[RemoteManager.currentBox.addresses objectAtIndex:0]])
        {
            address = [RemoteManager.currentBox.addresses objectAtIndex:0];
        }
        else
        {
            // 박스 이름에서 IP를 가져온다.
            address = [self genAddress:RemoteManager.currentBox.name];
        }
        
        // 원래 코드.
        //NSString *address = [RemoteManager.currentBox.addresses objectAtIndex:0];
        [SocketManager openSocketWithAddress:address andPort:27351];
    }
    else
    {
        isConnected = NO;
        
        // 연결이 안되어 있는 경우.
        DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알람"
                                                            message:@"셋탑박스가 연결되어 있지 않습니다!"
                                                  cancelButtonTitle:@"확인"
                                                   otherButtonTitle:nil];
        [alertView show];
    }
    
    return isConnected;
}

// 미러TV 선택 팝업.
- (void)checkMirrorTV
{
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"미러 TV"
                                                         message:@"미러TV로 이동하시겠습니까?\n스트리밍시간이 몇 초 소요됩니다."
                                               cancelButtonTitle:@"취소"
                                                otherButtonTitle:@"확인"];
    alertView.shouldDismissOnActionButtonClicked = YES;
    [alertView show];
    
    alertView.cancelButtonAction = ^{
        Debug(@"Cancel Clicked");
    };
    alertView.otherButtonAction = ^{
        Debug(@"OK Clicked");
        // 1. STB 연결 상태를 확인한다.
        if ([self isSTBConnected])
        {
            // 2. 채널 상태 확인.
            [self requestChannelStatus];
        }
        
        // 테스트 용 -----------------------------------.
        //                              CMMirrorTVViewController *viewController = [[CMMirrorTVViewController alloc] initWithNibName:DeviceSpecificSetting(@"CMMirrorTVViewController_4", @"CMMirrorTVViewController") bundle:nil];
        //                              viewController.blockChannelInfo = self.blockChannelInfo;
        //                              self.modalPresentationStyle = UIModalPresentationCurrentContext;
        //                              [self presentViewController:viewController animated:YES completion:nil];
        // 테스트 용 -----------------------------------.
    };
}

// 블럭 채널 정보.
- (void)blockChannel
{
    NSURL *url = [NSURL URLWithString:BLOCK_CHANNEL_INFO_URL];
    [[CMHTTPClient sharedCMHTTPClient] requestWithURL:url delegate:self sync:YES];
}

// 채널 상태 확인.
- (void)requestChannelStatus
{
    // 전문 생성.
    CMTRGenerator *generator = [[CMTRGenerator alloc] init];
    NSString *tr = [generator genCM06WithClientIP:[AppInfo getIPAddress]];
    
    // 데이터 전송.
    [SocketManager sendData:tr];
}

// 블럭 채널 확인.
- (BOOL)isBlockedChannel:(NSString *)sourceID
{
    NSDictionary *channelInfo = nil;
    for (NSDictionary *dict in self.blockChannelInfo)
    {
        NSString *left = [[dict objectForKey:@"sourceid"] lowercaseString];
        NSString *right = [sourceID lowercaseString];
        //NSString *block = [dict objectForKey:@"block"];
        
        if ([left isEqualToString:right])
        {
            channelInfo = dict;
            break;
        }
    }
    
    if ([[channelInfo objectForKey:@"block"] isEqualToString:@"O"])
    {
        return YES;
    }
    
    return NO;
}

// 확인 버튼만 있는 얼럿.
- (void)showAlertWithMessage:(NSString *)msg
{    
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알람"
                                                        message:msg
                                              cancelButtonTitle:nil
                                               otherButtonTitle:@"확인"];
    alertView.shouldDismissOnActionButtonClicked = YES;
    alertView.otherButtonAction = ^{
        Debug(@"OK Clicked");
    };
    
    [alertView show];
}

#pragma mark - CMHTTPClientDelegate

- (void)receiveData:(NSDictionary *)dict
{
    Debug(@"Receive data: %@", dict);
    self.blockChannelInfo = [[dict objectForKey:@"channelinfo"] objectForKey:@"item"];
}

#pragma mark - 데이터 수신

// 소켓 데이터 수신.
- (void)receiveSocketData:(NSNotification *)notification
{
    // CM06: Mirror TV Heartbeat.
    if ([notification.name isEqualToString:TR_NO_CM06])
    {
        CM06 *data = [[notification userInfo] objectForKey:CMDataObject];
        NSLog(@"Received data trNo: %@, result: %@", data.trNo, data.result);
        
        // TV 상태 확인.
        NSInteger tvStatus = [data.tvStatus integerValue];
        
        switch (tvStatus)
        {
            case 0:
            {
                // Live.
                
                // 블럭 채널 여부 확인.
                if (![self isBlockedChannel:data.sourceID])
                {
                    [self showAlertWithMessage:MIRRORTV_ERROR_MSG_INTRO];
                }
                else
                {
                    // 채널 정보 설정.
                    CMChannelInfo *ci = [[CMChannelInfo alloc] init];
                    ci.sourceID = data.sourceID;
                    ci.channelNo = data.channelNo;
                    ci.channelName = data.channelName;
                    ci.programTitle = data.title;
                    
                    // 미러TV 진입.
                    CMMirrorTVViewController *viewController = [[CMMirrorTVViewController alloc] initWithNibName:DeviceSpecificSetting(@"CMMirrorTVViewController_4", @"CMMirrorTVViewController") bundle:nil];
                    viewController.blockChannelInfo = self.blockChannelInfo;
                    viewController.channelInfo = ci;
                    
                    self.modalPresentationStyle = UIModalPresentationCurrentContext;
                    [self presentViewController:viewController animated:YES completion:nil];
                    
                    // 미러TV에 진입하면 CM06에 대한 옵저버를 삭제한다.
                    [[NSNotificationCenter defaultCenter] removeObserver:self];
                }
            }
                break;
                
            case 1:
            {
                // VOD.
                [self showAlertWithMessage:MIRRORTV_ERROR_MSG_VOD];
            }
                break;
                
            case 2:
            {
                // Others.
                [self showAlertWithMessage:MIRRORTV_ERROR_MSG_OTHERS];
            }
                break;
                
            case 3:
            {
                // Blocking Channel.
                [self showAlertWithMessage:MIRRORTV_ERROR_MSG_BLOCKING_CHANNEL];
            }
                break;
                
            case 4:
            {
                // Standby.
                [self showAlertWithMessage:MIRRORTV_ERROR_MSG_STANBY];
            }
                break;
                
            default:
            {
                [self showAlertWithMessage:MIRRORTV_ERROR_MSG_VOD];
            }
                break;
        }
    }
}

@end
