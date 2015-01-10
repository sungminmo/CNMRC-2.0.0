//
//  CM05.h
//  CNMRC
//
//  Created by lambert on 2014. 4. 21..
//  Copyright (c) 2014년 Jong Pil Park. All rights reserved.
//

#import "CMTRObject.h"

// Request.
@interface CM05Rq : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;

@end

// Response.
@interface CM05 : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;
@property (strong, nonatomic) NSString *result;

@end
