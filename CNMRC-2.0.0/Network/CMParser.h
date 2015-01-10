//
//  CMParser.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 6. 25..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

#define ITERATE_ELEMENT_KEY @"item"
#define XML_VALUE_KEY @"value"

/**
 @name 통신 전문 포맷 중 XML을 파싱한다.
 */

@interface CMParser : NSObject

/**
 TBXML 파서로 파싱된 XML을 NSMutableDictionary 타입으로 변환한다.
 
 @param element TBXML의 TEXMLElement 타입.
 @return NSMutableDictionary 반환.
 @see TBXML 파서에 관해서는 다음 (https://github.com/71squared/TBXML)을 참고하라.
 */
+ (NSMutableDictionary *)dictionaryWithXMLNode:(TBXMLElement *)element;

/**
 NSData 타입의 XML을 NSMutableDictionary 타입으로 변환한다.
 
 @param data NSData 타입.
 @return NSMutableDictionary 반환.
 */
+ (NSMutableDictionary *)dictionaryWithXMLData:(NSData *)data;

@end
