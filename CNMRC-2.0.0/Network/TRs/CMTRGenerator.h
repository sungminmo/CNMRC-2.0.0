//
//  CMTRGenerator.h
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TR_NO_CM01 @"CM01"
#define TR_NO_CM02 @"CM02"
#define TR_NO_CM03 @"CM03"
#define TR_NO_CM04 @"CM04"
#define TR_NO_CM05 @"CM05"
#define TR_NO_CM06 @"CM06"
#define CMDataObject @"DataObject"

@class CMTRObject;

@interface CMTRGenerator : NSObject

- (void)debugTR:(NSString *)tr;
- (NSString *)reverseString:(NSString *)string;
- (NSString *)formatStringNumber:(int)num withCipher:(int)cipher;
- (NSString *)addWhiteSpaceCharterSetWithCount:(int)count;
- (NSString *)addStringZeroWithCount:(int)count;
- (NSString *)addStringNullWithCount:(int)count;
- (int)dataLength:(CMTRObject *)tr;

// 전문 생성.
- (NSString *)genCM01WithDate:(NSString *)date assetID:(NSString *)assetID;
- (NSString *)genCM02WithAssetID:(NSString *)assetID;
- (NSString *)genCM03;
- (NSString *)genCM04;
- (NSString *)genCM05;
- (NSString *)genCM06WithClientIP:(NSString *)clientIP;

@end
