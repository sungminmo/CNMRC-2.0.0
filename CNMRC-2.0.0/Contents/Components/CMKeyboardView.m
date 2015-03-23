//
//  CMKeyboardView.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 20..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMKeyboardView.h"

@implementation CMKeyboardView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

#pragma mark  - 퍼블릭 메서드 -

- (IBAction)keyAction:(id)sender
{
    DDLogDebug(@"선택된 버튼: %@", @([(UIButton *)sender tag]));
    if (self.delegate && [self.delegate respondsToSelector:@selector(pressedKey:)])
    {
        [self.delegate pressedKey:sender];
    }
}

- (IBAction)changeKeyboardTypeAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == KEY_TAG_KO_AND_EN)
    {
        if (self.keyboardType == CMKeyboardTypeKorean)
        {
            [self changeKeyboard:CMKeyboardTypeEnglish];
        }
        else
        {
            [self changeKeyboard:CMKeyboardTypeKorean];
        }
    }
}

- (IBAction)changeNumberKeyboardAction:(id)sender
{
    if (self.keyboardType != CMKeyboardTypeNumberAndSymbol)
    {
        [self changeKeyboard:CMKeyboardTypeNumberAndSymbol];
    }
    else
    {
        [self changeKeyboard:CMKeyboardTypeKorean];
    }
}

#pragma mark - 프라이빗 메서드 -

- (void)setup
{
    // 키보드 타입 초기화.
    self.keyboardType = CMKeyboardTypeKorean;
    
    // 한글 키.
    self.koKeyList = @[@"ㅂ", @"ㅈ", @"ㄷ", @"ㄱ", @"ㅅ", @"ㅛ", @"ㅕ", @"ㅑ", @"ㅐ", @"ㅔ", @"ㅁ", @"ㄴ", @"ㅇ", @"ㄹ", @"ㅎ", @"ㅗ", @"ㅓ", @"ㅏ", @"ㅣ", @"ㅋ", @"ㅌ", @"ㅊ", @"ㅍ", @"ㅠ", @"ㅜ", @"ㅡ"];
    
    // 영문 키.
    self.enKeyList = @[@"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"Z", @"X", @"C", @"V", @"B", @"N", @"M"];
    
    // 숮자 키.
    self.numberKeyList = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", @"&", @"/", @":", @";", @"(", @")", @"-", @"+", @"$", @",", @"?", @"!", @"`", @"\"", @"*", @"#", @"~"];
}

- (void)changeKeyboard:(CMKeyboardType)type
{
    switch (type)
    {
        case CMKeyboardTypeKorean:
        {
            self.keyboardType = CMKeyboardTypeKorean;
            
            for (UIButton *keyButton in self.keyList)
            {
                if (keyButton.tag != 26)
                {
                    NSString *keyTitle = self.koKeyList[keyButton.tag];
                    [keyButton setTitle:keyTitle forState:UIControlStateNormal];
                }
            }
        }
            break;
            
        case CMKeyboardTypeEnglish:
        {
            self.keyboardType = CMKeyboardTypeEnglish;
            
            for (UIButton *keyButton in self.keyList)
            {
                if (keyButton.tag != 26)
                {
                    NSString *keyTitle = self.enKeyList[keyButton.tag];
                    [keyButton setTitle:keyTitle forState:UIControlStateNormal];
                    [keyButton setNeedsDisplay];
                }
            }
        }
            break;
            
        case CMKeyboardTypeNumberAndSymbol:
        {
            self.keyboardType = CMKeyboardTypeNumberAndSymbol;
            
            for (UIButton *keyButton in self.keyList)
            {
                if (keyButton.tag == 26)
                {
                    keyButton.hidden = NO;
                }
                
                NSString *keyTitle = self.numberKeyList[keyButton.tag];
                [keyButton setTitle:keyTitle forState:UIControlStateNormal];
                [keyButton setNeedsDisplay];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
