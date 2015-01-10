//
//  NSObject+RemoteControlKey.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 19..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "NSObject+RemoteControlKey.h"
#import <objc/runtime.h>

@implementation NSObject (RemoteControlKey)

static char storedKey;

- (NSString *)key
{
     return objc_getAssociatedObject(self, &storedKey);
}

- (void)setKey:(NSString *)key
{
    objc_setAssociatedObject(self, &storedKey, key, OBJC_ASSOCIATION_COPY);
}

@end
