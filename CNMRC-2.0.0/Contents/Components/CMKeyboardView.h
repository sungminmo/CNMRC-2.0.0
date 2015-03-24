//
//  CMKeyboardView.h
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 20..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPressView.h"

#define KEY_TAG_SHIFT 100               // 쉬프트 키.
#define KEY_TAG_BACK 200                // 삭제 키.
#define KEY_TAG_LANGUAGE_AND_NUMBER 300 // 숫자 변환 키.
#define KEY_TAG_KO_AND_EN 400           // 한/영 변환 키.
#define KEY_TAG_SPACE 500               // 스페이스 키.
#define KEY_TAG_SEARCH 600              // 검색 키.

typedef NS_ENUM(NSInteger, CMKeyboardType) {
    CMKeyboardTypeKorean,
    CMKeyboardTypeEnglish,
    CMKeyboardTypeNumberAndSymbol
};

@protocol CMKeyboardDelegate;

@interface CMKeyboardView : UIView

@property (assign, nonatomic) id<CMKeyboardDelegate> delegate;
@property (assign, nonatomic) CMKeyboardType keyboardType;
@property (strong, nonatomic) NSArray *koKeyList;
@property (strong, nonatomic) NSArray *koPairKeyList;
@property (strong, nonatomic) NSArray *enUpperCaseKeyList;
@property (strong, nonatomic) NSArray *enLowerCaseKeyList;
@property (strong, nonatomic) NSArray *numberKeyList;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *keyList;
@property (assign, nonatomic) BOOL isShiftKeyPressed;
@property (weak, nonatomic) IBOutlet UIButton *shiftKey;
@property (weak, nonatomic) IBOutlet UIButton *numberKey;
@property (weak, nonatomic) IBOutlet UIButton *languageKey;
@property (weak, nonatomic) IBOutlet UIButton *tildeKey;

- (IBAction)keyAction:(id)sender;
- (IBAction)changeKeyboardTypeAction:(id)sender;
- (IBAction)changeNumberKeyboardAction:(id)sender;
- (IBAction)changeShiftKeyboardAction:(id)sender;

@end

@protocol CMKeyboardDelegate <NSObject>
- (void)pressedKey:(UIButton *)key;
- (void)keyboardDidChange:(CMKeyboardType)type;
@end
