//
//  CMTRParser.m
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTRParser.h"
#import "CM01.h"
#import "CM02.h"
#import "CM03.h"

NSString * const CMDataObjectKey = @"DataObject";

@implementation CMTRParser

- (id)init
{
    self = [super init];
    if (self)
    {
        // TR 목록 설정.
        self.trList = @[@"CM01", @"CM02", @"CM03"];
    }
    
    return self;
}

// 파싱 디버그.
- (void)debugParsing:(NSString *)theValue withProperty:(NSString *)theProperty
{
	Debug(@"[debug] Data parsing: %@ -> %@", theProperty, theValue);
}


// 클래스의 디클레어드 프라퍼티 목록.
- (NSMutableArray *)getPropertyList:(NSString *)className
{
	unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([NSClassFromString(className) class], &outCount);
	NSMutableArray *propertyArray = [[NSMutableArray alloc] init];
	
	//while (outCount--)
    for (int i = 0; i < outCount; i++)
    {
		objc_property_t property = properties[i];
		[propertyArray addObject:[NSString stringWithFormat:@"%s", property_getName(property)]];
		
		// 디버그용.
		//fprintf(stdout, "%s %s\n", property_getName(property), property_getAttributes(property));
    }
	free(properties);
    
	return propertyArray;
}

// 클래스의 디클레어드 프라퍼티의 어트리뷰트 목록.
- (NSMutableArray *)getPropertyAttributes:(NSString *)className
{
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([NSClassFromString(className) class], &outCount);
	NSMutableArray *attributeArray = [[NSMutableArray alloc] init];
	
	//while (outCount--)
    for (int i = 0; i < outCount; i++)
    {
		objc_property_t property = properties[i];
        
        NSString *attribute = [NSString stringWithFormat:@"%s", property_getAttributes(property)];
        attribute = [[attribute componentsSeparatedByString:@","] objectAtIndex:0];
        attribute = [attribute stringByReplacingOccurrencesOfString:@"T" withString:@""];
        attribute = [attribute stringByReplacingOccurrencesOfString:@"@" withString:@""];
        attribute = [attribute stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
		[attributeArray addObject:attribute];
    }
	free(properties);
    
	return attributeArray;
}

// 패킷(문자열) 분리.
- (NSData *)splitPacket:(NSData *)data withOffset:(int)offset andLength:(int)length
{
	return [data subdataWithRange:NSMakeRange(offset, length)];
}

// 데이터 파싱.
- (NSMutableDictionary *)parseData:(NSData *)data withClass:(NSString *)className
{
    // 클래스의 프라퍼티 목록.
    NSMutableArray *properties = [self getPropertyList:className];
    
    // TR 객체.
	id obj = [[NSClassFromString(className) alloc] init];
    
    // 데이터 매핑.
	for (int i = 0; i < [properties count]; i++)
    {
		NSString *key = [properties objectAtIndex:i];
        NSData *splitedData = [self splitPacket:data withOffset:[obj propertyOffset:i] andLength:[obj propertyLength:i]];
		NSString *val = [[NSString alloc] initWithData:splitedData encoding:NSUTF8StringEncoding];
        
		// 클래스의 인스턴스 변수에 값 입력.
		[obj setValue:val forKey:key];
		
		// 디버그.
		[self debugParsing:val withProperty:key];
	}
    
    // 파싱 데이터 전달을 위해 사전에 추가.
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (obj != nil)
    {
        [dict setObject:obj forKey:CMDataObjectKey];
    }
	
	return dict;
}


@end
