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
        self.tildeKey.hidden = YES;
        self.shiftKey.hidden = NO;
        
        if (self.keyboardType == CMKeyboardTypeKorean)
        {
            [self.languageKey setSelected:YES];
            [self changeKeyboard:CMKeyboardTypeEnglish];
        }
        else
        {
            [self.languageKey setSelected:NO];
            [self changeKeyboard:CMKeyboardTypeKorean];
        }
    }
}

- (IBAction)changeNumberKeyboardAction:(id)sender
{
    if (self.keyboardType != CMKeyboardTypeNumberAndSymbol)
    {
        self.tildeKey.hidden = NO;
        self.shiftKey.hidden = YES;
        [self.numberKey setSelected:YES];
        [self changeKeyboard:CMKeyboardTypeNumberAndSymbol];
    }
    else
    {
        self.tildeKey.hidden = YES;
        self.shiftKey.hidden = NO;
        [self.numberKey setSelected:NO];
        [self changeKeyboard:CMKeyboardTypeKorean];
    }
}

- (IBAction)changeShiftKeyboardAction:(id)sender
{
    if (self.keyboardType == CMKeyboardTypeKorean)
    {
        if (self.isShiftKeyPressed)
        {
            self.isShiftKeyPressed = NO;
            [self.shiftKey setSelected:NO];
            [self changeKeyboard:CMKeyboardTypeKorean];
        }
        else
        {
            self.isShiftKeyPressed = YES;
            [self.shiftKey setSelected:YES];
            for (UIButton *keyButton in self.keyList)
            {
                if (keyButton.tag < 10)
                {
                    NSString *keyTitle = self.koPairKeyList[keyButton.tag];
                    [keyButton setTitle:keyTitle forState:UIControlStateNormal];
                }
            }
        }
    }
}

#pragma mark - 프라이빗 메서드 -

- (void)setup
{
    // 키보드 타입 초기화.
    self.keyboardType = CMKeyboardTypeKorean;
    
    // 한글 키.
    self.koKeyList = @[@"ㅂ", @"ㅈ", @"ㄷ", @"ㄱ", @"ㅅ", @"ㅛ", @"ㅕ", @"ㅑ", @"ㅐ", @"ㅔ", @"ㅁ", @"ㄴ", @"ㅇ", @"ㄹ", @"ㅎ", @"ㅗ", @"ㅓ", @"ㅏ", @"ㅣ", @"ㅋ", @"ㅌ", @"ㅊ", @"ㅍ", @"ㅠ", @"ㅜ", @"ㅡ"];
    
    // 한글 쌍 모음/자음 키.
    self.koPairKeyList = @[@"ㅃ", @"ㅉ", @"ㄸ", @"ㄲ", @"ㅆ", @"ㅛ", @"ㅕ", @"ㅑ", @"ㅒ", @"ㅖ"];
    
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
