//
//  CM02.m
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CM02.h"

@implementation CM02Rq

- (id)init
{
    self = [super init];
    if (self)
    {
        // 프라퍼티의 길이: 프라퍼티의 갯수와 일치해야 함!
        self.propertiesLength = @[@4, @4, @100];
        
        // 옵셋 생성.
        self.propertiesOffset = [self createOffsets];
        
        // 기본값 설정.
        self.size = [NSString stringWithFormat:@"%d", self.totalPropertyLength];
        self.trNo = @"CM02";
    }
    
    return self;
}

@end

@implementation CM02

- (id)init
{
    self = [super init];
    if (self)
    {
        // 프라퍼티의 길이: 프라퍼티의 갯수와 일치해야 함!
        self.propertiesLength = @[@4, @4, @1];
        
        // 옵셋 생성.
        self.propertiesOffset = [self createOffsets];
    }
    
    return self;
}

@end
