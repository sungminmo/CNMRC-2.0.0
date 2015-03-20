//
//  CMKeyboardView.h
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 20..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CMKeyboardType) {
    CMKeyboardTypeKorean,
    CMKeyboardTypeEnglish,
    CMKeyboardTypeNumberAndSymbol
};

@protocol CMKeyboardDelegate;

IB_DESIGNABLE
@interface CMKeyboardView : UIView

@property (assign, nonatomic) id<CMKeyboardDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (assign, nonatomic) IBInspectable CMKeyboardType keyboardType;

- (void)keyAction:(id)sender;

@end

@protocol CMKeyboardDelegate <NSObject>
- (void)pressedKey:(UIButton *)key;
@end
