//
//  UIDevice+Hardware.h
//  ShinhanBank
//
//  Created by Jong Pil Park on 12. 9. 21..
//  Copyright (c) 2012년 LambertPark. All rights reserved.
//

/**
 디바이스 정보를 확인하기 위한 클래스이다.
 */

#import <UIKit/UIKit.h>

@interface UIDevice (Hardware)

/**
 플랫폼 정보를 출력한다.
 */
- (NSString *)platform;

/**
 플랫폼 이름을 출력한다.
 */
- (NSString *)platformString;

/**
 레티나 디스플렉이 지원 여부.
 */
- (BOOL)hasRetinaDisplay;

/**
 멀티태스킹 지원 여부.
 */
- (BOOL)hasMultitasking;

/**
 플랫폼의 iPhone5 여부.
 */
- (BOOL)isiPhoneFive;

@end
