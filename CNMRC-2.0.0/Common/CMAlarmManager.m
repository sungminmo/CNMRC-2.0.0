//
//  CMAlarmManager.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 24..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMAlarmManager.h"

@implementation CMAlarmManager

+ (void)fireLocalNotificationWitTitle:(NSString *)title andDate:(NSDate *)date;
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    // 5분전 등록.
    notification.timeZone = [NSTimeZone systemTimeZone];
    notification.fireDate = [NSDate dateWithTimeInterval:-(60*5) sinceDate:date];
    notification.alertBody = title;
    notification.alertAction = @"확인";
    //notification.applicationIconBadgeNumber = 1;
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // UIApplication을 이용하여 알림을 등록.
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
