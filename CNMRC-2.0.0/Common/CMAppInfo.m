//
//  CMAppInfo.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 6. 26..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMAppInfo.h"
#import "UIDevice+IdentifierAddition.h"
#import "UIDevice+Hardware.h"
#import "Setting.h"

// IP Address
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation CMAppInfo

+ (CMAppInfo *)sharedCMAppInfo
{
    static CMAppInfo *sharedCMAppInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCMAppInfo = [[self alloc] init];
    });
    return sharedCMAppInfo;
}

- (id)init
{
    if (self = [super init])
    {
        // iPhone5 여부.
        UIDevice *device = [[UIDevice alloc] init];
        self.isiPhoneFive = [device isiPhoneFive];
        
        // 설정 정보의 기본값 세팅.
        [self importDefaultSetting];
        
        // 설정 정보를 로드한다.
        [self loadSettings];
        
        [AsyncImageLoader sharedLoader].cache = NO;
    }
    return self;
}

- (void)setIsAutoAuthAdult:(BOOL)isAutoAuthAdult
{
    _isAutoAuthAdult = isAutoAuthAdult;
    self.isAdult = _isAutoAuthAdult;
}

- (void)importDefaultSetting
{
    NSArray *settings = [Setting all];
    
    if (settings.count == 0)
    {
        Setting *setting = [Setting create];
        
        // 터미널ID 설정.
        setting.terminalID = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
        
        // 진동효과.
        setting.isVibration = [NSNumber numberWithBool:YES];
        
        // 소리효과.
        setting.isSound = [NSNumber numberWithBool:YES];
        
        // 터치속도.
        setting.touchSensitivity = [NSNumber numberWithFloat:0.5];
        
        // VOD업데이트 알림(APNS).
        setting.isUpdateVODAlarm = [NSNumber numberWithBool:YES];
        
        // 시청예약 알림.
        setting.isWatchReservationAlarm = [NSNumber numberWithBool:YES];
        
        // 지역코드/명 기본값.
        setting.areaCode = @"12";
        setting.areaName = @"송파";
        
        // 상품정보/명 기본값.
        setting.productCode = @"12";
        setting.productName = @"디지털기본형";
        
        // 자동성인인증하기 여부(성인인증 여부 포함).
        setting.isAutoAuthAdult = [NSNumber numberWithBool:NO];
        
        [setting save];
    }
}

- (void)loadSettings
{
    [self resetSettings:[[Setting all] objectAtIndex:0]];
}

- (void)resetSettings:(Setting *)setting
{
    self.isVibration = [setting.isVibration boolValue];
    self.isSound = [setting.isSound boolValue];
    self.touchtouchSensitivity = [setting.touchSensitivity floatValue];
    self.isUpdateVODAlarm = [setting.isUpdateVODAlarm boolValue];
    self.isWatchReservationAlarm = [setting.isWatchReservationAlarm boolValue];
    self.areaCode = setting.areaCode;
    self.areaName = setting.areaName;
    self.productCode = setting.productCode;
    self.productName = setting.productName;
    self.isAutoAuthAdult = [setting.isAutoAuthAdult boolValue];
}

// IP Address.
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL)
        {
            if (temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

@end
