//
//  CMMacro.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 6. 25..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "CMAppInfo.h"
#import "CMRemoteManager.h"
#import "CMSocketManager.h"

// !!! 프로젝트의 앱델리게이트의 이름 확인할 것.
#define CMAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

// AppInfo
#define AppInfo [CMAppInfo sharedCMAppInfo]

// CMRemoteManager
#define RemoteManager [CMRemoteManager sharedInstance]

// CMSocketManager
#define SocketManager [CMSocketManager sharedCMSocketManager]

// 아이폰5 여부에 따라 분기할 경우 사용.
#define DeviceSpecificSetting(iPhone, iPhoneFive) ((![CMAppInfo sharedCMAppInfo].isiPhoneFive) ? (iPhone) : (iPhoneFive))

// iOS7 여부.
#define isiOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? YES : NO

// UIColor: RGB
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

// UIColor 값을 RGB로...
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBWithAlpha(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

// UIColor: HSB
#define HSB(h, s, b) [UIColor colorWithHue:h/360.0saturation:s/100.0brightness:b/100.0alpha:1]
#define HSBA(h, s, b, a) [UIColor colorWithHue:h/360.0saturation:s/100.0brightness:b/100.0alpha:a]

// HSB 개별 변환용.
#define CH(h) (h / 360.0)
#define CS(s) (s / 100.0)
#define CB(b) (b / 100.0)

// 각도/라디안.
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(x) ((x) * 180.0 / M_PI)

// UIView frmae(CGRect).
#define width(a) a.frame.size.width
#define height(a) a.frame.size.height
#define top(a) a.frame.origin.y
#define left(a) a.frame.origin.x
#define FrameReposition(a,x,y) a.frame = CGRectMake(x, y, width(a), height(a))
#define FrameResize(a,w,h) a.frame = CGRectMake(left(a), top(a), w, h)

// !!!: 개발 시 간단히 테스트 할 시에먄 사용하고, 코드 상에 상시 추가할 것이라면 LPStopwatch를 사용하라!
// 벤치마킹.
#define START_TIMER NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
#define END_TIMER(msg) NSTimeInterval stop = [NSDate timeIntervalSinceReferenceDate]; NSLog([NSString stringWithFormat:@"%@ Time = %f", msg, stop-start]);

// 사용법.
//- (void)loadStockCodeMaster
//{
//    START_TIMER;
//    NSURL *url = [NSURL URLWithString:STOCK_CODE_MASTER_URL];
//    NSString *stringFile = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//    END_TIMER(@"loadStockCodeMaster");
//}

/**
 POST/GET 방식으로 데이터를 요청한다(dict이 nil 이면 GET 방식 전송).
 
 @param url 서버 URL.
 @param obj 델리게이터 객체.
 @param dict 데이터 요청을 위한 전문의 키 = 값 형태의 NSDictionary.
 @param isSynchronous 동기 여부.
 */
#define request(url, obj, dict, isSynchronous) [[CMHTTPClient sharedCMHTTPClient] requestWithURL:url delegate:obj andDictionary:dict sync:isSynchronous]

