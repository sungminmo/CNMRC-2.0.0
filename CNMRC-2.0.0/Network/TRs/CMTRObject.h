//
//  CMTRObject.h
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface CMTRObject : NSObject

@property (strong, nonatomic) NSArray *propertiesLength;
@property (strong, nonatomic) NSArray *propertiesOffset;
@property (assign, nonatomic) int totalPropertyLength;

- (NSMutableArray *)createOffsets;
- (int)totalPropertyLength;
- (int)propertyLength:(int)idx;
- (int)propertyOffset:(int)idx;
- (BOOL)isDecimalSet:(NSString *)string;
- (NSString *)reverseString:(NSString *)string;
- (NSString *)formatStringNumber:(NSString *)value withCipher:(int)cipher;
- (void)validateProperties;

@end
