//
//  CM04.h
//  CNMRC
//
//  Created by lambert on 2014. 4. 21..
//  Copyright (c) 2014년 Jong Pil Park. All rights reserved.
//

#import "CMTRObject.h"

// Request.
@interface CM04Rq : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;

@end

// Response.
@interface CM04 : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;
@property (strong, nonatomic) NSString *result;
@property (strong, nonatomic) NSString *assetID;

@end

// Response(SecondTV 용).
@interface CM041 : CMTRObject

@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *trNo;
@property (strong, nonatomic) NSString *result;
@property (strong, nonatomic) NSString *assetID;
@property (strong, nonatomic) NSString *secondTV;

@end
