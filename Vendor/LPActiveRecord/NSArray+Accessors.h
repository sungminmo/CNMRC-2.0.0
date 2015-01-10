//
//  NSArray+Accessors.h
//  ActiveRecord
//
//  Created by Jong Pil Park on 12. 8. 23..
//  Copyright (c) 2012년 LambertPark. All rights reserved.
//

/**
 LPActiveRecord를 위한 NSArray의 카테고리 이다.
 */

#import <Foundation/Foundation.h>

@interface NSArray (Accessors)

/**
 첫 번째 객체.
 */
@property (readonly) id first;

/**
 마지막 객체.
 */
@property (readonly) id last;

/**
 각 객체.
 
 @param block 블럭.
 */
- (void)each:(void (^)(id object))block;

/**
 인덱스를 기준으로한 각 객체.
 
 @param block 블럭.
 */
- (void)eachWithIndex:(void (^)(id object, int index))block;

@end
