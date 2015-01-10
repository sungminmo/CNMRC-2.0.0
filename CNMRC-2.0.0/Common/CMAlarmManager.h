//
//  CMAlarmManager.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 24..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMAlarmManager : NSObject

/**
 *	시청예약알림 등록(무조건 5분전으로로 등록한다).
 *
 *	@param title 제목(프로그램 이름).
 *	@param date 프로그램 시작 시간.
 */
+ (void)fireLocalNotificationWitTitle:(NSString *)title andDate:(NSDate *)date;

@end
