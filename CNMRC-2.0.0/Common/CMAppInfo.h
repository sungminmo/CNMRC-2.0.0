//
//  CMAppInfo.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 6. 26..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Setting;

@interface CMAppInfo : NSObject

@property (assign, nonatomic) BOOL isiPhoneFive;            // iPhone5 여부.
@property (assign, nonatomic) BOOL isPaired;                // 페어링 여부.
@property (assign, nonatomic) BOOL isSecondTV;              // SecondTV 여부.(수신된 SecondTV 필드의 값이 1 이면 SecondTV 이다.)

// 설정 관련.
@property (assign, nonatomic) BOOL isVibration;             // 진동효과 사용 여부.
@property (assign, nonatomic) BOOL isSound;                 // 소리효과 사용 여부.
@property (assign, nonatomic) float touchtouchSensitivity;  // 터치 속도.
@property (assign, nonatomic) BOOL isUpdateVODAlarm;        // VOD업데이트 알림 사용 여부.
@property (assign, nonatomic) BOOL isWatchReservationAlarm; // 시청예약 알림 사용 여부.
@property (strong, nonatomic) NSString *areaCode;           // 지역코드.
@property (strong, nonatomic) NSString *areaName;           // 지역명.
@property (strong, nonatomic) NSString *productCode;        // 상품코드.
@property (strong, nonatomic) NSString *productName;        // 상품명.
@property (assign, nonatomic) BOOL isAutoAuthAdult;         // 자동성인인증하기여부.
@property (assign, nonatomic) BOOL isAdult;                 // 성인여부.

/**
 싱글턴 인스턴스 반환.
 
 @return HWAppInfo 싱글턴 인스턴스 반환.
 */
+ (CMAppInfo *)sharedCMAppInfo;

/**
 teminalID 값을 저장한다.
 */
- (void)importDefaultSetting;

/**
 설정 정보를 로드한다.
 */
- (void)loadSettings;

/**
 설정 정보를 세팅한다.
 */
- (void)resetSettings:(Setting *)setting;

/**
 *  클라이언트의 IP Address를 반환한다.
 *
 *  @return IP Address.
 */
- (NSString *)getIPAddress;

@end
