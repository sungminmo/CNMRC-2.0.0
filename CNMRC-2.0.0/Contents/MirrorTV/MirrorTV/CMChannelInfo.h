//
//  CMChannelInfo.h
//  CNMRC
//
//  Created by lambert on 2014. 4. 22..
//  Copyright (c) 2014년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMChannelInfo : NSObject

// 16진수(소문자로 통일해 사용한다.).
@property (strong, nonatomic) NSString *sourceID;

@property (strong, nonatomic) NSString *channelNo;
@property (strong, nonatomic) NSString *channelName;
@property (strong, nonatomic) NSString *programTitle;

@end
