//
//  CMPlayerViewController.h
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 31..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMChannelInfo.h"
#import "CMActivityIndicator.h"
#import <MediaPlayer/MPVolumeView.h>

@class KxMovieDecoder;

extern NSString * const KxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KxMovieParameterDisableDeinterlacing;   // BOOL

@interface CMPlayerViewController : UIViewController <UIGestureRecognizerDelegate, CMHTTPClientDelegate>

// 플레이 여부.
@property (readonly) BOOL playing;

// 데이터.
@property (strong, nonatomic) NSArray *blockChannelInfo;
@property (strong, nonatomic) CMChannelInfo *channelInfo;

// 볼륨.
@property (weak, nonatomic) IBOutlet UIView *volumeHolder;
@property (strong, nonatomic) MPVolumeView *volumeView;
@property (nonatomic) float currentVolume;

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

// 플레이어 관련.
- (void)playWithContentPath:(NSString *)path parameters:(NSDictionary *)parameters;
- (void)play;
- (void)pause;
- (void)stop;

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
