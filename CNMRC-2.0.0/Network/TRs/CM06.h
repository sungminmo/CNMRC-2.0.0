//
//  CM06.h
//  CNMRC
//
//  Created by lambert on 2014. 4. 21..
//  Copyright (c) 2014년 Jong Pil Park. All rights reserved.
//

#import "CMTRObject.h"

// Request.
@interface CM06Rq : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;
@property (strong, nonatomic) NSString *clientIP;

@end

// Response.
@interface CM06 : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;
@property (strong, nonatomic) NSString *result;
@property (strong, nonatomic) NSString *tvStatus;
@property (strong, nonatomic) NSString *channelNo;
@property (strong, nonatomic) NSString *sourceID;
@property (strong, nonatomic) NSString *channelName;
@property (strong, nonatomic) NSString *title;

@end
