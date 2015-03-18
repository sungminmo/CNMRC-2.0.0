//
//  CMTRGenerator.m
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTRGenerator.h"
#import "CM01.h"
#import "CM02.h"
#import "CM03.h"
#import "CM04.h"
#import "CM05.h"
#import "CM06.h"

@implementation CMTRGenerator

- (id)init
{
    self = [super init];
    if (self)
    {
    
    }
    
    return self;
}

/**
 !!!: NSData로 캐스팅할 때 인코딩 타입 확인.
 
 1. CP949: CFStringConvertEncodingToNSStringEncoding(0x0422)
 2. EUC-KR: -2147481280
 3. NSASCIIStringEncoding
 4. NSUTF8StringEncoding
 */
// 전문 디버그.
- (void)debugTR:(NSString *)tr
{
    NSLog(@"\n-----------------------------------------------------------------------\
          \nData length: [%d]\
          \n-----------------------------------------------------------------------\
          \n%@\
          \n-----------------------------------------------------------------------", [tr lengthOfBytesUsingEncoding:NSUTF8StringEncoding], tr);
}

// 문자열 뒤집기.
- (NSString *)reverseString:(NSString *)string
{
	NSMutableString *reversedString;
	int len = [string length];
	reversedString = [NSMutableString stringWithCapacity:len];
	
	while (len > 0)
		[reversedString appendString:[NSString stringWithFormat:@"%C", [string characterAtIndex:--len]]];
	
	return reversedString;
}

// 데이터 길이만큼 앞에서 "0"을 채운 숫자로 구성된 문자열.
- (NSString *)formatStringNumber:(int)num withCipher:(int)cipher
{
	NSString *stringDataLength = [NSString stringWithFormat:@"%d", num];
	stringDataLength = [self reverseString:stringDataLength];
    int repeatNum = cipher - [stringDataLength length];
	
	for (int i = 0; i < repeatNum; i++)
    {
		stringDataLength = [stringDataLength stringByAppendingString:@"0"];
	}
    
	return [self reverseString:stringDataLength];
}

// 공백 추가.
- (NSString *)addWhiteSpaceCharterSetWithCount:(int)count
{
	NSString *whiteSpace = [[NSString alloc] init];
	
	for (int i = 0; i < count; ++i)
    {
		whiteSpace = [whiteSpace stringByAppendingString:@" "];
	}
	
	return whiteSpace;
}

// 문자 "0" 추가.
- (NSString *)addStringZeroWithCount:(int)count
{
	NSString *stringZero = [[NSString alloc] init];
	
	for (int i = 0; i < count; ++i)
    {
		stringZero = [stringZero stringByAppendingString:@"0"];
	}
	
	return stringZero;
}

// 널 처리용 문자.
- (NSString *)addStringNullWithCount:(int)count
{
	NSString *stringNull = [[NSString alloc] init];
	
	for (int i = 0; i < count; ++i)
    {
		stringNull = [stringNull stringByAppendingString:@" "];
	}
	
	return stringNull;
}

// 전문 데이터의 길이.
- (int)dataLength:(CMTRObject *)tr
{
    return [[tr description] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - 전문 생성.

- (NSString *)genCM01WithDate:(NSString *)date assetID:(NSString *)assetID
{
    CM01Rq *rq = [[CM01Rq alloc] init];
    rq.date = date;
    rq.assetID = assetID;
    
    // 프라퍼티 값 검증 후 길이 포맷팅.
    [rq validateProperties];
    
    // 전문.
    NSString *tr = [rq description];
    
	// 디버그.
	[self debugTR:tr];
    
    return tr;
}

- (NSString *)genCM02WithAssetID:(NSString *)assetID
{
    CM02Rq *rq = [[CM02Rq alloc] init];
    rq.assetID = assetID;
    
    // 프라퍼티 값 검증 후 길이 포맷팅.
    [rq validateProperties];
    
    // 전문.
    NSString *tr = [rq description];
    
	// 디버그.
	[self debugTR:tr];
    
    return tr;
}

- (NSString *)genCM03
{
    CM03Rq *rq = [[CM03Rq alloc] init];
    
    // 프라퍼티 값 검증 후 길이 포맷팅.
    [rq validateProperties];
    
    // 전문.
    NSString *tr = [rq description];
    
	// 디버그.
	[self debugTR:tr];
    
    return tr;
}

- (NSString *)genCM04
{
    CM04Rq *rq = [[CM04Rq alloc] init];
    
    // 프라퍼티 값 검증 후 길이 포맷팅.
    [rq validateProperties];
    
    // 전문.
    NSString *tr = [rq description];
    
	// 디버그.
	[self debugTR:tr];
    
    return tr;
}

- (NSString *)genCM05
{
    CM05Rq *rq = [[CM05Rq alloc] init];
    
    // 프라퍼티 값 검증 후 길이 포맷팅.
    [rq validateProperties];
    
    // 전문.
    NSString *tr = [rq description];
    
	// 디버그.
	[self debugTR:tr];
    
    return tr;
}

- (NSString *)genCM06WithClientIP:(NSString *)clientIP
{
    CM06Rq *rq = [[CM06Rq alloc] init];
    rq.clientIP = clientIP;
    
    // 프라퍼티 값 검증 후 길이 포맷팅.
    [rq validateProperties];
    
    // 전문.
    NSString *tr = [rq description];
    
	// 디버그.
	[self debugTR:tr];
    
    return tr;
}

@end
