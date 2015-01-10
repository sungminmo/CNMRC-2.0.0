//
//  CMTRParser.h
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

extern NSString * const CMDataObjectKey;

@interface CMTRParser : NSObject

@property (nonatomic, retain) NSArray *trList;

- (void)debugParsing:(NSString *)theValue withProperty:(NSString *)theProperty;
- (NSMutableArray *)getPropertyList:(NSString *)className;
- (NSMutableArray *)getPropertyAttributes:(NSString *)className;
- (NSData *)splitPacket:(NSData *)data withOffset:(int)offset andLength:(int)length;
- (NSMutableDictionary *)parseData:(NSData *)data withClass:(NSString *)className;

@end
