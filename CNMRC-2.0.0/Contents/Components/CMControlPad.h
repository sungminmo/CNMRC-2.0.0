//
//  CMControlPad.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 12..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMControlPadDelegate;

@interface CMControlPad : UIView

@property (assign, nonatomic) id<CMControlPadDelegate> delegate;

// 영상 컨트롤 패드.
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

- (IBAction)buttonAction:(id)sender;

@end

@protocol CMControlPadDelegate <NSObject>
- (void)controlPad:(CMControlPad *)pad selectedKey:(UIButton *)key;
@end