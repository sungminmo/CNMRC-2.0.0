//
//  CMGenerator.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 6. 25..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMGenerator.h"

@interface CMGenerator ()
+ (NSString *)genParameter:(NSString *)key andValue:(NSString *)value;
@end 

@implementation CMGenerator

+ (NSURL *)genURLWithInterface:(NSString *)interface
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.asp", CNM_OPEN_API_SERVER_URL, interface]];
}

// TODO: UI에서 페이징 처리 결정해야 함!
+ (NSURL *)genURLWithQuery:(NSString *)query
{
    // !!!: query는 UTF-8 인코딩.
    NSDictionary *dict = @{
                                @"key" : NAVER_SEARCH_API_KEY,
                                @"target" : @"webkr",
                                @"query" : [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                @"start" : @"1",
                                @"display" : @"10"
                           };
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", NAVER_SEARCH_API_SERVER_URL, [self genQueryStringWithDictionary:dict]]];
}

+ (NSString *)genParameter:(NSString *)key andValue:(NSString *)value
{
    NSString *element = [NSString stringWithFormat:@"%@=%@&", key, value];
    
    return element;
}

+ (NSString *)genQueryStringWithDictionary:(NSDictionary *)dict
{
    NSMutableString *queryString = [NSMutableString string];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [queryString appendString:[self genParameter:key andValue:obj]];
    }];
    
    return queryString;
}

@end
