//
//  CM03.h
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTRObject.h"

// Request.
@interface CM03Rq : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;

@end

// Response.
@interface CM03 : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;
@property (strong, nonatomic) NSString *result;
@property (strong, nonatomic) NSString *tvStatus;
@property (strong, nonatomic) NSString *channelNo;
@property (strong, nonatomic) NSString *channelName;
@property (strong, nonatomic) NSString *assetID;
@property (strong, nonatomic) NSString *title;

@end
