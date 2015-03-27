//
//  CMPlayerViewController.h
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 26..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPlayerView.h"
#import "CMChannelInfo.h"
#import "CMActivityIndicator.h"

@interface CMPlayerViewController : UIViewController <UIGestureRecognizerDelegate>

// 데이터.
@property (strong, nonatomic) NSArray *blockChannelInfo;
@property (strong, nonatomic) CMChannelInfo *channelInfo;

// 플레이어 뷰.
@property (weak, nonatomic) IBOutlet CMPlayerView *playerView;

// 볼륨 프로그레스뷰.
@property (weak, nonatomic) IBOutlet UIProgressView *volumeProgressView;

// 백그라운드.
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;

// 로딩.
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet CMActivityIndicator *loadingImageView;

// 컨트롤.
@property (weak, nonatomic) IBOutlet UIView *controlPannel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *volumeMuteButton;
@property (weak, nonatomic) IBOutlet UILabel *channelNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelNoIndicatorLabel;

// 채널정보 페이지로 이동.
- (IBAction)goChannelAction:(id)sender;

// 플레이어 종료.
- (IBAction)closeAction:(id)sender;

// 볼륨 조절.
- (IBAction)volumeAction:(id)sender;

// 볼륨 끄기.
- (IBAction)volumeMuteAction:(id)sender;

// 채널 업/다운.
- (IBAction)channelAction:(id)sender;

// 숫자키로 채널 이동.
- (IBAction)numberAction:(id)sender;

@end
