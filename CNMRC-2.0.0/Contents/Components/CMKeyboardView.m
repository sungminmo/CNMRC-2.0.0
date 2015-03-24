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
    UIButton *button = (UIButton *)sender;
    
    DDLogDebug(@"선택된 버튼: %@", @(button.tag));
    
    // 키만 대상으로 처리한다.
    if (button.tag < 27)
    {
        NSString *pressImageName = nil;
        CGFloat pressViewWidth = 0;
        CGFloat pressViewHight = 109;
        NSString *pressViewXIB = nil;
        switch ([LPPhoneVersion deviceSize]) {
            case iPhone55inch:
                pressViewWidth = 64;
                pressViewXIB = @"CMPressView";
                break;
                
            case iPhone47inch:
                pressViewWidth = 56;
                pressViewXIB = @"CMPressView_6";
                break;
                
            default:
                pressViewWidth = 52;
                pressViewXIB = @"CMPressView_5";
                break;
        }
        
        CGRect pressVewFrame = CGRectZero;
        if (button.tag == 0)
        {
            pressImageName = @"Key_Left_Press";
            pressVewFrame = CGRectMake(button.frame.origin.x,
                                       button.frame.origin.y - (pressViewHight - button.frame.size.height),
                                       pressViewWidth,
                                       pressViewHight);
        }
        else if (button.tag == 9)
        {
            pressImageName = @"Key_Right_Press";
            pressVewFrame = CGRectMake(button.frame.origin.x - (pressViewWidth - button.frame.size.width),
                                       button.frame.origin.y - (pressViewHight - button.frame.size.height),
                                       pressViewWidth,
                                       pressViewHight);
        }
        else
        {
            pressImageName = @"Key_Center_Press";
            pressVewFrame = CGRectMake(button.frame.origin.x - (pressViewWidth - button.frame.size.width)/2,
                                       button.frame.origin.y - (pressViewHight - button.frame.size.height),
                                       pressViewWidth,
                                       pressViewHight);
        }
        
        CMPressView *pv = [[[NSBundle mainBundle] loadNibNamed:pressViewXIB owner:self options:nil] objectAtIndex:0];
        pv.frame = pressVewFrame;
        [pv setImage:pressImageName andLabel:button.titleLabel.text];
        [self addSubview:pv];
        
        [self performSelector:@selector(removePressView:) withObject:pv afterDelay:0.3];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pressedKey:)])
    {
        [self.delegate pressedKey:sender];
    }
}

- (void)removePressView:(UIView *)pressView
{
    [pressView removeFromSuperview];
}

// 한/영 키 변환.
- (IBAction)changeKeyboardTypeAction:(id)sender
{
    self.tildeKey.hidden = YES;
    self.shiftKey.hidden = NO;
    [self.shiftKey setSelected:NO];
    [self.numberKey setSelected:NO];
    self.isShiftKeyPressed = NO;
    
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

// 숫자키 변환.
- (IBAction)changeNumberKeyboardAction:(id)sender
{
    [self.languageKey setSelected:NO];
    
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

// 쉬프트 키 선택.
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
    else if (self.keyboardType == CMKeyboardTypeEnglish)
    {
        if (self.isShiftKeyPressed)
        {
            self.isShiftKeyPressed = NO;
            [self.shiftKey setSelected:NO];
            [self changeKeyboard:CMKeyboardTypeEnglish];
        }
        else
        {
            self.isShiftKeyPressed = YES;
            [self.shiftKey setSelected:YES];
            for (UIButton *keyButton in self.keyList)
            {
                if (keyButton.tag != 26)
                {
                    NSString *keyTitle = self.enLowerCaseKeyList[keyButton.tag];
                    [keyButton setTitle:keyTitle forState:UIControlStateNormal];
                    [keyButton setNeedsDisplay];
                }
            }
        }
    }
    else
    {
        self.isShiftKeyPressed = !self.isShiftKeyPressed;
        [self.shiftKey setSelected:self.isShiftKeyPressed];
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
    
    // 영문 대문자 키.
    self.enUpperCaseKeyList = @[@"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"Z", @"X", @"C", @"V", @"B", @"N", @"M"];
    
    // 영문 소문자 키.
    self.enLowerCaseKeyList = @[@"q", @"w", @"e", @"r", @"r", @"y", @"u", @"i", @"o", @"p", @"a", @"s", @"d", @"f", @"g", @"h", @"j", @"k", @"l", @"z", @"x", @"c", @"v", @"b", @"n", @"m"];
    
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
                    NSString *keyTitle = self.enUpperCaseKeyList[keyButton.tag];
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
    
    // 언어 변경 노티.
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardDidChange:)])
    {
        [self.delegate keyboardDidChange:self.keyboardType];
    }
}

@end
