//
//  AppDelegate.m
//  CNMRC-2.0.0
//
//  Created by ParkJong Pil on 2014. 11. 22..
//  Copyright (c) 2014년 LambertPark. All rights reserved.
//

#import "AppDelegate.h"
#import "UIDevice+IdentifierAddition.h"
#import "CMAlarmManager.h"
#import "CMHTTPClient.h"
#import "CMGenerator.h"
#import "Setting.h"
#import "DQAlertView.h"
#import "LPAppStats.h"
#import "CMRCViewController.h"
#import "FCFileManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // CocoaLumberjack.
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
#ifdef DEBUG
    static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
    static const DDLogLevel ddLogLevel = DDLogLevelWarn;
#endif
    
    // 앱 실행 횟수 확인
    [NSObject load];
    DDLogDebug(@"\n------------------------------------------------------------------\
          \nNow is the %dth execution!\
          \n------------------------------------------------------------------", [LPAppStats numAppOpens]);
    
    // 알림을 통한 진입인지 확인
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification)
    {
        // 알림으로 인해 앱이 실행된 경우라면..
        // localNotif.userInfo 등을 이용하여
        // 알림과 관계된 화면을 보여주는 등의 코드를 진행할 수 있음.
    }
    
    // AppInfo
    [CMAppInfo sharedCMAppInfo];
    
    // HTTP 클라이언트.
    [CMHTTPClient sharedCMHTTPClient];
    
    // 터미널키 설정.
    [CMHTTPClient sharedCMHTTPClient].terminalKey = CNM_TEST_TERMINAL_KEY;
    
    UIViewController *viewController = [[CMRCViewController alloc] initWithNibName:@"CMRCViewController" bundle:nil];
    self.container = [[CMContainerViewController alloc] initWithRootViewController:viewController];
    self.container.delegate = self;
    self.container.navigationBarHidden = YES;
    self.container.toolbarHidden = NO;
    [self.container.toolbar configureFlatToolbarWithColor:[UIColor colorFromHexCode:@"#252525"]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.container;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 코어데이터 컨텍스트 저장.
    [[LPCoreDataManager instance] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // 코어데이터 컨텍스트 저장.
    [[LPCoreDataManager instance] saveContext];
}

// 로컬노티피케이션 처리.
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // 설정을 확인해야 한다.
    if (AppInfo.isWatchReservationAlarm && application.applicationState == UIApplicationStateActive)
    {
        // Foreground에서 알림 수신
        DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"시청예약알림"
                                                            message:notification.alertBody
                                                  cancelButtonTitle:nil
                                                   otherButtonTitle:@"확인"];
        alertView.shouldDismissOnActionButtonClicked = YES;
        alertView.otherButtonAction = ^{
            NSLog(@"OK Clicked");
            // 로컬노티피케이션 취소.
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        };
        [alertView show];
    }
    
    if(AppInfo.isWatchReservationAlarm && application.applicationState == UIApplicationStateInactive)
    {
        // Background에서 알림 액션에 의한 수신
        // notification.userInfo 이용하여 처리
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"NavigationController view controller count: %d", (int)navigationController.viewControllers.count);
    
    // 리모콘이 아닌 하위 메뉴일 경우...
    if (navigationController.viewControllers.count == 1)
    {
        [navigationController.toolbar openToolbar];
    }
    else if (navigationController.viewControllers.count == 2 &&
             [navigationController.toolbar.isClosed isEqualToString:@"NO"])
    {
        [navigationController.toolbar closeToolbar];
    }
    
    // 인디케이터 보여 주기.
    if (navigationController.viewControllers.count > 1)
    {
        [navigationController.toolbar showIndicator:navigationController.viewControllers.count - 1];
    }
}

@end
