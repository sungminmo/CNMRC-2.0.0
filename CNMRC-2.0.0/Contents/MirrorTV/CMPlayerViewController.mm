//
//  CMPlayerViewController.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 26..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMPlayerViewController.h"
#import "DQAlertView.h"
#import "CMRCViewController.h"
#include "keycodes.pb.h"

// 소켓 관련.
#import "CMTRGenerator.h"
#import "CM04.h"
#import "CM05.h"
#import "CM06.h"

using namespace anymote::messages;

// 영상 확장자.
#define HLS_EXTENTION @"m3u8"

// 채널버튼 태그.
#define CHANNEL_BUTTON_TAG 1000

// 볼륨 단위.
#define VOLUME_UNIT 0.0625f

// 미러TV 상태.
typedef NS_ENUM(NSInteger, CMMirrorTVStatus) {
    CMMirrorTVStatusPlaying = 0,
    CMMirrorTVStatusLoading,
    CMMirrorTVStatusError
};

@interface CMPlayerViewController () <CMPlayerViewDelegate>
{
    // 컨트롤 패널 토글(감추기 여부).
    BOOL _isHide;
    
    // Mute 여부.
    BOOL _isMuted;
    
    // 블락채널 여부.
    BOOL _isBlockChannel;
    
    // CM06 에러 횟수.
    NSInteger _errorCount;
}

@property (weak, nonatomic) NSURL *mirrorTVURL;
@property (strong, nonatomic) NSTimer *heartbeatTimer;
@property (strong, nonatomic) NSTimer *hideControlPannelTimer;

// 화면 초기 설정.
- (void)setupLayout;

// 화면 설정.
- (void)adjustLayout:(CMMirrorTVStatus)status;

// 백그라운드 토글.
- (void)toggleBackground:(BOOL)hidden;

// 로딩 토글.
- (void)toggleLoading:(BOOL)hidden;

// 컨트롤패널 토글.
- (void)toggleControl:(BOOL)hidden;

// 채널정보 설정.
- (void)setupChannelInfo;

// 로딩 시작.
- (void)startLoading;

// 로딩 종료.
- (void)stopLoading;

// Asset ID 요청.
- (void)requestAssetID;

// 미러TV 중지 요청.
- (void)requestStop;

// Heartbeat 요청.
- (void)requestHeartbeat;

// 미러TV 스트림 URL 생성.
- (NSURL *)genMirrorTVURL:(NSString *)receivedAssetID;

// 블럭채널 여부.
- (BOOL)isBlockedChannel:(NSString *)sourceID;

// 공지.
- (void)showNotice:(NSString *)msg;

// 플레이이 추가(실행).
- (void)addPlayer;

// 플레이어 삭제(중지).
- (void)removePlayer;

@end

@implementation CMPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 상태바 감추기.
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    // 뷰 로테이션(-90도).
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    rotationTransform = CGAffineTransformRotate(rotationTransform, -M_PI/2);
    self.view.transform = rotationTransform;
    
    // 전문 수신용 옵저버 등록: CM04, CM05, CM06.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM04 object:nil];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM041 object:nil];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM05 object:nil];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM06 object:nil];
    
    // CMO6 heartbeat 타이머 설정(2초마다).
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(requestHeartbeat) userInfo:nil repeats:YES];
    
    // HLS URL 생성을 위해 AssetID 요청.
    //[self requestAssetID];
    
    // 화면 설정.
    [self setupLayout];
    
    // 로딩 시작.
    [self adjustLayout:CMMirrorTVStatusLoading];
    
    // 볼륨 프로그레스바 초기화.
    //[self.volumeProgressView setProgress:self.player.volume animated:YES];
    
    // 현재 볼륨 초기화.
    //self.currentVolume = self.player.volume;
    
    // 테스트.
    [self addPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -  퍼블릭 메서드 -

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
        [self removePlayer];
        
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
    
//    if (buttonTag == 0)
//    {
//        if (self.currentVolume < 1.0) {
//            // 볼륨 업.
//            self.currentVolume += VOLUME_UNIT;
//            self.player.volume = self.currentVolume;
//        }
//    }
//    else
//    {
//        if (self.currentVolume > 0) {
//            // 볼륨 다운.
//            self.currentVolume -= VOLUME_UNIT;
//            self.player.volume = self.currentVolume;
//        }
//    }
//    
//    // 볼륨 프로그레스바 UI 설정.
//    self.volumeProgressView.hidden = NO;
//    [self.volumeProgressView setProgress:self.currentVolume animated:YES];
    
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
        //self.player.muted = NO;
        [_volumeMuteButton setImage:[UIImage imageNamed:@"M_MuteOff_D"] forState:UIControlStateNormal];
        [_volumeMuteButton setImage:[UIImage imageNamed:@"M_MuteOff_H"] forState:UIControlStateHighlighted];
    }
    else
    {
        //self.player.muted = YES;
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

#pragma mark -  프라이빗 메서드 -

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
//    self.loadingView.hidden = hidden;
//    
//    if (hidden)
//    {
//        [self.view sendSubviewToBack:self.loadingView];
//        
//        // 로딩 종료.
//        [self stopLoading];
//    }
//    else
//    {
//        [self.view bringSubviewToFront:self.loadingView];
//        
//        // 로딩 시작.
//        [self startLoading];
//    }
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

- (void)addPlayer
{
    self.playerView.delegate = self;
    //NSURL *URL = [NSURL URLWithString:@"http://192.168.0.35/VideoSample/new/SERV4732.m3u8"];
    //NSURL *URL = [NSURL URLWithString:@"http://192.168.0.35/VideoSample/old/SERV2150.m3u8"];
    NSURL *URL = [NSURL URLWithString:@"http://192.168.0.35/VideoSample/new-2/SERV2257.m3u8"];
    [self.playerView setVideoURL:URL];
    [self.playerView prepareAndPlayAutomatically:YES];
}

- (void)removePlayer
{
    [self.playerView clean];
}

#pragma mark -  CMPlayerView 델리게이트 메서드 -

- (void)playerDidEndPlaying {
    [self.playerView clean];
}

- (void)playerFailedToPlayToEnd {
    NSLog(@"Error: could not play video");
    [self.playerView clean];
}

#pragma mark - 데이터 수신

// CM06: Mirror TV Heartbeat.
- (void)receiveSocketData:(NSNotification *)notification
{
    //NSLog(@"AVPlayer status: %ld - %ld", self.player.status, self.playerItem.status);
    
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
            //[self loadMirrorTV];
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
            //[self loadMirrorTV];
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
                    //[self pause];
                    
                    return;
                }
                else
                {
                    _isBlockChannel = NO;
                    
                    // 로딩 시작.
                    [self adjustLayout:CMMirrorTVStatusLoading];
                    
                    // 플레이어 중지.
                    //[self pause];
                    
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
                //[self pause];
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
                //[self pause];
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
                //[self pause];
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

@end
