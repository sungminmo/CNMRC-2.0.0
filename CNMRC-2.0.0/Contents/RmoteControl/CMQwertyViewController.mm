//
//  CMQwertyViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMQwertyViewController.h"
#include "keycodes.pb.h"

using namespace anymote::messages;

@interface CMQwertyViewController ()
- (int)mappingHanguelToKeycode:(NSString *)hangeul;
@end

@implementation CMQwertyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setQwertyTextField:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // UTTextField 노티피케이션 옵저버 등록.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(inputModeDidChange:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // TTextField 노티피케이션 옵저버 삭제.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupLayout
{
    if (isiOS7)
    {
        self.qwertyTextField.center = CGPointMake(self.qwertyTextField.center.x, self.qwertyTextField.center.y + 20.0);
    }
    
    [self.qwertyTextField becomeFirstResponder];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeTapGesture:)];
    [self.view addGestureRecognizer:recognizer];
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

#pragma mark - Keyboard handling

- (void)keyboardWillShow:(NSNotification *)notification
{
    // 키보드 언어 확인.
    if ([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString:@"en-US"])
    {
        [RemoteManager.sender sendClickForKey:BTN_GAME_15 error:NULL];
    }
    else
    {
        [RemoteManager.sender sendClickForKey:BTN_GAME_16 error:NULL];
    }
    
    self.currentInputMode = [[UITextInputMode currentInputMode] primaryLanguage];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
}

// 텍스트 입력모드 확인.
- (void)inputModeDidChange:(NSNotification *)notification
{
    for (UITextInputMode *mode in [UITextInputMode activeInputModes])
    {
        NSLog(@"Device input mode: %@", [mode primaryLanguage]);
    }
    GTMLoggerDebug(@"Currnet input mode: %@", [[UITextInputMode currentInputMode] primaryLanguage]);
    
    self.currentInputMode = [[UITextInputMode currentInputMode] primaryLanguage];
    
    NSLog(@"현재 입력모드: %@", self.currentInputMode);
    
    // STB에 한영 변환 알림!
    if ([self.currentInputMode isEqualToString:@"en-US"])
    {
        [RemoteManager.sender sendClickForKey:BTN_GAME_15 error:NULL];
    }
    else
    {
        [RemoteManager.sender sendClickForKey:BTN_GAME_16 error:NULL];
    }
}

#pragma makr - TextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{    
    if (range.length > [string length])
    {
        for (NSUInteger i = 0; i < range.length; ++i)
        {
            [RemoteManager.sender sendClickForKey:KEYCODE_DEL error:NULL];
        }
    }
    else
    {
        if ([string isEqualToString:@"\n"])
        {
            [RemoteManager.sender sendClickForKey:KEYCODE_ENTER error:NULL];
        }
        else
        {
            if ([self.currentInputMode isEqualToString:@"en-US"])
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
        }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = self.inputAccessoryView;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.inputAccessoryView = nil;
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.qwertyTextField resignFirstResponder];
}

- (IBAction)deleteTVCharacter:(id)sender
{
    [RemoteManager.sender sendClickForKey:KEYCODE_DEL error:NULL];
}

@end
