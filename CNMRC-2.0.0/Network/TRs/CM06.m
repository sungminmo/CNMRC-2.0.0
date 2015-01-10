//
//  CM06.m
//  CNMRC
//
//  Created by lambert on 2014. 4. 21..
//  Copyright (c) 2014년 Jong Pil Park. All rights reserved.
//

#import "CM06.h"

@implementation CM06Rq

- (id)init
{
    self = [super init];
    if (self)
    {
        // 프라퍼티의 길이: 프라퍼티의 갯수와 일치해야 함!
        self.propertiesLength = @[@4, @4, @20];
        
        // 옵셋 생성.
        self.propertiesOffset = [self createOffsets];
        
        // 기본값 설정.
        self.size = [NSString stringWithFormat:@"%d", self.totalPropertyLength];
        self.trNo = @"CM06";
    }
    
    return self;
}

@end

@implementation CM06

- (id)init
{
    self = [super init];
    if (self)
    {
        // 프라퍼티의 길이: 프라퍼티의 갯수와 일치해야 함!
        self.propertiesLength = @[@4, @4, @1, @1, @3, @4, @50, @200];
        
        // 옵셋 생성.
        self.propertiesOffset = [self createOffsets];
    }
    
    return self;
}

@end
