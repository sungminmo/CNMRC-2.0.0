//
//  UIDevice+Hardware.m
//  ShinhanBank
//
//  Created by Jong Pil Park on 12. 9. 21..
//  Copyright (c) 2012년 LambertPark. All rights reserved.
//

#import "UIDevice+Hardware.h"
#import <sys/sysctl.h>

@implementation UIDevice (Hardware)

- (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *)platformString
{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

- (BOOL)hasRetinaDisplay
{
    NSString *platform = [self platform];
    BOOL retVal = YES;
    if ([platform isEqualToString:@"iPhone1,1"])
    {
        retVal = NO;
    }
    else
        if ([platform isEqualToString:@"iPhone1,2"])    retVal = NO;
        else
            if ([platform isEqualToString:@"iPhone2,1"])    retVal = NO;
            else
                if ([platform isEqualToString:@"iPod1,1"])      retVal = NO;
                else
                    if ([platform isEqualToString:@"iPod2,1"])      retVal = NO;
                    else
                        if ([platform isEqualToString:@"iPod3,1"])      retVal = NO;
    return retVal;
}

- (BOOL)hasMultitasking
{
    if ([self respondsToSelector:@selector(isMultitaskingSupported)])
    {
        return [self isMultitaskingSupported];
    }
    return NO;
}

- (BOOL)isiPhoneFive
{
    NSString *platform = [self platform];
    NSLog(@"Current platform: %@", platform);

    if ([platform isEqualToString:@"iPhone5,1"] ||
        [platform isEqualToString:@"iPhone5,2"] ||
        [platform isEqualToString:@"iPhone5,4"] ||
        [platform isEqualToString:@"iPhone6,2"] ||
        [platform isEqualToString:@"x86_64"] ||     // 4인치 UI 적용.
        [platform isEqualToString:@"iPod5,1"])
    {
        return YES;
    }
    
    return NO;
}

@end
