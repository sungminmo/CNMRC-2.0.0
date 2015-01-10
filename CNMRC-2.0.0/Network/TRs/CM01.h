//
//  CM01.h
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTRObject.h"

// Request.
@interface CM01Rq : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *assetID;

@end

// Response.
@interface CM01 : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;
@property (strong, nonatomic) NSString *result;

@end
