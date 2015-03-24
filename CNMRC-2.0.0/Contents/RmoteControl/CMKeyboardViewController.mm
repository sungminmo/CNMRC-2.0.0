//
//  CMKeyboardViewController.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 20..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMKeyboardViewController.h"
#include "keycodes.pb.h"

using namespace anymote::messages;

@interface CMKeyboardViewController ()

@end

@implementation CMKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 프라이빗 메서드 -

- (void)setupLayout
{
    // 백그라운트 컬러 설정.
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    
    // 탭 제스처 추가.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeTapGesture:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
    // 키보드 추가.
    NSString *keyboardXIB = nil;
    switch ([LPPhoneVersion deviceSize]) {
        case iPhone55inch:
            keyboardXIB = @"CMKeyboardView";
            break;
            
        case iPhone47inch:
            keyboardXIB = @"CMKeyboardView_6";
            break;
            
        default:
            keyboardXIB = @"CMKeyboardView_5";
            break;
    }
    
    CMKeyboardView *kb = [[[NSBundle mainBundle] loadNibNamed:keyboardXIB owner:self options:nil] objectAtIndex:0];
    kb.clipsToBounds = NO;
    kb.delegate = self;
    [self.KeyboardBackground addSubview:kb];
    self.KeyboardBackground.clipsToBounds = NO;
    self.keyboard = kb;
    
    // 키보드 언어 설정(한글).
    self.currentInputMode = CMKeyboardTypeKorean;
    [RemoteManager.sender sendClickForKey:BTN_GAME_16 error:NULL];
}

- (void)recognizeTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self cancelAction:recognizer];
    }
}

#pragma mark - 프라이빗 메스드

// 쌍모음/쌍자음 확인.
- (BOOL)isPair:(NSString *)hangeul
{
    BOOL isPair = NO;
    if ([hangeul isEqualToString:@"ㅃ"] ||
        [hangeul isEqualToString:@"ㅉ"] ||
        [hangeul isEqualToString:@"ㄸ"] ||
        [hangeul isEqualToString:@"ㄲ"] ||
        [hangeul isEqualToString:@"ㅆ"] ||
        [hangeul isEqualToString:@"ㅒ"] ||
        [hangeul isEqualToString:@"ㅖ"])
    {
        isPair = YES;
    }
    
    return isPair;
}

// 쌍모음/쌍자음에 해당하는 영문(알파벳)으로 매핑한다.
- (NSString *)mappingHanguelToEnglish:(NSString *)hangeul
{
    if ([hangeul isEqualToString:@"ㅃ"])
    {
        return @"Q";
    }
    else if ([hangeul isEqualToString:@"ㅉ"])
    {
        return @"W";
    }
    else if ([hangeul isEqualToString:@"ㄸ"])
    {
        return @"E";
    }
    else if ([hangeul isEqualToString:@"ㄲ"])
    {
        return @"R";
    }
    else if ([hangeul isEqualToString:@"ㅆ"])
    {
        return @"T";
    }
    else if ([hangeul isEqualToString:@"ㅒ"])
    {
        return @"O";
    }
    else if ([hangeul isEqualToString:@"ㅖ"])
    {
        return @"P";
    }
    
    return nil;
}

// 한글일 경우 STB에 키코드를 전달하기 위해 한글을 키코드로 매핑한다.
- (int)mappingHanguelToKeycode:(NSString *)hangeul
{
    if([hangeul isEqualToString:@" "])
    {
        return KEYCODE_SPACE;
    }
    else if ([hangeul isEqualToString:@"ㅂ"])
    {
        return KEYCODE_Q;
    }
    else if ([hangeul isEqualToString:@"ㅈ"])
    {
        return KEYCODE_W;
    }
    else if ([hangeul isEqualToString:@"ㄷ"])
    {
        return KEYCODE_E;
    }
    else if ([hangeul isEqualToString:@"ㄱ"])
    {
        return KEYCODE_R;
    }
    else if ([hangeul isEqualToString:@"ㅅ"])
    {
        return KEYCODE_T;
    }
    else if ([hangeul isEqualToString:@"ㅛ"])
    {
        return KEYCODE_Y;
    }
    else if ([hangeul isEqualToString:@"ㅕ"])
    {
        return KEYCODE_U;
    }
    else if ([hangeul isEqualToString:@"ㅑ"])
    {
        return KEYCODE_I;
    }
    else if ([hangeul isEqualToString:@"ㅐ"])
    {
        return KEYCODE_O;
    }
    else if ([hangeul isEqualToString:@"ㅔ"])
    {
        return KEYCODE_P;
    }
    else if ([hangeul isEqualToString:@"ㅁ"])
    {
        return KEYCODE_A;
    }
    else if ([hangeul isEqualToString:@"ㄴ"])
    {
        return KEYCODE_S;
    }
    else if ([hangeul isEqualToString:@"ㅇ"])
    {
        return KEYCODE_D;
    }
    else if ([hangeul isEqualToString:@"ㄹ"])
    {
        return KEYCODE_F;
    }
    else if ([hangeul isEqualToString:@"ㅎ"])
    {
        return KEYCODE_G;
    }
    else if ([hangeul isEqualToString:@"ㅗ"])
    {
        return KEYCODE_H;
    }
    else if ([hangeul isEqualToString:@"ㅓ"])
    {
        return KEYCODE_J;
    }
    else if ([hangeul isEqualToString:@"ㅏ"])
    {
        return KEYCODE_K;
    }
    else if ([hangeul isEqualToString:@"ㅣ"])
    {
        return KEYCODE_L;
    }
    else if ([hangeul isEqualToString:@"ㅋ"])
    {
        return KEYCODE_Z;
    }
    else if ([hangeul isEqualToString:@"ㅌ"])
    {
        return KEYCODE_X;
    }
    else if ([hangeul isEqualToString:@"ㅊ"])
    {
        return KEYCODE_C;
    }
    else if ([hangeul isEqualToString:@"ㅍ"])
    {
        return KEYCODE_V;
    }
    else if ([hangeul isEqualToString:@"ㅠ"])
    {
        return KEYCODE_B;
    }
    else if ([hangeul isEqualToString:@"ㅜ"])
    {
        return KEYCODE_N;
    }
    else if ([hangeul isEqualToString:@"ㅡ"])
    {
        return KEYCODE_M;
    }
    else if ([hangeul isEqualToString:@"0"])
    {
        return KEYCODE_0;
    }
    else if ([hangeul isEqualToString:@")"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_0;
    }
    else if ([hangeul isEqualToString:@"1"])
    {
        return KEYCODE_1;
    }
    else if ([hangeul isEqualToString:@"!"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_1;
    }
    else if ([hangeul isEqualToString:@"2"])
    {
        return KEYCODE_2;
    }
    else if ([hangeul isEqualToString:@"3"])
    {
        return KEYCODE_3;
    }
    else if ([hangeul isEqualToString:@"#"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_3;
    }
    else if ([hangeul isEqualToString:@"4"])
    {
        return KEYCODE_4;
    }
    else if ([hangeul isEqualToString:@"$"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_4;
    }
    else if ([hangeul isEqualToString:@"5"])
    {
        return KEYCODE_5;
    }
    else if ([hangeul isEqualToString:@"%"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_5;
    }
    else if ([hangeul isEqualToString:@"6"])
    {
        return KEYCODE_6;
    }
    else if ([hangeul isEqualToString:@"^"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_6;
    }
    else if ([hangeul isEqualToString:@"7"])
    {
        return KEYCODE_7;
    }
    else if ([hangeul isEqualToString:@"&"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_7;
    }
    else if ([hangeul isEqualToString:@"8"])
    {
        return KEYCODE_8;
    }
    else if ([hangeul isEqualToString:@"*"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_8;
    }
    else if ([hangeul isEqualToString:@"9"])
    {
        return KEYCODE_9;
    }
    else if ([hangeul isEqualToString:@"("])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_9;
    }
    else if ([hangeul isEqualToString:@","])
    {
        return KEYCODE_COMMA;
    }
    else if ([hangeul isEqualToString:@"<"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_COMMA;
    }
    else if ([hangeul isEqualToString:@"."])
    {
        return KEYCODE_PERIOD;
    }
    else if ([hangeul isEqualToString:@">"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_PERIOD;
    }
    else if ([hangeul isEqualToString:@"`"])
    {
        return KEYCODE_GRAVE;
    }
    else if ([hangeul isEqualToString:@"~"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_GRAVE;
    }
    else if ([hangeul isEqualToString:@"-"])
    {
        return KEYCODE_MINUS;
    }
    else if ([hangeul isEqualToString:@"_"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_MINUS;
    }
    else if ([hangeul isEqualToString:@"="])
    {
        return KEYCODE_EQUALS;
    }
    else if ([hangeul isEqualToString:@"["])
    {
        return KEYCODE_LEFT_BRACKET;
    }
    else if ([hangeul isEqualToString:@"{"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_LEFT_BRACKET;
    }
    else if ([hangeul isEqualToString:@"]"])
    {
        return KEYCODE_RIGHT_BRACKET;
    }
    else if ([hangeul isEqualToString:@"}"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_RIGHT_BRACKET;
    }
    else if ([hangeul isEqualToString:@"\\"])
    {
        return KEYCODE_BACKSLASH;
    }
    else if ([hangeul isEqualToString:@"|"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_BACKSLASH;
    }
    else if ([hangeul isEqualToString:@";"])
    {
        return KEYCODE_SEMICOLON;
    }
    else if ([hangeul isEqualToString:@":"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_SEMICOLON;
    }
    else if ([hangeul isEqualToString:@"'"])
    {
        return KEYCODE_APOSTROPHE;
    }
    else if ([hangeul isEqualToString:@"\""])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_APOSTROPHE;
    }
    else if ([hangeul isEqualToString:@"/"])
    {
        return KEYCODE_SLASH;
    }
    else if ([hangeul isEqualToString:@"?"])
    {
        [RemoteManager.sender sendClickForKey:KEYCODE_SHIFT_LEFT error:NULL];
        return KEYCODE_SLASH;
    }
    else if ([hangeul isEqualToString:@"@"])
    {
        return KEYCODE_AT;
    }
    else if ([hangeul isEqualToString:@"+"])
    {
        return KEYCODE_PLUS;
    }
    
    return 0;
}

#pragma mark - 퍼블릭 메서드 -

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deleteTVCharacter:(id)sender
{
    [RemoteManager.sender sendClickForKey:KEYCODE_DEL error:NULL];
}

#pragma mark - CMKeyboardDelegate -

- (void)pressedKey:(UIButton *)key
{
    NSInteger keyTag = key.tag;
    NSString *string = key.titleLabel.text;
    
    if (keyTag == KEY_TAG_BACK)
    {
        // 삭제 키.
        NSString *oldText = self.searchTextField.text;
        if (oldText.length > 0)
        {
            // 한 글자씩 삭제한다.
            [RemoteManager.sender sendClickForKey:KEYCODE_DEL error:NULL];
            
            NSString *newText = [oldText substringToIndex:[oldText length] - 1];
            self.searchTextField.text = newText;
        }
    }
    else if (keyTag == KEY_TAG_SPACE)
    {
        // 스페이스 키.
        string = @"";
        [RemoteManager.sender enterText:string error:NULL];
        NSString *newText = [self.searchTextField.text stringByAppendingString:string];
        self.searchTextField.text = newText;
    }
    else if (keyTag == KEY_TAG_SEARCH)
    {
        // 검색 키.
        [RemoteManager.sender sendClickForKey:KEYCODE_ENTER error:NULL];
    }
    else
    {
        if (self.currentInputMode == CMKeyboardTypeEnglish)
        {
            // 영문일 경우 텍스트 전송.
            [RemoteManager.sender enterText:string error:NULL];
        }
        else
        {
            NSLog(@"Input string: %@", string);
            
            // !!!: 한글이 단모음/단자음일 경우 Anymote 키코드 전송, 쌍모음/쌍자음일 경우 영문 텍스트 전송.
            if ([self isPair:string])
            {
                [RemoteManager.sender enterText:[self mappingHanguelToEnglish:string] error:NULL];
            }
            else
            {
                [RemoteManager.sender sendClickForKey:[self mappingHanguelToKeycode:string] error:NULL];
            }
        }
        
        NSString *newText = [self.searchTextField.text stringByAppendingString:string];
        self.searchTextField.text = newText;
    }
}

- (void)keyboardDidChange:(CMKeyboardType)type
{
    DDLogDebug(@"현재 입력모드: %@", @(type));
    self.currentInputMode = type;
    
    // STB에 한영 변환 알림!
    if (self.currentInputMode == CMKeyboardTypeEnglish)
    {
        [RemoteManager.sender sendClickForKey:BTN_GAME_15 error:NULL];
    }
    else
    {
        [RemoteManager.sender sendClickForKey:BTN_GAME_16 error:NULL];
    }
}

#pragma mark - 제스처 델리게이트 메서드 -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.view)
    {
        return YES;
    }
    
    return NO;
}

@end
