//
//  NSString+LPCategory.h
//  LPLibrary
//
//  Created by Jong Pil Park on 10. 7. 23..
//  Copyright 2010 Lilac Studio. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Helper)

- (void)drawCenteredInRect:(CGRect)rect withFont:(UIFont *)font;
- (CGSize)heightWithFont:(UIFont*)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode;
- (NSString *)stringByUrlEncoding;
- (NSString *)stringByUrlDecoding;
- (NSString *)substringFrom:(NSInteger)a to:(NSInteger)b;
- (NSInteger)indexOf:(NSString *)substring from:(NSInteger)starts;
- (NSString *)trim;
- (BOOL)startsWith:(NSString *)s;
- (BOOL)containsString:(NSString *)aString;
- (NSString *)sha1;
- (NSString *)formatNumber;
- (NSString *)formatPercent;
- (NSString *)formatFloatNumber;
- (NSString *)formatFloatNumberWithPercent;
- (NSString *)formatDoubleNumber;
- (BOOL)isEmpty;
- (NSString *)remainOnlyNumber;
- (NSData *)decodeFromHexidecimal;
- (NSComparisonResult)localizedCaseInsensitiveKoreanCompare:(NSString *)compare;
- (BOOL)isValidIPAddress;

@end
