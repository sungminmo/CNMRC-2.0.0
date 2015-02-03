//
//  LPPhoneVersion.h
//  DGBP
//
//  Created by lambert on 2014. 11. 14..
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

#define iOSVersionEqualTo(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define iOSVersionGreaterThan(v)          ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define iOSVersionGreaterThanOrEqualTo(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define iOSVersionLessThan(v)             ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define iOSVersionLessThanOrEqualTo(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

typedef NS_ENUM(NSInteger, LPDeviceVersion) {
    iPhone4 = 3,
    iPhone4S = 4,
    iPhone5 = 5,
    iPhone5C = 5,
    iPhone5S = 6,
    iPhone6 = 7,
    iPhone6Plus = 8,
    
    iPad1 = 9,
    iPad2 = 10,
    iPadMini = 11,
    iPad3 = 12,
    iPad4 = 13,
    iPadAir = 15,
    iPadMiniRetina = 16,
    Simulator = 0
};

typedef NS_ENUM(NSInteger, LPDeviceSize) {
    iPhone35inch = 1,
    iPhone4inch = 2,
    iPhone47inch = 3,
    iPhone55inch = 4
};

@interface LPPhoneVersion : NSObject

/**
 *  @brief  아이폰 버전.
 *
 *  @return LPDeviceVersion.
 */
+ (LPDeviceVersion)deviceVersion;

/**
 *  @brief  아이폰 화면 크기.
 *
 *  @return LPDeviceSize.
 */
+ (LPDeviceSize)deviceSize;

/**
 *  @brief  아이폰 이름.
 *
 *  @return NSString.
 */
+ (NSString *)deviceName;

@end
