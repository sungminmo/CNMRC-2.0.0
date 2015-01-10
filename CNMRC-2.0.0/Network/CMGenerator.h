//
//  CMGenerator.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 6. 25..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @name HTTP 통신을 위한 URL(GET 방식)을 생성한다.
 */

@interface CMGenerator : NSObject

/**
 C&M SMApplicationServer의 openAPI를 사용하기 위한 NSURL 타입의 URL 반환한다.
 
 @param interface C&M SMApplicationServer의 openAPI의 인터페이스.
 @return NSURL 타입의 URL 반환.
 */
+ (NSURL *)genURLWithInterface:(NSString *)interface;

/**
 네이버의 검색API를 사용하기 위한 NSURL 타입의 URL 반환한다.
 
 @param query 검색 키워드.
 @return NSURL 타입의 URL 반환.
 */
+ (NSURL *)genURLWithQuery:(NSString *)query;

/**
 NSString 타입의 쿼리스트링 반환한다.
 
 @param dict 쿼리스트링을 생성할 파라미터 목록.
 @return NSString 타입의 쿼리스트링 반환.
 */
+ (NSString *)genQueryStringWithDictionary:(NSDictionary *)dict;

@end
