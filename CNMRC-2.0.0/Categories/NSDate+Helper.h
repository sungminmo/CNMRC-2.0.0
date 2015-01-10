//
//  NSDate+Helper.h
//  HWSmartCalendar
//
//  Created by thyung kim on 13. 3. 27..
//  Copyright (c) 2013년 LambertPark. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, StringFromDateType)  {
    StringFromDateTypeDefault = 0,
    StringFromDateTypeYear = 1,
    StringFromDateTypeMonth = 2,
    StringFromDateTypeDay = 3,
    StringFromDateTypeYearAndMonth = 4,
    StringFromDateTypeMonthAndDay = 5,
    StringFromDateTypeTimeDefault = 6,
    StringFromDateTypeTimeSymbolAndHourAndMinute = 7,
    StringFromDateTypeHourAndMinute = 8,
    StringFromDateTypeNetwork = 9,
    StringFromDateTypeYYMMDD = 10,
    StringFromDateTypeHHmmss = 11,
    StringFromDateTypeMonthAndDayKorea = 12
};

@interface NSDate (Helper)

- (NSDate *)toLocalTime;
- (NSDate *)toGlobalTime;
- (NSString *)stringFromDateWithType:(StringFromDateType)stringFromDateType;

- (NSInteger)year;

- (NSInteger)month;

- (NSInteger)day;

- (NSInteger)hour;

- (NSInteger)minute;

- (NSDate *)beginningOfDay;
- (NSDate *)beginningOfMonth;
- (NSDate *)beginningOfQuarter;
- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfYear;

- (NSDate *)endOfDay;
- (NSDate *)endOfMonth;
- (NSDate *)endOfQuarter;
- (NSDate *)endOfWeek;
- (NSDate *)endOfYear;

- (NSDate *)advance:(int)years months:(int)months weeks:(int)weeks days:(int)days
			  hours:(int)hours minutes:(int)minutes seconds:(int)seconds;

- (NSDate *)ago:(int)years months:(int)months weeks:(int)weeks days:(int)days
          hours:(int)hours minutes:(int)minutes seconds:(int)seconds;

- (NSDate *)change:(NSDictionary *)changes;

- (int)daysInMonth;

- (NSDate *)monthsSince:(int)months;
- (NSDate *)yearsSince:(int)years;

- (NSDate *)nextMonth;
- (NSDate *)nextWeek;
- (NSDate *)nextYear;

- (NSDate *)prevMonth;
- (NSDate *)prevYear;
- (NSDate *)yearsAgo:(int)years;
- (NSDate *)yesterday;
- (NSDate *)tomorrow;

- (NSDate *)dateOnly;
- (NSDate *)dateOnlyAndSetDay:(int)day;

- (BOOL)future;
- (BOOL)past;
- (BOOL)today;

- (NSUInteger)daysAgo;
- (NSUInteger)daysAgoAgainstMidnight;
- (NSString *)stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger)weekday;
- (NSString *)stringWeekFromDate;
- (NSString *)weekFromDate;

+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime;

- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)dbFormatString;

- (NSDateComponents *)dateComponentsWithTimeZone:(NSTimeZone *)timeZone;
+ (NSDate *)dateWithDateComponents:(NSDateComponents *)components;

- (BOOL)isSameDay:(NSDate *)anotherDate;
- (BOOL)isSameDay:(NSDate *)anotherDate timeZone:(NSTimeZone *)timeZone;
- (BOOL)isSameMonth:(NSDate*)anotherDate;
- (BOOL)isSameMonth:(NSDate *)anotherDate timeZone:(NSTimeZone *)timeZone;

- (BOOL)isToday;
- (BOOL)isTodayWithTimeZone:(NSTimeZone *)timeZone;

- (BOOL)isBetween:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
- (BOOL)isMonthLastDay;

@end
