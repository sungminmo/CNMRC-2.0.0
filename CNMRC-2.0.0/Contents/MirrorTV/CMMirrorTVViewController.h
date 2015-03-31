//
//  CMMirrorTVViewController.h
//  CNMRC
//
//  Created by lambert on 2014. 4. 22..
//  Copyright (c) 2014년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CMChannelInfo.h"

// 미러TV 상태.
typedef NS_ENUM(NSInteger, CMMirrorTVStatus) {
    CMMirrorTVStatusPlaying = 0,
    CMMirrorTVStatusLoading,
    CMMirrorTVStatusError
};

@class AVPlayer;
@class AVPlayerItem;
@class CMPlayerLayerView;

@interface CMMirrorTVViewController : UIViewController <UIGestureRecognizerDelegate>

// 데이터.
@property (strong, nonatomic) NSArray *blockChannelInfo;
@property (strong, nonatomic) CMChannelInfo *channelInfo;

// 플레이어.
@property (weak, nonatomic) IBOutlet CMPlayerLayerView *playerLayerView;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet UIProgressView *volumeProgressView;

// 백그라운드.
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;

// 로딩.
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;

// 컨트롤.
@property (weak, nonatomic) IBOutlet UIView *controlPannel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *channelButton;
@property (weak, nonatomic) IBOutlet UIView *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *volumeMuteButton;
@property (weak, nonatomic) IBOutlet UILabel *channelNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelNoIndicatorLabel;

- (IBAction)goChannelAction:(id)sender;
- (IBAction)closeAction:(id)sender;
- (IBAction)volumeAction:(id)sender;
- (IBAction)volumeMuteAction:(id)sender;
- (IBAction)channelAction:(id)sender;
- (IBAction)numberAction:(id)sender;

@end
