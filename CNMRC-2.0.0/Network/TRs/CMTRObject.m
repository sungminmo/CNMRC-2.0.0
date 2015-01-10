//
//  CMTRObject.m
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTRObject.h"

@implementation CMTRObject

- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

// 옵셋 목록 생성 및 프라퍼티의 길이 합계 게산.
- (NSMutableArray *)createOffsets
{
    NSMutableArray *offsetList = [NSMutableArray array];
    
    int sum = 0;
    _totalPropertyLength = 0;
    for (int i = 0; i < [_propertiesLength count]; i++)
    {
        if (i == 0)
        {
            [offsetList addObject:[NSNumber numberWithInt:sum]];
        }
        else
        {
            [offsetList addObject:[NSNumber numberWithInt:sum]];
        }
        
        sum = sum + [[_propertiesLength objectAtIndex:i] intValue];
        _totalPropertyLength += [[_propertiesLength objectAtIndex:i] intValue];
    }
    
    return offsetList;
}

// 프라퍼티 길이.
- (int)propertyLength:(int)idx
{
	return [[_propertiesLength objectAtIndex:idx] intValue];
}

// 프라퍼티의 총 길이.
- (int)totalPropertyLength
{
    return _totalPropertyLength;
}

// 프라퍼티 옵셋.
- (int)propertyOffset:(int)idx
{
	return [[_propertiesOffset objectAtIndex:idx] intValue];
}

// 문자열이 숫자로만 구성되어 있는지 검사.
- (BOOL)isDecimalSet:(NSString *)string
{
    NSCharacterSet *decimalSet = [NSCharacterSet decimalDigitCharacterSet];
    
    if (!([string rangeOfCharacterFromSet:decimalSet].location == NSNotFound))
    {
        return YES;
    }
    
    return NO;
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

// 데이터 길이를 문자열로 포맷팅.
- (NSString *)formatStringNumber:(NSString *)value withCipher:(int)cipher
{
	NSString *stringDataLength = [self reverseString:value];
    int repeatNum = cipher - [stringDataLength length];
	
	for (int i = 0; i < repeatNum; i++)
    {
		stringDataLength = [stringDataLength stringByAppendingString:@"0"];
	}
    
	return [self reverseString:stringDataLength];
}


// TODO: NSInteger일 경우 처리해야 함.(만약 있다면, 현재 없음).
// !!!: 현재는 길이 체크만 한다. 만약 값의 내용까지 검증하려면 서브클래스에서 오버라이드 하면 된다.
// 프라퍼티 길이 검증.
- (void)validateProperties
{
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);

    for (int index = 0; index < outCount; index++)
    {
		objc_property_t property = properties[index];
        NSString *key = [NSString stringWithFormat:@"%s", property_getName(property)];
		NSString *currentVal = [self valueForKey:key];
        
        int currentLength = [currentVal length];
        BOOL isDecimalSet = [self isDecimalSet:currentVal];
        int maxLength = [self propertyLength:(index)];
        
        if (currentLength < maxLength)
        {
            int subtraction = maxLength - currentLength;
            for (int i = 0; i < subtraction; i++)
            {
                // assetID는 뒤로 공백을 채운다.
                if ([key isEqualToString:@"assetID"])
                {
                    currentVal = [currentVal stringByAppendingString:@" "];
                }
                else
                {
                    if (isDecimalSet)
                    {
                        // 값이 숫자로만 구성되어 있을 경우: 부족한 길이만큼 앞에 "0"을 추가.
                        currentVal = [self formatStringNumber:currentVal withCipher:maxLength];
                    }
                }
                
            }
        }
        else if (currentLength > maxLength)
        {
            currentVal = [currentVal substringToIndex:maxLength];
        }
        
		[self setValue:currentVal forKey:key];
    }
	free(properties);
}

// TODO: NSInteger일 경우 처리해야 함.(만약 있다면, 현재 없음).
// 프라터티의 값을 문자열로.
- (NSString *)description
{
    NSString *desc = [[NSString alloc] init];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (int i = 0; i < outCount; i++)
    {
		objc_property_t property = properties[i];
		desc = [desc stringByAppendingString:[self valueForKey:[NSString stringWithFormat:@"%s", property_getName(property)]]];
		
    }
	free(properties);
    
	return desc;
}

@end
