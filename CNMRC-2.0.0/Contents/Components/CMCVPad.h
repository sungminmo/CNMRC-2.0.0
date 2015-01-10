//
//  CMCVPad.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMCVPadDelegate;

@interface CMCVPad : UIView

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (assign, nonatomic) id<CMCVPadDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *volumeUpButton;
@property (weak, nonatomic) IBOutlet UIButton *volumeMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *volumeDownButton;
@property (weak, nonatomic) IBOutlet UIImageView *speakIcon;
@property (weak, nonatomic) IBOutlet UIButton *channelUpButton;
@property (weak, nonatomic) IBOutlet UIButton *channelDownButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

- (IBAction)buttonAction:(id)sender;

@end

@protocol CMCVPadDelegate <NSObject>
- (void)cvPad:(CMCVPad *)pad selectedKey:(UIButton *)key;
@end
