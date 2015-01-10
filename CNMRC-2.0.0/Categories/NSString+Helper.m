//
//  NSString+LPCategory.m
//  LPLibrary
//
//  Created by Jong Pil Park on 10. 7. 23..
//  Copyright 2010 Lilac Studio. All rights reserved.
//

#import "NSString+Helper.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSData+Helper.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#include <arpa/inet.h>

@implementation NSString (Helper)

- (void)drawCenteredInRect:(CGRect)rect withFont:(UIFont *)font 
{
    CGSize size = [self sizeWithFont:font];
    
    CGRect textBounds = CGRectMake(rect.origin.x + (rect.size.width - size.width) / 2,
                                   rect.origin.y + (rect.size.height - size.height) / 2,
                                   size.width, size.height);
    [self drawInRect:textBounds withFont:font];    
}

- (CGSize)heightWithFont:(UIFont*)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode 
{
	[withFont retain];
	CGSize suggestedSize = [self sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	[withFont release];
	
	return suggestedSize;
}

// URL 인코딩.
- (NSString *)stringByUrlEncoding 
{
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8) autorelease];	
}

// URL 디코딩.
- (NSString *)stringByUrlDecoding 
{
	return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// 서브스트링.
- (NSString *)substringFrom:(NSInteger)a to:(NSInteger)b 
{
	NSRange r;
	r.location = a;
	r.length = b - a;
	return [self substringWithRange:r];
}

- (NSInteger)indexOf:(NSString *)substring from:(NSInteger)starts 
{
	NSRange r;
	r.location = starts;
	r.length = [self length] - r.location;
	
	NSRange index = [self rangeOfString:substring options:NSLiteralSearch range:r];
	if (index.location == NSNotFound) 
    {
		return -1;
	}
	return index.location + index.length;
}

// 트림.
- (NSString *)trim 
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// 시작 여부.
- (BOOL)startsWith:(NSString *)s 
{
	if([self length] < [s length]) return NO;
	return [s isEqualToString:[self substringFrom:0 to:[s length]]];
}

// 포함 여부.
- (BOOL)containsString:(NSString *)aString
{
	NSRange range = [[self lowercaseString] rangeOfString:[aString lowercaseString]];
	return range.location != NSNotFound;
}

// SHA1.
- (NSString *)sha1 
{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	CC_SHA1(data.bytes, data.length, digest);
	NSData *d = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
	return [d hexString];
}

// 숫자 포맷팅(콤마).
- (NSString *)formatNumber
{
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];  
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithLongLong:[self longLongValue]]];
    
    return formattedOutput;
}

// 실수형 포맷팅(콤마).
- (NSString *)formatDoubleNumber
{
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];  
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithDouble:[self doubleValue]]];
    
    return formattedOutput;
}

// 퍼센트 포맷(콤마 처리됨).
- (NSString *)formatPercent
{
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];  
	[formatter setNumberStyle:NSNumberFormatterPercentStyle];
	NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithLongLong:[self longLongValue]]];
    
    return formattedOutput;
}

// 소숫점 포맷 유지(스트링 데이터, 예: 00000017.34 > 17.34).
- (NSString *)formatFloatNumber
{    
    return [NSString stringWithFormat:@"%.2f", [self floatValue]];
}

// 소숫점 포맷 유지(스트링 데이터, 예: 00000017.34 > 17.34%).
- (NSString *)formatFloatNumberWithPercent
{
    return [NSString stringWithFormat:@"%.2f%%", [self floatValue]];
}

// 빈 문자열 여부.
- (BOOL)isEmpty
{
    if ((NSNull *)self == [NSNull null]) 
    {
        return YES;
    }
    else if (self == nil) 
    {
        return YES;
    } 
    else if ([self length] == 0) 
    {
        return YES;
    } 
    else 
    {
        self = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([self length] == 0) 
        {
            return YES;
        }
    }
    
    return NO;
}

// 입력된 문자열 중 오직 숫자만 반환.
- (NSString *)remainOnlyNumber
{    
    return [[self componentsSeparatedByCharactersInSet:
             [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] 
            componentsJoinedByString:@""];
}

// strToChar.
unsigned char strToChar (char a, char b)
{
    char encoder[3] = {'\0','\0','\0'};
    encoder[0] = a;
    encoder[1] = b;
    return (char) strtol(encoder,NULL,16);
}

// cahr > NSData.
- (NSData *)decodeFromHexidecimal;
{
    const char *bytes = [self cStringUsingEncoding: NSUTF8StringEncoding];
    NSUInteger length = strlen(bytes);
    unsigned char *r = (unsigned char *) malloc(length / 2 + 1);
    unsigned char *index = r;
    
    while ((*bytes) && (*(bytes +1))) 
    {
        *index = strToChar(*bytes, *(bytes +1));
        index++;
        bytes+=2;
    }
    *index = '\0';
    
    NSData *result = [NSData dataWithBytes:r length:length / 2];
    free(r);
    
    return result;
}

// 기본 localizedCaseInsensitiveCompare는 숫자, 영문(대소무시), 한글 순 정렬
// 한글 > 영문(대소구분 없음) > 숫자 > $
// 그외 특수문자는 전부 무시한채 인덱싱
// $는 예외
// self 가 @"ㄱ" 보다 작고 (한글이 아니고) , compare 가 @"ㄱ"보다 같거나 클때 - 무조건 크다
// 비교하면 -1 0 1 이 작다, 같다, 크다 순이므로 +1 을 하면 한글일때 YES 아니면 NO 가 된다.
// self 가 한글이고 compare 가 한글이 아닐때 무조건 작다인 조건과 
// self 가 글자(한/영)이 아니고 compare가 글자(한/영)일떄 무조건 크다인 조건을 반영다.
- (NSComparisonResult)localizedCaseInsensitiveKoreanCompare:(NSString *)compare
{
	NSString *left = [NSString stringWithFormat:@"%@%@", 
                      [self localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" : 
					  !([self localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" : 
					  @"1", self];
	NSString *right = [NSString stringWithFormat:@"%@%@",
					   [compare localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" : 
					   !([compare localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" : 
					   @"1", compare];
    
	return [left localizedCaseInsensitiveCompare:right];
}

// IP 검증.
- (BOOL)isValidIPAddress
{
    const char *utf8 = [self UTF8String];
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    if (success != 1)
    {
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    
    return (success == 1 ? TRUE : FALSE);
}

@end
