//
//  NSDate+Helper.m
//  HWSmartCalendar
//
//  Created by thyung kim on 13. 3. 27..
//  Copyright (c) 2013년 LambertPark. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

// 로컬 시간.
- (NSDate *)toLocalTime
{
    // 타임존을 한국으로 설정.
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"Asia/Seoul"];
    NSInteger seconds = [tz secondsFromGMTForDate:self];
    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}

// 글로벌 시간.
- (NSDate *)toGlobalTime
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate:self];
    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}

// NSDate -> NSString.
- (NSString *)stringFromDateWithType:(StringFromDateType)stringFromDateType
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    switch (stringFromDateType)
    {
        case StringFromDateTypeDefault:
        {
            [formatter setDateFormat:@"yyyy-MM-dd"];
        }
            break;
            
        case StringFromDateTypeYear:
        {
            [formatter setDateFormat:@"yyyy"];
        }
            break;
            
        case StringFromDateTypeMonth:
        {
            [formatter setDateFormat:@"MM"];
        }
            break;
            
        case StringFromDateTypeDay:
        {
            [formatter setDateFormat:@"dd"];
        }
            break;
            
        case StringFromDateTypeYearAndMonth:
        {
            [formatter setDateFormat:@"yyyy.MM"];
        }
            break;
            
        case StringFromDateTypeMonthAndDay:
        {
            [formatter setDateFormat:@"MM.dd"];
        }
            break;
            
        case StringFromDateTypeTimeDefault:
        {
            [formatter setDateFormat:@"HH:mm:ss"];
        }
            break;
            
        case StringFromDateTypeTimeSymbolAndHourAndMinute:
        {
            formatter.timeStyle = NSDateFormatterShortStyle;
            [formatter setDateFormat:@"a hh:mm"];
        }
            break;
            
        case StringFromDateTypeHourAndMinute:
        {
            formatter.timeStyle = NSDateFormatterShortStyle;
            [formatter setDateFormat:@"HH:mm"];
        }
            break;
            
        case StringFromDateTypeNetwork:
        {
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
        }
            break;
            
        case StringFromDateTypeYYMMDD:
        {
            [formatter setDateFormat:@"yyyyMMdd"];
        }
            break;
            
        case StringFromDateTypeHHmmss:
        {
            formatter.timeStyle = NSDateFormatterShortStyle;
            [formatter setDateFormat:@"HHmmss"];
        }
            break;
            
        case StringFromDateTypeMonthAndDayKorea:
        {
            formatter.timeStyle = NSDateFormatterShortStyle;
            [formatter setDateFormat:@"MM월 dd일"];
        }
            break;
            
        default:
            break;
    }
    
    NSString *stringDate = [formatter stringFromDate:self];
    [formatter release];
    
    return stringDate;
}

- (NSInteger)year
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:self];
    return [dateComponents year];
}

- (NSInteger)month
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:self];
    return [dateComponents month];
}

- (NSInteger)day
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self];
    return [dateComponents day];
}

- (NSInteger)hour
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:self];
    return [dateComponents hour];
}

- (NSInteger)minute
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:self];
    return [dateComponents minute];
}

#pragma mark - Beginning of

- (NSDate *)beginningOfDay
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSDate *)beginningOfMonth
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setDay:1];
	[comps setHour:0];
	[comps setMinute:00];
	[comps setSecond:00];
	
	return [currentCalendar dateFromComponents:comps];
}

// 1st of january, april, july, october
- (NSDate *)beginningOfQuarter
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	int month = [comps month];
	
	if (month < 4)
		[comps setMonth:1];
	else if (month < 7)
		[comps setMonth:4];
	else if (month < 10)
		[comps setMonth:7];
	else
		[comps setMonth:10];
    
	[comps setDay:1];
	[comps setHour:0];
	[comps setMinute:00];
	[comps setSecond:00];
	
	return [currentCalendar dateFromComponents:comps];
}

// Week starts on sunday for the gregorian calendar
- (NSDate *)beginningOfWeek
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setWeekday:1];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSDate *)beginningOfYear
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setMonth:1];
	[comps setDay:1];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	
	return [currentCalendar dateFromComponents:comps];
}

#pragma mark - End of

- (NSDate *)endOfDay
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSDate *)endOfMonth
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setDay:[self daysInMonth]];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	
	return [currentCalendar dateFromComponents:comps];
}

// 1st of january, april, july, october
- (NSDate *)endOfQuarter
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	int month = [comps month];
	
	if (month < 4)
	{
		[comps setMonth:3];
		[comps setDay:31];
	}
	else if (month < 7)
	{
		[comps setMonth:6];
		[comps setDay:30];
	}
	else if (month < 10)
	{
		[comps setMonth:9];
		[comps setDay:30];
	}
	else
	{
		[comps setMonth:12];
		[comps setDay:31];
	}
	
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSDate *)endOfWeek
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setWeekday:7];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSDate *)endOfYear
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setMonth:12];
	[comps setDay:31];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	
	return [currentCalendar dateFromComponents:comps];
}

#pragma mark - Other Calculations

- (NSDate *)advance:(int)years months:(int)months weeks:(int)weeks days:(int)days
			  hours:(int)hours minutes:(int)minutes seconds:(int)seconds
{
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	[comps setYear:years];
	[comps setMonth:months];
	[comps setWeek:weeks];
	[comps setDay:days];
	[comps setHour:hours];
	[comps setMinute:minutes];
	[comps setSecond:seconds];
	
	return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate *)ago:(int)years months:(int)months weeks:(int)weeks days:(int)days
		  hours:(int)hours minutes:(int)minutes seconds:(int)seconds
{
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	[comps setYear:-years];
	[comps setMonth:-months];
	[comps setWeek:-weeks];
	[comps setDay:-days];
	[comps setHour:-hours];
	[comps setMinute:-minutes];
	[comps setSecond:-seconds];
	
	return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate *)change:(NSDictionary *)changes
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
							  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |
							  NSWeekCalendarUnit | NSWeekdayCalendarUnit |  NSWeekdayOrdinalCalendarUnit |
							  NSQuarterCalendarUnit);
	
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	for (id key in changes) {
		SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@:", [key capitalizedString]]);
		int value = [[changes valueForKey:key] intValue];
		
		NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[comps methodSignatureForSelector:selector]];
		[inv setSelector:selector];
		[inv setTarget:comps];
		[inv setArgument:&value atIndex:2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
		[inv invoke];
	}
    
	return [currentCalendar dateFromComponents:comps];
}

- (int)daysInMonth
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	NSRange days = [currentCalendar rangeOfUnit:NSDayCalendarUnit
										 inUnit:NSMonthCalendarUnit
										forDate:self];
	return days.length;
}

- (NSDate *)monthsSince:(int)months
{
	return [self advance:0 months:months weeks:0 days:0 hours:0 minutes:0 seconds:0];
}

- (NSDate *)yearsSince:(int)years
{
	return [self advance:years months:0 weeks:0 days:0 hours:0 minutes:0 seconds:0];
}

- (NSDate *)nextMonth
{
	return [self monthsSince:1];
}

- (NSDate *)nextWeek
{
	return [self advance:0 months:0 weeks:1 days:0 hours:0 minutes:0 seconds:0];
}

- (NSDate *)nextYear
{
	return [self advance:1 months:0 weeks:0 days:0 hours:0 minutes:0 seconds:0];
}

- (NSDate *)prevMonth
{
	return [self monthsSince:-1];
}

- (NSDate *)prevYear
{
	return [self yearsAgo:1];
}

- (NSDate *)yearsAgo:(int)years
{
	return [self advance:-years months:0 weeks:0 days:0 hours:0 minutes:0 seconds:0];
}

- (NSDate *)yesterday
{
	return [self advance:0 months:0 weeks:0 days:-1 hours:0 minutes:0 seconds:0];
}

- (NSDate *)tomorrow
{
	return [self advance:0 months:0 weeks:0 days:1 hours:0 minutes:0 seconds:0];
}

- (NSDate *)dateOnly
{
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:flags fromDate:self];
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)dateOnlyAndSetDay:(int)day
{
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:flags fromDate:self];
    [components setDay:day];
    
    return [calendar dateFromComponents:components];
}

- (BOOL)future
{
	return self == [self laterDate:[NSDate date]];
}

- (BOOL)past
{
	return self == [self earlierDate:[NSDate date]];
}

- (BOOL)today
{
	return self == [self laterDate:[[NSDate date] beginningOfDay]] &&
    self == [self earlierDate:[[NSDate date] endOfDay]];
}

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit)
											   fromDate:self
												 toDate:[NSDate date]
												options:0];
	return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight
{
	// get a midnight version of ourself:
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
	[mdf release];
	
	return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSString *)stringDaysAgo
{
	return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag
{
	NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
	NSString *text = nil;
	switch (daysAgo) {
		case 0:
			text = @"Today";
			break;
		case 1:
			text = @"Yesterday";
			break;
		default:
			text = [NSString stringWithFormat:@"%d days ago", daysAgo];
	}
	return text;
}

// 일요일이 1이다.
- (NSUInteger)weekday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:self];
	return [weekdayComponents weekday];
}


- (NSString*)stringWeekFromDate
{
    NSInteger index = [self weekday];
    
    switch (index - 1)
    {
        case 0: return @"일요일";
        case 1: return @"월요일";
        case 2: return @"화요일";
        case 3: return @"수요일";
        case 4: return @"목요일";
        case 5: return @"금요일";
        case 6: return @"토요일";
    }
    return @"";
}


- (NSString*)weekFromDate
{
    NSInteger index = [self weekday];
    
    switch (index - 1)
    {
        case 0: return @"일";
        case 1: return @"월";
        case 2: return @"화";
        case 3: return @"수";
        case 4: return @"목";
        case 5: return @"금";
        case 6: return @"토";
    }
    return @"";
}


+ (NSDate *)dateFromString:(NSString *)string
{
	return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format
{
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:format];
	NSDate *date = [inputFormatter dateFromString:string];
    
    [inputFormatter release];

	return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format
{
	return [date stringWithFormat:format];
}

+ (NSString *)stringFromDate:(NSDate *)date
{
	return [date string];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime
{
    /*
	 * if the date is in today, display 12-hour time with meridian,
	 * if it is within the last 7 days, display weekday name (Friday)
	 * if within the calendar year, display as Jan 23
	 * else display as Nov 11, 2008
	 */
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
    
	NSDate *today = [NSDate date];
    NSDateComponents *offsetComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
													 fromDate:today];
	
	NSDate *midnight = [calendar dateFromComponents:offsetComponents];
	NSString *displayString = nil;
	
	// comparing against midnight
    NSComparisonResult midnight_result = [date compare:midnight];
	if (midnight_result == NSOrderedDescending) {
		if (prefixed) {
			[displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
		} else {
			[displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
		}
	} else {
		// check if date is within last 7 days
		NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
		[componentsToSubtract setDay:-7];
		NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
		[componentsToSubtract release];
        NSComparisonResult lastweek_result = [date compare:lastweek];
		if (lastweek_result == NSOrderedDescending) {
            if (displayTime) {
                [displayFormatter setDateFormat:@"EEEE h:mm a"];
            } else {
                [displayFormatter setDateFormat:@"EEEE"]; // Tuesday
            }
		} else {
			// check if same calendar year
			NSInteger thisYear = [offsetComponents year];
			
			NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
														   fromDate:date];
			NSInteger thatYear = [dateComponents year];
			if (thatYear >= thisYear) {
                if (displayTime) {
                    [displayFormatter setDateFormat:@"MMM d h:mm a"];
                }
                else {
                    [displayFormatter setDateFormat:@"MMM d"];
                }
			} else {
                if (displayTime) {
                    [displayFormatter setDateFormat:@"MMM d, yyyy h:mm a"];
                }
                else {
                    [displayFormatter setDateFormat:@"MMM d, yyyy"];
                }
			}
		}
		if (prefixed) {
			NSString *dateFormat = [displayFormatter dateFormat];
			NSString *prefix = @"'on' ";
			[displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
		}
	}
	
	// use display formatter to return formatted date string
	displayString = [displayFormatter stringFromDate:date];
    
    [displayFormatter release];
    
	return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed
{
	return [[self class] stringForDisplayFromDate:date prefixed:prefixed alwaysDisplayTime:NO];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date
{
	return [self stringForDisplayFromDate:date prefixed:NO];
}

- (NSString *)stringWithFormat:(NSString *)format
{
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:format];
	NSString *timestamp_str = [outputFormatter stringFromDate:self];
 
	[outputFormatter release];
	return timestamp_str;
}

- (NSString *)string
{
	return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateStyle:dateStyle];
	[outputFormatter setTimeStyle:timeStyle];
	NSString *outputString = [outputFormatter stringFromDate:self];
	[outputFormatter release];
	return outputString;
}

+ (NSString *)dateFormatString
{
	return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString
{
	return @"HH:mm:ss";
}

+ (NSString *)timestampFormatString
{
	return @"yyyy-MM-dd HH:mm:ss";
}

// preserving for compatibility
+ (NSString *)dbFormatString
{
	return [NSDate timestampFormatString];
}

- (NSDateComponents *)dateComponentsWithTimeZone:(NSTimeZone*)timeZone
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	gregorian.timeZone = timeZone;
	return [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSTimeZoneCalendarUnit) fromDate:self];
}

+ (NSDate *)dateWithDateComponents:(NSDateComponents *)components
{	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	gregorian.timeZone = components.timeZone;
	return [gregorian dateFromComponents:components];
}

#pragma mark Same Day

- (BOOL)isSameDay:(NSDate *)anotherDate
{
	return [self isSameDay:anotherDate timeZone:[NSTimeZone defaultTimeZone]];
}

- (BOOL)isSameDay:(NSDate *)anotherDate timeZone:(NSTimeZone *)timeZone
{
	NSCalendar* calendar = [NSCalendar currentCalendar];
	calendar.timeZone = timeZone;
	NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];
	return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

- (BOOL)isSameMonth:(NSDate*)anotherDate
{
    return [self isSameMonth:anotherDate timeZone:[NSTimeZone defaultTimeZone]];
}

- (BOOL)isSameMonth:(NSDate *)anotherDate timeZone:(NSTimeZone *)timeZone
{
	NSCalendar* calendar = [NSCalendar currentCalendar];
	calendar.timeZone = timeZone;
	NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
	NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:anotherDate];
	return ([components1 year] == [components2 year] && [components1 month] == [components2 month]);
}



#pragma mark Is Today

- (BOOL)isToday
{
	return [self isSameDay:[NSDate date]];
}

- (BOOL)isTodayWithTimeZone:(NSTimeZone *)timeZone
{
	return [self isSameDay:[NSDate date] timeZone:timeZone];
}

// 날짜 포함 여부.
- (BOOL)isBetween:(NSDate *)startDate endDate:(NSDate *)endDate
{
    BOOL between = NO;
    
    if (([self compare:startDate] == NSOrderedDescending) && ([self compare:endDate] == NSOrderedAscending))
    {
        between = YES;
    }
    
    return between;
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

// 월의 마지막 날 여부.
- (BOOL)isMonthLastDay
{
    NSDate *monthLastDay = [self endOfMonth];
    
    return [self isSameDay:monthLastDay];
}

@end
