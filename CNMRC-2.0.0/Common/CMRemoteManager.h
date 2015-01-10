//
//  CMRmoteManager.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 19..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PoloSender.h"
#import "CMBoxFinder.h"
#import "CMBoxListViewController.h"
#import "CMPairingViewController.h"
#import "CommandHandler.h"

// 앱의 상태.
typedef NS_ENUM(NSInteger, CMAppState) {
    kAppStateIdle,
    kAppStateConnecting,
    kAppStateConnected,
    kAppStateDeviceFinder,
    kAppStatePairing,
    
    kAppSateNum
};

@class Reachability;

@interface CMRemoteManager : NSObject <CMBoxListDelegate, PoloSenderDelegate, CMPairingViewControllerDelegate>
{
    //CMAppState _appState;
    BOOL _isWifiEnabled;
    NSInteger _currentErrorCount;
}
@property (strong, nonatomic) Reachability *reachability;
@property (strong, nonatomic) CommandHandler *commandHandler;
@property (strong, nonatomic, readonly) PoloSender *sender;
@property (strong, nonatomic) CMBoxService *currentBox;
@property (nonatomic, readonly) CMBoxService *recentlyUsedBox;
@property (strong, nonatomic) NSArray *allowedTransitions;
@property (nonatomic, readonly) CMAppState appState;

/**
 싱글턴 인스턴스 반환.
 
 @return CMRmoteManager 싱글턴 인스턴스 반환.
 */
+ (CMRemoteManager *)sharedInstance;

+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

- (void)presentPairingDialog;
- (void)showDeviceFinder;
- (void)changeState:(CMAppState)toState;
- (void)checkPairing;

@end
