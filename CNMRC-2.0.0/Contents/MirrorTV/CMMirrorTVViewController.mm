//
//  CMMirrorTVViewController.m
//  CNMRC
//
//  Created by lambert on 2014. 4. 22..
//  Copyright (c) 2014년 Jong Pil Park. All rights reserved.
//

#import "CMMirrorTVViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "DQAlertView.h"
#import "CMRCViewController.h"
#include "keycodes.pb.h"

// 소켓 관련.
#import "CMTRGenerator.h"
#import "CM04.h"
#import "CM05.h"
#import "CM06.h"

// 플레이어 관련.
#import "CMPlayerLayerView.h"

static void *CMMirrorTVViewControllerTimedMetadataObserverContext = &CMMirrorTVViewControllerTimedMetadataObserverContext;
static void *CMMirrorTVViewControllerRateObservationContext = &CMMirrorTVViewControllerRateObservationContext;
static void *CMMirrorTVViewControllerCurrentItemObservationContext = &CMMirrorTVViewControllerCurrentItemObservationContext;
static void *CMMirrorTVViewControllerPlayerItemStatusObserverContext = &CMMirrorTVViewControllerPlayerItemStatusObserverContext;

NSString *kTracksKey		= @"tracks";
NSString *kStatusKey		= @"status";
NSString *kRateKey			= @"rate";
NSString *kPlayableKey		= @"playable";
NSString *kCurrentItemKey	= @"currentItem";
NSString *kTimedMetadataKey	= @"currentItem.timedMetadata";

#pragma mark -
@interface CMMirrorTVViewController (Player)
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)handleTimedMetadata:(AVMetadataItem*)timedMetadata;
- (void)updateAdList:(NSArray *)newAdList;
- (void)assetFailedToPrepareForPlayback:(NSError *)error;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
@end

using namespace anymote::messages;

// 영상 확장자.
#define HLS_EXTENTION @"m3u8"

// 채널버튼 태그.
#define CHANNEL_BUTTON_TAG 1000

// 볼륨 단위.
#define VOLUME_UNIT 0.0625f

@interface CMMirrorTVViewController ()
{
    // 컨트롤 패널 토글(감추기 여부).
    BOOL _isHide;
    
    // Mute 여부.
    BOOL _isMuted;
    
    // 블락채널 여부.
    BOOL _isBlockChannel;
    
    // CM06 에러 횟수.
    NSInteger _errorCount;
    
    // 플레이어.
    BOOL seekToZeroBeforePlay;
}

@property (weak, nonatomic) NSURL *mirrorTVURL;
@property (strong, nonatomic) NSTimer *heartbeatTimer;
@property (strong, nonatomic) NSTimer *hideControlPannelTimer;

- (void)setupLayout;
- (void)adjustLayout:(CMMirrorTVStatus)status;
- (void)toggleBackground:(BOOL)hidden;
- (void)toggleLoading:(BOOL)hidden;
- (void)toggleControl:(BOOL)hidden;
- (void)setupChannelInfo;
- (void)startLoading;
- (void)requestAssetID;
- (void)requestStop;
- (void)requestHeartbeat;
- (NSURL *)genMirrorTVURL:(NSString *)receivedAssetID;
- (BOOL)isBlockedChannel:(NSString *)sourceID;
- (void)showNotice:(NSString *)msg;

@end

@implementation CMMirrorTVViewController

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
    
    // 뷰 로테이션(-90도).
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    rotationTransform = CGAffineTransformRotate(rotationTransform, -M_PI/2);
    self.view.transform = rotationTransform;
    
    // 상태바 감추기.
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    // 전문 수신용 옵저버 등록: CM04, CM05, CM06.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM04 object:nil];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM041 object:nil];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM05 object:nil];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM06 object:nil];
    
    // CMO6 heartbeat 타이머 설정(2초마다).
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(requestHeartbeat) userInfo:nil repeats:YES];
    
    // HLS URL 생성을 위해 AssetID 요청.
    [self requestAssetID];
    
    // 화면 설정.
    [self setupLayout];
    
    // 로딩 시작.
    [self adjustLayout:CMMirrorTVStatusLoading];
    
    // 볼륨 프로그레스바 초기화.
    [self.volumeProgressView setProgress:self.player.volume animated:YES];
    
    // 현재 볼륨 초기화.
    self.currentVolume = self.player.volume;
    
    // 테스트.
    self.mirrorTVURL = [NSURL URLWithString:@"http://192.168.0.35/VideoSample/new-2/SERV2257.m3u8"];
    [self loadMirrorTV];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//- (BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationLandscapeLeft;
//}

#pragma mark - 플레이어

// 플레이.
- (void)play
{
    // 영상의 마지막이면 플레이가 시작되기 전에 반드시 처음으로 돌아가야 한다.
	if (YES == seekToZeroBeforePlay)
	{
		seekToZeroBeforePlay = NO;
		[_player seekToTime:kCMTimeZero];
	}
    
	[_player play];
    
    // 4초후에 컨트롤 패널 감추기.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPannel) object:nil];
    [self performSelector:@selector(hideControlPannel) withObject:nil afterDelay:4];
}

// 정지.
- (void)pause
{
	[_player pause];
}

// 미러TV URL 로드.
- (void)loadMirrorTV
{
	if (self.mirrorTVURL)
	{
        // URL이 정상인지 확인한다.
		if ([self.mirrorTVURL scheme])
		{
            // URL로 어셋을 생성하여 어셋 키인 "tracks", "playable" 값을 로드 한다.
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.mirrorTVURL options:nil];
            
			NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
			
            // 아직 로드되지 않은 특정 키의 값을 로드한다.
			[asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
			 ^{
				 dispatch_async( dispatch_get_main_queue(),
								^{
									// AVPlayer와 AVPlayerItem은 반드시 메인 큐에서...
									[self prepareToPlayAsset:asset withKeys:requestedKeys];
								});
			 }];
		}
	}
}

#pragma mark - 프라이빗 메서드

// 화면 설정.
- (void)setupLayout
{
    // 탭 제스처: 플레이어 컨트롤 토글 용.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeTapGesture:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
    // 에러 횟수 초기화.
    _errorCount = 0;

    // 채널 정보 설정.
    [self setupChannelInfo];
    
    //[self.view bringSubviewToFront:self.playerLayerView];
}

// 제스처 콜백.
- (void)recognizeTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // 플레이어 컨트롤을 토글 시킨다.
        [self toggleControl:_isHide];
    }
}

// 레이아웃 조정.
- (void)adjustLayout:(CMMirrorTVStatus)status
{
    switch (status)
    {
        case CMMirrorTVStatusPlaying:
        {
            [self toggleBackground:YES];
            [self toggleLoading:YES];
            [self toggleControl:NO];
        }
            break;
            
        case CMMirrorTVStatusLoading:
        {
            [self toggleBackground:YES];
            [self toggleLoading:NO];
            [self toggleControl:YES];
        }
            break;
            
        case CMMirrorTVStatusError:
        {
            [self toggleBackground:NO];
            [self toggleLoading:YES];
            [self toggleControl:YES];
        }
            break;
            
        default:
            break;
    }
}

// 백그라운드 토글.
- (void)toggleBackground:(BOOL)hidden
{
    self.backgroundView.hidden = hidden;
    
    if (hidden)
    {
        [self.view sendSubviewToBack:self.backgroundView];
    }
    else
    {
        [self.view bringSubviewToFront:self.backgroundView];
    }
}

// 로딩 토글.
- (void)toggleLoading:(BOOL)hidden
{
    self.loadingView.hidden = hidden;
    
    if (hidden)
    {
        [self.view sendSubviewToBack:self.loadingView];
        
        // 로딩 종료.
        [self stopLoading];
    }
    else
    {
        [self.view bringSubviewToFront:self.loadingView];
        
        // 로딩 시작.
        [self startLoading];
    }
}

// 컨트롤 토글.
- (void)toggleControl:(BOOL)hidden
{
    // 초기화.
    self.channelNoIndicatorLabel.text = @"";
    
    self.controlPannel.hidden = hidden;
    
    if (hidden)
    {
        [self.view sendSubviewToBack:self.controlPannel];
    }
    else
    {
        [self.view bringSubviewToFront:self.controlPannel];
    }
    
    _isHide = !hidden;
}

// 볼륨 프로그레스바 감추기.
- (void)hideVolumeProgressView
{
    self.volumeProgressView.hidden = YES;
}

// 컨트롤 패널 감추기.
- (void)hideControlPannel
{
    if (_isHide)
    {
        [self toggleControl:YES];
    }
}

// 채널 정보 설정.
- (void)setupChannelInfo
{
    // 제목.
    self.titleLabel.text = [NSString stringWithFormat:@" %@", self.channelInfo.programTitle];
    
    // 채널 번호.
    self.channelNoLabel.text = self.channelInfo.channelNo;
}

// 채널 정보 변경.
- (void)changeChannelInfo:(CM06 *)data
{
    self.channelInfo.sourceID = data.sourceID;
    self.channelInfo.channelNo = data.channelNo;
    self.channelInfo.channelName = data.channelName;
    self.channelInfo.programTitle = data.title;
}

// 로딩 애니메이션 시작.
- (void)startLoading
{
    self.loadingImageView.hidden = NO;
    [self.view bringSubviewToFront:self.loadingImageView];
    
    NSTimeInterval duration = 0.25f;
    CGFloat angle = M_PI / 2.0f; // 90도.
    CGAffineTransform rotateTransform = CGAffineTransformRotate(self.loadingImageView.transform, angle);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.loadingImageView.transform = rotateTransform;
                     }
                     completion:^(BOOL finished) {
                         // 회전 애니메이션을 줄 이미지가 완전한 원이 아니라 화살표가 있기 때문에 90도씩 계속 반복시킨다.
                         if (finished)
                         {
                             [self stopLoading];
                             [self startLoading];
                         }
                     }];
}

// 로딩 애니메이션 중지.
- (void)stopLoading
{
    [self.loadingImageView.layer removeAllAnimations];
    self.loadingImageView.hidden = YES;
}

// CM04: AssetID 요청.
- (void)requestAssetID
{
    // 로딩 시작.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPannel) object:nil];
    [self performSelector:@selector(startLoading) withObject:nil afterDelay:2];
    
    // 전문 생성.
    CMTRGenerator *generator = [[CMTRGenerator alloc] init];
    NSString *tr = [generator genCM04];
    
    // 데이터 전송.
    [SocketManager sendData:tr];
}

// CM05: 미러TV 종료.
- (void)requestStop
{
    // 전문 생성.
    CMTRGenerator *generator = [[CMTRGenerator alloc] init];
    NSString *tr = [generator genCM05];
    
    // 데이터 전송.
    [SocketManager sendData:tr];
}

// CM06: heartbeat.
- (void)requestHeartbeat
{
    // 전문 생성.
    CMTRGenerator *generator = [[CMTRGenerator alloc] init];
    NSString *tr = [generator genCM06WithClientIP:[AppInfo getIPAddress]];
    
    // 데이터 전송.
    [SocketManager sendData:tr];
}

// IP 주소가 공인IP 인지 사설IP인지 체크한다.
- (BOOL)isPrivateAddress:(NSString *)address
{
    return [address hasPrefix:@"192"];
}

// 박스의 이름에서 IP를 가져온다.
// 예: stb_catv_cnm-192-168-0-131
- (NSString *)genAddress:(NSString *)boxName
{
    // 앞의 박스 이름을 제외하고 IP 부분만 가져온다.
    NSString *address = [boxName substringFromIndex:13];
    
    // "-"를 "."로 치환한다.
    return [address stringByReplacingOccurrencesOfString:@"-" withString:@"."];
}

// 미러TV URL 생성.
- (NSURL *)genMirrorTVURL:(NSString *)receivedAssetID
{
    if (!receivedAssetID) return nil;
    
    // 앞에서 8자리까지가 AssetID 이다.
    NSString *assetID = [receivedAssetID substringToIndex:8];
    
    // !!!: 공인IP가 잡히는 경우에 대한 예외 처리!
    // 사설IP(192로 시작...)  여부.
//    NSString *address = nil;
//    if ([self isPrivateAddress:[RemoteManager.currentBox.addresses objectAtIndex:0]])
//    {
//        address = [RemoteManager.currentBox.addresses objectAtIndex:0];
//    }
//    else
//    {
//        // 박스 이름에서 IP를 가져온다.
//        address = [self genAddress:RemoteManager.currentBox.name];
//    }
    
    // 원래 코드.
    NSString *address = [RemoteManager.currentBox.addresses objectAtIndex:0];
    
    NSString *stringURL = [NSString stringWithFormat:@"http://%@/%@.%@", address, assetID, HLS_EXTENTION];
    return [NSURL URLWithString:stringURL];
}

// 블럭 채널 확인.
- (BOOL)isBlockedChannel:(NSString *)sourceID
{
    NSDictionary *channelInfo = nil;
    for (NSDictionary *dict in self.blockChannelInfo)
    {
        NSString *left = [[dict objectForKey:@"sourceid"] lowercaseString];
        NSString *right = [sourceID lowercaseString];
        //NSString *block = [dict objectForKey:@"block"];
        
        if ([left isEqualToString:right])
        {
            channelInfo = dict;
            break;
        }
    }
    
    if ([[channelInfo objectForKey:@"block"] isEqualToString:@"O"])
    {
        return YES;
    }
    
    return NO;
}

// CM06 에러 공지.
- (void)showNotice:(NSString *)msg
{
    self.noticeLabel.text = msg;
    self.noticeLabel.hidden = NO;
    
    [self adjustLayout:CMMirrorTVStatusError];
}

// 에러로 인한 미러TV 종료 공지!
- (void)alertMirrorTVError
{
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"에러"
                                                        message:MIRRORTV_ERROR
                                              cancelButtonTitle:@"Cancel"
                                               otherButtonTitle:@"확인"];
    alertView.shouldDismissOnActionButtonClicked = YES;
    [alertView show];
}

// 확인 버튼만 있는 얼럿.
- (void)showAlertWithMessage:(NSString *)msg
{
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                        message:msg
                                              cancelButtonTitle:nil
                                               otherButtonTitle:@"확인"];
    alertView.shouldDismissOnActionButtonClicked = YES;
    [alertView show];
}

#pragma mark - 데이터 수신

// CM06: Mirror TV Heartbeat.
- (void)receiveSocketData:(NSNotification *)notification
{
    NSLog(@"AVPlayer status: %ld - %ld", self.player.status, self.playerItem.status);
    
    // CM04: Mirror TV 실행 요청.
    if ([notification.name isEqualToString:TR_NO_CM04])
    {
        CM04 *data = [[notification userInfo] objectForKey:CMDataObject];
        NSLog(@"Received data trNo: %@, result: %@", data.trNo, data.result);
        
        NSInteger result = [data.result integerValue];
        if (result == 0)
        {
            // 미러TV URL 생성.
            self.mirrorTVURL = [self genMirrorTVURL:data.assetID];
            
            // 미러TV 로드.
            [self loadMirrorTV];
            NSLog(@"MirrorTV URL: %@", self.mirrorTVURL);
        }
        else
        {
            // 에러 처리.
            // 미러TV 종료.
            [self alertMirrorTVError];
        }
    }
    
    // CM041: Mirror TV 실행 요청(SeconTV 예외 처리).
    if ([notification.name isEqualToString:TR_NO_CM041])
    {
        CM041 *data = [[notification userInfo] objectForKey:CMDataObject];
        NSLog(@"Received data trNo: %@(1), result: %@", data.trNo, data.result);
        
        NSInteger result = [data.result integerValue];
        if (result == 0)
        {
            // 미러TV URL 생성.
            self.mirrorTVURL = [self genMirrorTVURL:data.assetID];
            
            // SecondTV 설정.
            if ([data.secondTV isEqualToString:@"1"]) {
                AppInfo.isSecondTV = YES;
            }
            
            // 미러TV 로드.
            [self loadMirrorTV];
            NSLog(@"MirrorTV URL: %@", self.mirrorTVURL);
        }
        else
        {
            // 에러 처리.
            // 미러TV 종료.
            [self alertMirrorTVError];
        }
    }
    
    // CM05: Mirror TV 정지 요청.
    if ([notification.name isEqualToString:TR_NO_CM05])
    {
        CM05 *data = [[notification userInfo] objectForKey:CMDataObject];
        NSLog(@"Received data trNo: %@, result: %@", data.trNo, data.result);
        
        // 소켓 종료.
        [SocketManager closeSocket];
    }
    
    // CM06: Mirror TV Heartbeat.
    if ([notification.name isEqualToString:TR_NO_CM06])
    {
        CM06 *data = [[notification userInfo] objectForKey:CMDataObject];
        NSLog(@"Received data trNo: %@, result: %@", data.trNo, data.result);
        
        // 에러가 5번 연속 발생하면 미러TV 서비스를 종료한다.
        NSInteger result = [data.result integerValue];
        if (result != 0)
        {
            _errorCount += 1;
            if (_errorCount == 5)
            {
                // 미러TV 종료.
                [self alertMirrorTVError];
            }
            
            return;
        }
        else
        {
            // 초기화.
            _errorCount = 0;
        }
        
        // TV 상태 확인.
        NSInteger tvStatus = [data.tvStatus integerValue];
        
        switch (tvStatus)
        {
            case 0:
            {
                // 기존 sourceID와 새로 받은 sourceID가 다르면 채널 변경으로 간주한다.
                // 채널 변경 시: player stop -> 이전 HLS URL로 다시 player 시작.
                // !!!: CM04를 재요청하지 않는다.
                NSString *oldSID = [self.channelInfo.sourceID lowercaseString];
                NSString *newSID = [data.sourceID lowercaseString];
                
                // 채널변경 여부.
                if ([oldSID isEqualToString:newSID])
                {
                    return;
                }
                
                // 채널 정보 변경.
                [self changeChannelInfo:data];
                [self setupChannelInfo];
                
                // 블럭 채널 여부 확인.
                if (![self isBlockedChannel:data.sourceID])
                {
                    if (!_isBlockChannel)
                    {
                        // 한 번만 보여주기 위해...
                        [self showNotice:MIRRORTV_ERROR_MSG_INTRO_2];
                    }
                    _isBlockChannel = YES;
                    
                    // 플레이어 중지.
                    [self pause];
                    
                    return;
                }
                else
                {
                    _isBlockChannel = NO;
                    
                    // 로딩 시작.
                    [self adjustLayout:CMMirrorTVStatusLoading];
                    
                    // 플레이어 중지.
                    [self pause];
                    
                    // HLS URL 생성을 위해 AssetID 요청.
                    [self requestAssetID];
                }
            }
                break;
                
            case 1:
            {
                // 채널 정보 변경.
                [self changeChannelInfo:data];
                [self setupChannelInfo];
                
                // VOD.
                [self showNotice:MIRRORTV_ERROR_MSG_VOD];
                
                // 플레이어 중지.
                [self pause];
            }
                break;
                
            case 2:
            {
                // 채널 정보 변경.
                [self changeChannelInfo:data];
                [self setupChannelInfo];
                
                // Others.
                [self showNotice:MIRRORTV_ERROR_MSG_OTHERS];
                
                // 플레이어 중지.
                [self pause];
            }
                break;
                
            case 3:
            {
                // 채널 정보 변경.
                [self changeChannelInfo:data];
                [self setupChannelInfo];
                
                // Blocking Channel.
                [self showNotice:MIRRORTV_ERROR_MSG_BLOCKING_CHANNEL];
                
                // 플레이어 중지.
                [self pause];
            }
                break;
                
            case 4:
            {
                // 채널 정보 변경.
                [self changeChannelInfo:data];
                [self setupChannelInfo];
                
                // Standby.
                [self showNotice:MIRRORTV_ERROR_MSG_STANBY];
            }
                break;
                
            case 5:
            {
                // 채널 정보 변경.
                [self changeChannelInfo:data];
                [self setupChannelInfo];
                
                // UHD.
                [self showNotice:MIRRORTV_ERROR_MSG_UHD];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - 퍼블릭 메서드

// 채널 메뉴로 이동.
- (IBAction)goChannelAction:(id)sender
{
    [self closeAction:sender];
}

// 미러TV 종료.
- (IBAction)closeAction:(id)sender
{
    DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"미러TV"
                                                        message:@"미러TV를 종료하시겠습니까?"
                                                       delegate:self
                                              cancelButtonTitle:@"취소"
                                               otherButtonTitles:@"확인"];
    alertView.shouldDismissOnActionButtonClicked = YES;
    alertView.isLandscape = YES;
    alertView.cancelButtonAction = ^{
        //NSLog(@"Cancel Clicked");
    };
    alertView.otherButtonAction = ^{
        // 타이머 정지.
        [self.heartbeatTimer invalidate];
        
        // 플레이어 종료.
        [self requestStop];
        
        // 미러TV 나가기.
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        // 채널을 선택한 경우.
        if ([(UIButton *)sender tag] == CHANNEL_BUTTON_TAG)
        {
            CMRCViewController *rcViewController = (CMRCViewController *)[CMAppDelegate.container.viewControllers first];
            [rcViewController channelAction:sender];
        }
    };
    [alertView show];
}

// 볼륨 조절.
- (IBAction)volumeAction:(id)sender
{
    NSInteger buttonTag = [(UIButton *)sender tag];

    if (buttonTag == 0)
    {
        if (self.currentVolume < 1.0) {
            // 볼륨 업.
            self.currentVolume += VOLUME_UNIT;
            self.player.volume = self.currentVolume;
        }
    }
    else
    {
        if (self.currentVolume > 0) {
            // 볼륨 다운.
            self.currentVolume -= VOLUME_UNIT;
            self.player.volume = self.currentVolume;
        }
    }
    
    // 볼륨 프로그레스바 UI 설정.
    self.volumeProgressView.hidden = NO;
    [self.volumeProgressView setProgress:self.currentVolume animated:YES];
    
    // 1초 후에 볼륨 프로그레스바 감추가.
    [self performSelector:@selector(hideVolumeProgressView) withObject:nil afterDelay:1];
    
    // 4초 후에 컨트롤 패널 감추기.
    //[NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPannel) object:nil];
    [self performSelector:@selector(hideControlPannel) withObject:nil afterDelay:4];
}

// 볼륨 끄기/켜기.
- (IBAction)volumeMuteAction:(id)sender
{
    // 토글 시 버튼 이미지 변경.
    if (_isMuted)
    {
        self.player.muted = NO;
        [_volumeMuteButton setImage:[UIImage imageNamed:@"M_MuteOff_D"] forState:UIControlStateNormal];
        [_volumeMuteButton setImage:[UIImage imageNamed:@"M_MuteOff_H"] forState:UIControlStateHighlighted];
    }
    else
    {
        self.player.muted = YES;
        [_volumeMuteButton setImage:[UIImage imageNamed:@"M_MuteOn_D"] forState:UIControlStateNormal];
        [_volumeMuteButton setImage:[UIImage imageNamed:@"M_MuteOn_H"] forState:UIControlStateHighlighted];
    }
    
    _isMuted = !_isMuted;
    
    // 4초후에 컨트롤 패널 감추기.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPannel) object:nil];
    [self performSelector:@selector(hideControlPannel) withObject:nil afterDelay:4];
}

// 채널 이동.
- (IBAction)channelAction:(id)sender
{
    NSInteger buttonTag = [(UIButton *)sender tag];
    
    if (buttonTag == 0)
    {
        // 채널 업.
        if (AppInfo.isSecondTV)
        {
            [[RemoteManager sender] sendClickForKey:BTN_GAME_12 error:NULL];
        }
        else
        {
            [[RemoteManager sender] sendClickForKey:KEYCODE_CHANNEL_UP error:NULL];
        }
    }
    else
    {
        // 채널 다운.
        if (AppInfo.isSecondTV)
        {
            [[RemoteManager sender] sendClickForKey:BTN_GAME_13 error:NULL];
        }
        else
        {
            [[RemoteManager sender] sendClickForKey:KEYCODE_CHANNEL_DOWN error:NULL];
        }
    }
    
    // 4초후에 컨트롤 패널 감추기.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPannel) object:nil];
    [self performSelector:@selector(hideControlPannel) withObject:nil afterDelay:4];
}

// 숫자키패드 키코드 반환.
- (int)keycodeForNumberButton:(UIButton *)button
{
    if (AppInfo.isSecondTV)
    {
        switch (button.tag)
        {
            case 0: // 0.
                return BTN_0;
                
            case 1: // 1.
                return BTN_1;
                
            case 2: // 2.
                return BTN_2;
                
            case 3: // 3.
                return BTN_3;
                
            case 4: // 4.
                return BTN_4;
                
            case 5: // 5.
                return BTN_5;
                
            case 6: // 6.
                return BTN_6;
                
            case 7: // 7.
                return BTN_7;
                
            case 8: // 8.
                return BTN_8;
                
            case 9: // 9.
                return BTN_9;
                
            case 10: // 지우기.
                return KEYCODE_DEL;
                
            case 11: // 확인.
                return KEYCODE_ENTER;
                
            default:
                return KEYCODE_UNKNOWN;
        }
    }
    else
    {
        switch (button.tag)
        {
            case 0: // 0.
                return KEYCODE_0;
                
            case 1: // 1.
                return KEYCODE_1;
                
            case 2: // 2.
                return KEYCODE_2;
                
            case 3: // 3.
                return KEYCODE_3;
                
            case 4: // 4.
                return KEYCODE_4;
                
            case 5: // 5.
                return KEYCODE_5;
                
            case 6: // 6.
                return KEYCODE_6;
                
            case 7: // 7.
                return KEYCODE_7;
                
            case 8: // 8.
                return KEYCODE_8;
                
            case 9: // 9.
                return KEYCODE_9;
                
            case 10: // 지우기.
                return KEYCODE_DEL;
                
            case 11: // 확인.
                return KEYCODE_ENTER;
                
            default:
                return KEYCODE_UNKNOWN;
        }
    }
}

// 숫자키.
- (IBAction)numberAction:(id)sender
{
    // 채널번호.
    UIButton *button = (UIButton *)sender;
    self.channelNoIndicatorLabel.hidden = NO;
    
    [[RemoteManager sender] sendClickForKey:[self keycodeForNumberButton:button] error:NULL];
    
    // 컨트롤이 감춰지기 전까지는 번호를 합친다.
    if (button.tag >= 0 && button.tag < 10)
    {
        // 채널 넘버는 3자리까지.
        if ([self.channelNoIndicatorLabel.text length] > 2)
        {
            self.channelNoIndicatorLabel.text = @"";
        }
        
        self.channelNoIndicatorLabel.text = [NSString stringWithFormat:@"%@%@", self.channelNoIndicatorLabel.text, @(button.tag)];
    }
    
    // 끝에서 부터 지운다.
    if (button.tag == 10)
    {
        // 이진 입력된 스트링.
        NSString *before = self.channelNoIndicatorLabel.text;
        
        switch (before.length)
        {
            case 1:
                self.channelNoIndicatorLabel.text = @"";
                break;
                
            case 2:
                self.channelNoIndicatorLabel.text = [before substringToIndex:1];
                break;
                
            case 3:
                self.channelNoIndicatorLabel.text = [before substringToIndex:2];
                break;
                
            default:
                break;
        }
    }
    
    // 4초후에 컨트롤 패널 감추기.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPannel) object:nil];
    [self performSelector:@selector(hideControlPannel) withObject:nil afterDelay:4];
}

#pragma mark - 제스처 델리게이트 메서드

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//    if (touch.view == self.view)
//    {
//        return YES;
//    }
//    
//    return NO;
    return YES;
}

@end


@implementation CMMirrorTVViewController (Player)

#pragma mark -

#pragma mark Player

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
	AVPlayerItem *thePlayerItem = [_player currentItem];
	if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
	{
        /*
         NOTE:
         Because of the dynamic nature of HTTP Live Streaming Media, the best practice
         for obtaining the duration of an AVPlayerItem object has changed in iOS 4.3.
         Prior to iOS 4.3, you would obtain the duration of a player item by fetching
         the value of the duration property of its associated AVAsset object. However,
         note that for HTTP Live Streaming Media the duration of a player item during
         any particular playback session may differ from the duration of its asset. For
         this reason a new key-value observable duration property has been defined on
         AVPlayerItem.
         
         See the AV Foundation Release Notes for iOS 4.3 for more information.
         */
        
		return([_playerItem duration]);
	}
    
	return(kCMTimeInvalid);
}

- (BOOL)isPlaying
{
	return [_player rate] != 0.f;
}

#pragma mark Player Notifications

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *) aNotification
{
	/* After the movie has played to its end time, seek back to time zero
     to play it again */
	seekToZeroBeforePlay = YES;
}

#pragma mark -
#pragma mark Timed metadata
#pragma mark -

- (void)handleTimedMetadata:(AVMetadataItem*)timedMetadata
{
	/* We expect the content to contain plists encoded as timed metadata. AVPlayer turns these into NSDictionaries. */
	if ([(NSString *)[timedMetadata key] isEqualToString:AVMetadataID3MetadataKeyGeneralEncapsulatedObject])
	{
		if ([[timedMetadata value] isKindOfClass:[NSDictionary class]])
		{
			NSDictionary *propertyList = (NSDictionary *)[timedMetadata value];
            
			/* Metadata payload could be the list of ads. */
			NSArray *newAdList = [propertyList objectForKey:@"ad-list"];
			if (newAdList != nil)
			{
				[self updateAdList:newAdList];
				NSLog(@"ad-list is %@", newAdList);
			}
            
			/* Or it might be an ad record. */
			NSString *adURL = [propertyList objectForKey:@"url"];
			if (adURL != nil)
			{
				if ([adURL isEqualToString:@""])
				{
					/* Ad is not playing, so clear text. */
//					self.isPlayingAdText.text = @"";
//                    
//                    [self enablePlayerButtons];
//                    [self enableScrubber]; /* Enable seeking for main content. */
                    
					NSLog(@"enabling seek at %g", CMTimeGetSeconds([_player currentTime]));
				}
				else
				{
					/* Display text indicating that an Ad is now playing. */
//					self.isPlayingAdText.text = @"< Ad now playing, seeking is disabled on the movie controller... >";
//					
//                    [self disablePlayerButtons];
//                    [self disableScrubber]; 	/* Disable seeking for ad content. */
                    
					NSLog(@"disabling seek at %g", CMTimeGetSeconds([_player currentTime]));
				}
			}
		}
	}
}

#pragma mark Ad list

/* Update current ad list, set slider to match current player item seekable time ranges */
- (void)updateAdList:(NSArray *)newAdList
{
//	if (!adList || ![adList isEqualToArray:newAdList])
//	{
//		newAdList = [newAdList copy];
//		[adList release];
//		adList = newAdList;
//        
//		[self sliderSyncToPlayerSeekableTimeRanges];
//	}
}

#pragma mark -
#pragma mark Loading the Asset Keys Asynchronously

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */

- (void)assetFailedToPrepareForPlayback:(NSError *)error
{
    // 로딩 시작.
    [self adjustLayout:CMMirrorTVStatusLoading];
    
    // HLS URL 생성을 위해 AssetID 요청.
    [self requestAssetID];
    
    // 테스트 시 확인 용.
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
//														message:[error localizedFailureReason]
//													   delegate:nil
//											  cancelButtonTitle:@"OK"
//											  otherButtonTitles:nil];
//	[alertView show];
}

#pragma mark Prepare to play asset

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{    
    /* Make sure that the value of each key has loaded successfully. */
	for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
			[self assetFailedToPrepareForPlayback:error];
			return;
		}
		/* If you are also implementing the use of -[AVAsset cancelLoading], add your code here to bail
         out properly in the case of cancellation. */
	}
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
		NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey,
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
								   nil];
		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
	
	/* At this point we're ready to set up for playback of the asset. */
    
//	[self initScrubberTimer];
//	[self enableScrubber];
//	[self enablePlayerButtons];
	
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.playerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
		
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
	
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.playerItem addObserver:self
                      forKeyPath:kStatusKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:CMMirrorTVViewControllerPlayerItemStatusObserverContext];
	
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
	
    seekToZeroBeforePlay = NO;
	
    /* Create new player, if we don't already have one. */
    if (![self player])
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
		
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:CMMirrorTVViewControllerCurrentItemObservationContext];
        
        /* A 'currentItem.timedMetadata' property observer to parse the media stream timed metadata. */
        [self.player addObserver:self
                      forKeyPath:kTimedMetadataKey
                         options:0
                         context:CMMirrorTVViewControllerTimedMetadataObserverContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:CMMirrorTVViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.playerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur*/
        [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
        
//        [self syncPlayPauseButtons];
    }
	
//    [movieTimeControl setValue:0.0];
}

#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark

#pragma mark Key Value Observer for player rate, currentItem, player item status

/* ---------------------------------------------------------
 **  Called when the value at the specified key path relative
 **  to the given object has changed.
 **  Adjust the movie play and pause button controls when the
 **  player item "status" value changes. Update the movie
 **  scrubber control when the player item is ready to play.
 **  Adjust the movie scrubber control when the player item
 **  "rate" value changes. For updates of the player
 **  "currentItem" property, set the AVPlayer for which the
 **  player layer displays visual output.
 **  NOTE: this method is invoked on the main queue.
 ** ------------------------------------------------------- */

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
	/* AVPlayerItem "status" property value observer. */
	if (context == CMMirrorTVViewControllerPlayerItemStatusObserverContext)
	{
//		[self syncPlayPauseButtons];
        
//        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        NSInteger status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
//                [self removePlayerTimeObserver];
//                [self syncScrubber];
//                
//                [self disableScrubber];
//                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                _playerLayerView.playerLayer.hidden = NO;
                _playerLayerView.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
                
                /* Set the AVPlayerLayer on the view to allow the AVPlayer object to display
                 its content. */
                [_playerLayerView.playerLayer setPlayer:_player];
                
                // 플레이 시작.
                [self play];
                [self adjustLayout:CMMirrorTVStatusPlaying];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *thePlayerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:thePlayerItem.error];
            }
                break;
        }
	}
	/* AVPlayer "rate" property value observer. */
	else if (context == CMMirrorTVViewControllerRateObservationContext)
	{
//        [self syncPlayPauseButtons];
	}
	/* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
	else if (context == CMMirrorTVViewControllerCurrentItemObservationContext)
	{
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* New player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
//            [self disablePlayerButtons];
//            [self disableScrubber];
//            
//            self.isPlayingAdText.text = @"";
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [_playerLayerView.playerLayer setPlayer:self.player];
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            [_playerLayerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
//            [self syncPlayPauseButtons];
        }
	}
	/* Observe the AVPlayer "currentItem.timedMetadata" property to parse the media stream
     timed metadata. */
	else if (context == CMMirrorTVViewControllerTimedMetadataObserverContext)
	{
		NSArray *array = [[_player currentItem] timedMetadata];
		for (AVMetadataItem *metadataItem in array)
		{
			[self handleTimedMetadata:metadataItem];
		}
	}
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
    
    return;
}

#pragma mark - DQAlertViewDelegate

//- (void)cancelButtonClickedOnAlertView:(DQAlertView *)alertView {
//    NSLog(@"OK Clicked");
//}
//
//- (void)otherButtonClickedOnAlertView:(DQAlertView *)alertView {
//    NSLog(@"OK Clicked");
//    // 타이머 정지.
//    [self.heartbeatTimer invalidate];
//    
//    // 플레이어 종료.
//    [self requestStop];
//    
//    // 미러TV 나가기.
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [self dismissViewControllerAnimated:YES completion:nil];
//    
//    // 채널을 선택한 경우.
//    if (alertView.tag == CHANNEL_BUTTON_TAG)
//    {
//        CMRCViewController *rcViewController = (CMRCViewController *)[CMAppDelegate.container.viewControllers first];
//        [rcViewController channelAction:nil];
//    }
//}

@end
