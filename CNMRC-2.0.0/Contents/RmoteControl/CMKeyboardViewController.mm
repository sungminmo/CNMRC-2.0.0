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
    kb.delegate = self;
    [self.KeyboardBackground addSubview:kb];
    self.keyboard = kb;
}

- (void)recognizeTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self cancelAction:recognizer];
    }
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
    self.searchTextField.text = @"111111";
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
