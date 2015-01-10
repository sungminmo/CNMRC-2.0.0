//
//  CM03.m
//  CNMRC
//
//  Created by lambert on 2013. 11. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CM03.h"

@implementation CM03Rq

- (id)init
{
    self = [super init];
    if (self)
    {
        // 프라퍼티의 길이: 프라퍼티의 갯수와 일치해야 함!
        self.propertiesLength = @[@4, @4];
        
        // 옵셋 생성.
        self.propertiesOffset = [self createOffsets];
        
        // 기본값 설정.
        self.size = [NSString stringWithFormat:@"%d", self.totalPropertyLength];
        self.trNo = @"CM03";
    }
    
    return self;
}

@end

@implementation CM03

- (id)init
{
    self = [super init];
    if (self)
    {
        // 프라퍼티의 길이: 프라퍼티의 갯수와 일치해야 함!
        self.propertiesLength = @[@4, @4, @1, @1, @3, @50, @100, @200];
        
        // 옵셋 생성.
        self.propertiesOffset = [self createOffsets];
    }
    
    return self;
}

@end
