//
//  CMBoxService.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 24..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMBoxService : NSObject <NSCoding>

// NSString 타입의 배열.
@property(readonly, nonatomic) NSArray *addresses;
@property(readonly, nonatomic) NSInteger port;
@property(readonly, nonatomic) NSString *name;

+ (id)boxServiceFromNetService:(NSNetService *)netService;

- (id)initWithAddresses:(NSArray *)addresses port:(NSInteger)port name:(NSString *)name;

/**
 *	'gid()'는 카테고리를 위한 구글의 접두사 이다.
 *  이름으로 비교한다. 그러나 만약 이름이 같으면 IP를 사용한다.
 *
 *	@param other CMBoxService 객체.
 *
 *	@return	NSComparisonResult
 */
- (NSComparisonResult)gidCompare:(CMBoxService *)other;

@end
