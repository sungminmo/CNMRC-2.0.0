//
//  CMBoxService.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 24..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBoxService.h"
#import "NSNetService+Additions.h"

@implementation CMBoxService

+ (id)boxServiceFromNetService:(NSNetService *)netService
{
    return [[CMBoxService alloc] initWithAddresses:[netService addressesAsStrings]
                                              port:[netService port]
                                              name:[netService name]];
}

- (id)initWithAddresses:(NSArray *)addresses port:(NSInteger)port name:(NSString *)name
{
    if ((self = [super init]))
    {
        _addresses = [addresses copy];
        _port = port;
        _name = [name copy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    return [self initWithAddresses:[decoder decodeObjectForKey:@"addresses"]
                              port:[decoder decodeInt32ForKey:@"port"]
                              name:[decoder decodeObjectForKey:@"name"]];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_addresses forKey:@"addresses"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeInt32:_port forKey:@"port"];
}

- (NSComparisonResult)gidCompare:(CMBoxService *)other
{
    NSString *selfName = [self name];
    NSString *otherName = [other name];
    NSComparisonResult result = [selfName caseInsensitiveCompare:otherName];
    
    if (result == NSOrderedSame)
    {
        if ([[self addresses] count] == 0 || [[other addresses] count] == 0)
        {
            return NSOrderedSame;
        }
        NSString *address = [[self addresses] objectAtIndex:0];
        NSString *otherAddress = [[other addresses] objectAtIndex:0];
        return [address caseInsensitiveCompare:otherAddress];
    }
    return result;
}

- (BOOL)isEqualToBoxService:(CMBoxService *)other
{
    return [[self name] isEqual:[other name]]
    && ([self port] == [other port])
    && [[self addresses] isEqual:[other addresses]];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[self class]])
    {
        return NO;
    }
    return [self isEqualToBoxService:other];
}

-(NSUInteger)hash
{
    int prime = 31;
    int result = 1;
    result = prime * result + [[self name] hash];
    result = prime * result + [self port];
    result = prime * result + [[self addresses] hash];
    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"CMBoxService(%@, %@, %d)", [self name], [[self addresses] description], [self port]];
}

@end
