//
//  NSArray+Accessors.m
//  ActiveRecord
//
//  Created by Jong Pil Park on 12. 8. 23..
//  Copyright (c) 2012년 LambertPark. All rights reserved.
//

#import "NSArray+Accessors.h"

@implementation NSArray (Accessors)

@dynamic first;
@dynamic last;

- (id)first
{
    return [self objectAtIndex:0];
}

- (id)last
{
    return [self lastObject];
}

- (void)each:(void (^)(id object))block
{
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)eachWithIndex:(void (^)(id object, int index))block
{
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx);
    }];
}

@end
