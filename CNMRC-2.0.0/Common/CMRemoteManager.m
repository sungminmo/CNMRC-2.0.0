//
//  CMRmoteManager.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 19..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMRemoteManager.h"
#import "Reachability.h"
#import "LPToast.h"
#import "RToast.h"
#import "NSSet+Additions.h"
#import "CMPairingViewController.h"
#import "DQAlertView.h"
#import "CMBoxListViewController.h"
#import "WishList.h"
#import "CMTRGenerator.h"

// 검색된 마지막 박스를 저장하기 위해...
static NSString * const kLastBoxKey = @"kLastBoxKey";

@interface CMRemoteManager ()
- (void)showNoWifiAlert;
- (void)onStateIdle;
- (void)startConnecting;
- (void)sendWishList;
@end

@implementation CMRemoteManager

- (void)dealloc
{
    // Stop Notifier
    if (_reachability)
    {
        [_reachability stopNotifier];
    }
}

+ (CMRemoteManager *)sharedInstance
{
    static CMRemoteManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        _sender = [[PoloSender alloc] init];
        [_sender setDelegate:self];
        [self setCommandHandler:[[CommandHandler alloc] initWithSender:_sender]];
        
        _isWifiEnabled = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        // Reachability 초기화.
        self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
        
        // 모니터링 시작.
        [self.reachability startNotifier];
        
        _appState = kAppStateIdle;
        [self onStateIdle];
        
        _currentErrorCount = 0;
    }
    return self;
}

#pragma mark - Reachability 클래스 메서드

+ (BOOL)isReachable
{
    return [[[CMRemoteManager sharedInstance] reachability] isReachable];
}

+ (BOOL)isUnreachable
{
    return ![[[CMRemoteManager sharedInstance] reachability] isReachable];
}

+ (BOOL)isReachableViaWWAN
{
    return [[[CMRemoteManager sharedInstance] reachability] isReachableViaWWAN];
}

+ (BOOL)isReachableViaWiFi
{
    return [[[CMRemoteManager sharedInstance] reachability] isReachableViaWiFi];
}

- (void)reachabilityChanged:(NSNotification *)noti
{
    Reachability *reach = [noti object];
    BOOL oldIsWifiEnabled = _isWifiEnabled;
    _isWifiEnabled = [reach isReachable] && ![reach isReachableViaWWAN];
    
    if (!oldIsWifiEnabled && _isWifiEnabled)
    {
        [self onStateIdle];
    }
    else if (oldIsWifiEnabled && !_isWifiEnabled)
    {
        [self performSelector:@selector(changeStateToIdleIfWifiStillUnavailable)
                   withObject:nil
                   afterDelay:5];
    }
}

- (void)changeStateToIdleIfWifiStillUnavailable
{
    if (!_isWifiEnabled)
    {
        NSLog(@"WiFi is still not available. Changing state to idle.");
        [_sender close];
        [self changeState:kAppStateIdle];
    }
}

#pragma mark - 프라이빗 메서드

- (void)showNoWifiAlert
{
    NSString *title = NSLocalizedString(@"WiFi를 이용할 수 없습니다.", @"");
    NSString *msg = NSLocalizedString(@"설정 메뉴에서 WiFi를 켜십시오.", @"");
    
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:title
                                                        message:msg
                                              cancelButtonTitle:nil
                                               otherButtonTitle:@"확인"];
    alertView.shouldDismissOnActionButtonClicked = YES;
    alertView.otherButtonAction = ^{
        NSLog(@"OK Clicked");
        // 상태 변경.
        if (_appState == kAppStateIdle)
        {
            [self onStateIdle];
        }
    };
    
    [alertView show];
}

- (void)onStateIdle
{
    if (!_isWifiEnabled)
    {
        [self showNoWifiAlert];
    }
    else
    {
        [self startConnecting];
    }
}

- (void)startConnecting
{
    // 마지막으로 연결되었던 박스가 사용가능하다면 연결한다.
    [self setCurrentBox:[self recentlyUsedBox]];
    if ([self currentBox])
    {
        [self changeState:kAppStateConnecting];
        [RToast showToastWithSpinner:NSLocalizedString(@"연결중...", @"")];
        CMBoxService *box = [self currentBox];
        NSLog(@"Connecting to last used box: %@", box);
        [_sender connectToHost:[[box addresses] objectAtIndex:0]
                        atPort:[box port]];
    } else
    {
        [self showDeviceFinder];
    }
}


- (NSString *)stateName:(CMAppState)state
{
#define CASE_MACRO(state) case state: return @#state;
    switch (state)
    {
            CASE_MACRO(kAppStateIdle)
            CASE_MACRO(kAppStateConnecting)
            CASE_MACRO(kAppStateConnected)
            CASE_MACRO(kAppStateDeviceFinder)
            CASE_MACRO(kAppStatePairing)
        default:
            return @"--STATE UNKNOWN--";
    }
#undef CASE_MACRO
}

- (void)changeState:(CMAppState)toState
{
    NSSet *allowed = [[self allowedTransitions] objectAtIndex:_appState];
    if ([allowed containsObject:[NSNumber numberWithInt:toState]])
    {
        NSLog(@"Changing state from %@ to %@", [self stateName:_appState], [self stateName:toState]);
        _appState = toState;
    }
    else
    {
        NSLog(@"WARNING: incorrect app state change from %@ to %@",
                   [self stateName:_appState], [self stateName:toState]);
    }
}

// VOD 찜하기 전송.
- (void)sendWishList
{
    NSArray *list = [WishList all];
    if (list.count > 0)
    {
        for (int i = 0; i < list.count; i++)
        {
            WishList *wishList = [list objectAtIndex:i];
            
            NSString *address = [self.currentBox.addresses objectAtIndex:0];
            [SocketManager openSocketWithAddress:address andPort:27351];
            
            // 전문 생성.
            CMTRGenerator *generator = [[CMTRGenerator alloc] init];
            NSString *tr = [generator genCM01WithDate:[wishList.date stringFromDateWithType:StringFromDateTypeNetwork] assetID:wishList.assetID];
            
            // 데이터 전송.
            [SocketManager sendData:tr];
        }
    }
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

- (CMBoxService *)recentlyUsedBox
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *data = [ud objectForKey:kLastBoxKey];
    
    if (data)
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (NSArray *)allowedTransitions
{
    if (!_allowedTransitions)
    {
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:kAppSateNum];
        [temp insertObject:[NSSet tv_setWithInts:2, kAppStateConnecting,
                            kAppStateDeviceFinder]
                   atIndex:kAppStateIdle];
        [temp insertObject:[NSSet tv_setWithInts:4, kAppStateIdle,
                            kAppStateConnected,
                            kAppStateDeviceFinder,
                            kAppStatePairing]
                   atIndex:kAppStateConnecting];
        [temp insertObject:[NSSet tv_setWithInts:1, kAppStateIdle]
                   atIndex:kAppStateConnected];
        [temp insertObject:[NSSet tv_setWithInts:1, kAppStateIdle]
                   atIndex:kAppStateDeviceFinder];
        [temp insertObject:[NSSet tv_setWithInts:2, kAppStateIdle,
                            kAppStateConnected]
                   atIndex:kAppStatePairing];
        _allowedTransitions = temp;
    }
    return _allowedTransitions;
}

- (void)presentPairingDialog
{
    CMPairingViewController *pairing = [[CMPairingViewController alloc] initWithNibName:@"CMPairingViewController" bundle:nil];
    [pairing setDelegate:self];
    [CMAppDelegate.container  pushViewController:pairing animated:YES];
}

- (void)showDeviceFinder
{
    if (_appState == kAppStateConnected)
    {
        // 다른 박스로 변경할 수 있도록 _sender를 종료다.
        [_sender close];
        [self changeState:kAppStateIdle];
    }
    [self changeState:kAppStateDeviceFinder];
//    NSArray *controllersInNav = [AppDelegate.container viewControllers];
//    if (![controllersInNav containsObject:boxListController_])
//    {
//        [boxListController_ setAvailableBoxes:[NSArray array]];
//        [AppDelegate.container pushViewController:boxListController_ animated:YES];
//    }
}

// 페어링 여부 확인.
- (void)checkPairing
{
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"씨앤앰 TV 연결"
                                                        message:@"씨앤앰 셋톱박스를 \n연결하시겠습니까?"
                                              cancelButtonTitle:@"취소"
                                               otherButtonTitle:@"확인"];
    alertView.shouldDismissOnActionButtonClicked = YES;
    alertView.otherButtonAction = ^{
        NSLog(@"OK Clicked");
        // 박스 찾기.
        CMBoxListViewController *viewController = [[CMBoxListViewController alloc] initWithNibName:@"CMBoxListViewController" bundle:nil];
        viewController.delegate = self;
        [CMAppDelegate.container pushViewController:viewController animated:YES];
    };
    
    [alertView show];
}

#pragma mark CMBoxListDelegate

// 사용자가 박스를 선택했을 경우 호출된다.
- (void)didSelectBox:(CMBoxService *)service
{
    if (_appState != kAppStateConnecting)
    {
        [self changeState:kAppStateIdle];
        [self setCurrentBox:service];
        [self changeState:kAppStateConnecting];
        [RToast showToastWithSpinner:NSLocalizedString(@"연결중...", @"")];
        [_sender connectToHost:[[service addresses] objectAtIndex:0]
                        atPort:[service port]];
    }
}

- (void)boxListControllerWasCancelled:(CMBoxListViewController *)controller
{
    //[self hideBoxSelectionViewAnimated:YES];
    [self changeState:kAppStateIdle];
    if ([self recentlyUsedBox] == nil)
    {
        DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                            message:@"시앤앰 셋톱박스가 선택되지 않았습니다.\n 셋톱박스를 찾습니다."
                                                  cancelButtonTitle:nil
                                                   otherButtonTitle:@"확인"];
        alertView.shouldDismissOnActionButtonClicked = YES;
        alertView.otherButtonAction = ^{
            NSLog(@"OK Clicked");
            // 상태 변경.
            if (_appState == kAppStateIdle)
            {
                [self onStateIdle];
            }
        };
        
        [alertView show];
    }
    else
    {
        [self onStateIdle];
    }
}

- (void)boxListViewControllerWasCancelled:(CMBoxListViewController *)viewController
{
    
}

#pragma mark PoloSenderDelegate

// 연결 성공.
- (void)poloSenderDidConnect:(PoloSender *)sender
{
    [self changeState:kAppStateConnected];
    NSLog(@"Connected to box");
    
    [RToast showToast:NSLocalizedString(@"연결됐습니다.", @"") forDuration:2];
    AppInfo.isPaired = YES;
    
    // 셋톱박스가 연결되면, VOD 찜하기 데이터를 전송한다.
    [self sendWishList];
    
    if ([self currentBox])
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:[self currentBox]]
               forKey:kLastBoxKey];
        [ud synchronize];
    }
    
    if (CMAppDelegate.container.viewControllers.count >= 2)
    {        
        [CMAppDelegate.container popToRootViewControllerAnimated:YES];
    }
}

// 연결하는 동안 에러 발생. 재 접속 시도.
- (void)poloSender:(PoloSender *)sender failedWithError:(NSError *)error
{
    NSInteger code = [error code];
    NSLog(@"Connection error (code: %ld): %@ ", (long)code, [error localizedFailureReason]);
    
    if (_appState == kAppStateConnected)
    {
        [RToast showToast:NSLocalizedString(@"셋톱박스에 연결되지 않았습니다.", @"") forDuration:2];
        [self changeState:kAppStateIdle];
        [_sender close];
        [self onStateIdle];
    }
    else if (_appState == kAppStateConnecting && code == POLO_ERR_CONNECTION_FAILURE)
    {
        [self changeState:kAppStateIdle];
        [RToast showToast:NSLocalizedString(@"씨앤앰 셋톱박스에 연결할 수 없습니다.", @"") forDuration:2];
        [self showDeviceFinder];
    }
    else if (_appState == kAppStateDeviceFinder)
    {
        _currentErrorCount += 1;
        
        // !!!: 에러가 두 번 들어오기 때문에 한 번을 걸려 낸다.
        if ((_currentErrorCount % 2) == 0)
        {
            // 박스 찾기 얼럿.
            [self checkPairing];
        }
    }
}

- (void)poloSenderNeedsSecret:(PoloSender *)sender
{
    if (_appState == kAppStateConnecting)
    {
        [self changeState:kAppStatePairing];
        [self presentPairingDialog];
    }
}

#pragma mark CMPairingViewControllerDelegate

// Checking if user's secret is correct one.
- (BOOL)continuePairingWithSecret:(NSString *)secret
{
    return [_sender continuePairingWithSecret:secret];
}

// User has choosen to cancel entering code on pairing screen;
- (void)didCancelPairing
{
    [self changeState:kAppStateIdle];
    [_sender cancelPairing];
    [CMAppDelegate.container popViewControllerAnimated:YES];
    // As pairing can be shown from other than BoxListController.
    NSArray *controllers = [CMAppDelegate.container viewControllers];
//    if ([controllers containsObject:boxListController_])
//    {
//        [self changeState:kAppStateDeviceFinder];
//    }
}

@end
