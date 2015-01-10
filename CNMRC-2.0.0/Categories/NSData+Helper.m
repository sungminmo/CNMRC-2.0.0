//
//  NSData+ NSDataStrings.m
//  SocketClient
//
//  Created by Jong Pil Park on 10. 6. 16..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSData+Helper.h"


@implementation NSData (Helper)

- (NSString *)stringWithHexBytes 
{
	static const char hexdigits[] = "0123456789ABCDEF";
	const size_t numBytes = [self length];
	const unsigned char* bytes = [self bytes];
	char *strbuf = (char *)malloc(numBytes * 2 + 1);
	char *hex = strbuf;
	NSString *hexBytes = nil;
	
	for (int i = 0; i<numBytes; ++i) {
		const unsigned char c = *bytes++;
		*hex++ = hexdigits[(c >> 4) & 0xF];
		*hex++ = hexdigits[(c ) & 0xF];
	}
	*hex = 0;
	hexBytes = [NSString stringWithUTF8String:strbuf];
	free(strbuf);
	return hexBytes;
}

- (NSString *)hexDump
{
    unsigned char *inbuf = (unsigned char *)[self bytes];	
	NSMutableString *stringBuffer = [NSMutableString string];
    NSMutableString *asciiBuffer = [NSMutableString string];
    for (int i = 0; i < [self length]; i++)
    {
        if (i != 0 && i % 16 == 0)
        {
            //[stringBuffer appendString:@"\n"];
            [stringBuffer appendFormat:@"      %@\n", asciiBuffer];
            [asciiBuffer setString:@""];
        }
        
		[stringBuffer appendFormat:@"%02X ", inbuf[i]];
        [asciiBuffer appendFormat:@"%c", inbuf[i]];
    }
	return stringBuffer;
}

- (NSString *)hexString 
{
	NSMutableString *str = [NSMutableString stringWithCapacity:64];
	int length = [self length];
	char *bytes = malloc(sizeof(char) * length);
	
	[self getBytes:bytes length:length];
	
	int i = 0;
	for (; i < length; i++) 
    {
		[str appendFormat:@"%02.2hhx", bytes[i]];
	}
	free(bytes);
	
	return str;
}

@end
