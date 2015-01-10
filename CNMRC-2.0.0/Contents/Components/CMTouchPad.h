//
//  CMTouchPad.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMTouchPadDelegate;

@interface CMTouchPad : UIView

@property (assign, nonatomic) id<CMTouchPadDelegate> delegate;
@property(nonatomic, assign) id touchHandler;

// 4방향 버튼.
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

- (IBAction)buttonAction:(id)sender;
- (void)touchAnimation:(CGPoint)point;

@end

@protocol CMTouchPadDelegate <NSObject>
- (void)touchPad:(CMTouchPad *)pad selectedKey:(UIButton *)key;
@optional
- (void)touchPadDidBeginTracking:(CMTouchPad *)controller;
- (void)touchPadDidEndTracking:(CMTouchPad *)controller;
@end
