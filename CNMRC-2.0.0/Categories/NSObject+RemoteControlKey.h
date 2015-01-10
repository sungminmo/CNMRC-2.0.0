//
//  NSObject+RemoteControlKey.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 19..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RemoteControlKey)

// 리모콘의 키 값을 저장한다.
@property (readwrite, copy) NSString *key;

@end
