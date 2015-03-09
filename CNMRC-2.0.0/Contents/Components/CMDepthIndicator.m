//
//  CMDepthIndicator.m
//  CNMRC
//
//  Created by lambert on 2013. 12. 3..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMDepthIndicator.h"

#define BOX_WIDTH 9.0
#define BOX_PADDING 5.0
#define MAX_DEPTH 6

@implementation CMDepthIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 화면 설정.
        [self setupLayout];
    }
    return self;
}

// TODO: 컬러 추가 할 것!
// 인디케이터는 4단계로 표시한다.
- (void)setupLayout
{
    CGFloat boxPadding = 0;
    switch ([LPPhoneVersion deviceSize]) {
        case iPhone55inch:
            boxPadding = 94;
            break;
            
        case iPhone47inch:
            boxPadding = 55;
            break;
            
        default:
            boxPadding = 0;
            break;
    }
    
    for (int i = 0; i < MAX_DEPTH; i++)
    {
        UIColor *color = nil;
        switch (i)
        {
            case 0:
                color = UIColorFromRGB(0x715a9f);
                break;
                
            case 1:
                color = UIColorFromRGB(0x715a9f);
                break;
                
            case 2:
                color = UIColorFromRGB(0x715a9f);
                break;
                
            case 3:
                color = UIColorFromRGB(0x856bb8);
                break;
                
            case 4:
                color = UIColorFromRGB(0x997bd5);
                break;
                
            case 5:
                color = UIColorFromRGB(0xb793ff);
                break;
                
            default:
                break;
        }
        
        UIView *box = [[UIView alloc] initWithFrame:CGRectMake(boxPadding + (BOX_PADDING + BOX_WIDTH) * i, 0.0, BOX_WIDTH, BOX_WIDTH)];
        box.tag = MAX_DEPTH - i;
        box.backgroundColor = color;
        box.hidden = YES;
        [self addSubview:box];
    }
}

- (void)hideIndicator
{
    for (int i = 1; i <= MAX_DEPTH; i++)
    {
        [self viewWithTag:i].hidden = YES;
    }
}

- (void)showIndicator:(NSInteger)depth
{
    // 우선 전체를 감춘다.
    [self hideIndicator];
    
    [self viewWithTag:depth].hidden = NO;
    
    if (depth > 1)
    {
        for (int i = 1; i < depth; i++)
        {
            [self viewWithTag:i].hidden = NO;
        }
    }
}

@end
