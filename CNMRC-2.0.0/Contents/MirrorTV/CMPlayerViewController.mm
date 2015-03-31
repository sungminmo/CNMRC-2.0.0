//
//  CMPlayerViewController.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 31..
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

// 플레이어 관련.
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "KxMovieDecoder.h"
#import "KxAudioManager.h"
#import "KxMovieGLView.h"
#import "KxLogger.h"

NSString * const KxMovieParameterMinBufferedDuration = @"KxMovieParameterMinBufferedDuration";
NSString * const KxMovieParameterMaxBufferedDuration = @"KxMovieParameterMaxBufferedDuration";
NSString * const KxMovieParameterDisableDeinterlacing = @"KxMovieParameterDisableDeinterlacing";

////////////////////////////////////////////////////////////////////////////////

static NSString * formatTimeInterval(CGFloat seconds, BOOL isLeft)
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    NSMutableString *format = [(isLeft && seconds >= 0.5 ? @"-" : @"") mutableCopy];
    if (h != 0) [format appendFormat:@"%ld:%0.2ld", h, m];
    else        [format appendFormat:@"%ld", m];
    [format appendFormat:@":%0.2ld", s];
    
    return format;
}

////////////////////////////////////////////////////////////////////////////////

enum {
    
    KxMovieInfoSectionGeneral,
    KxMovieInfoSectionVideo,
    KxMovieInfoSectionAudio,
    KxMovieInfoSectionSubtitles,
    KxMovieInfoSectionMetadata,
    KxMovieInfoSectionCount,
};

enum {
    
    KxMovieInfoGeneralFormat,
    KxMovieInfoGeneralBitrate,
    KxMovieInfoGeneralCount,
};

////////////////////////////////////////////////////////////////////////////////

static NSMutableDictionary * gHistory;

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0

// 애니모트.
using namespace anymote::messages;

// 영상 확장자.
#define HLS_EXTENTION @"m3u8"

// 채널버튼 태그.
#define CHANNEL_BUTTON_TAG 1000

// 볼륨 단위.
#define VOLUME_UNIT 0.0625f

// 컨트롤 패널 감추는 시간 설정.
#define CONTROL_PANNEL_HIDDEN_TIME 4

// Heartbit 시간 설정.
#define HEARTBEAT_TIME 2

// 미러TV 상태.
typedef NS_ENUM(NSInteger, CMMirrorTVStatus) {
    CMMirrorTVStatusPlaying = 0,
    CMMirrorTVStatusLoading,
    CMMirrorTVStatusError
};

@interface CMPlayerViewController ()
{
    KxMovieDecoder      *_decoder;
    dispatch_queue_t    _dispatchQueue;
    NSMutableArray      *_videoFrames;
    NSMutableArray      *_audioFrames;
    NSMutableArray      *_subtitles;
    NSData              *_currentAudioFrame;
    NSUInteger          _currentAudioFramePos;
    CGFloat             _moviePosition;
    BOOL                _disableUpdateHUD;
    NSTimeInterval      _tickCorrectionTime;
    NSTimeInterval      _tickCorrectionPosition;
    NSUInteger          _tickCounter;
    BOOL                _fullscreen;
    BOOL                _hiddenHUD;
    BOOL                _fitMode;
    BOOL                _infoMode;
    BOOL                _restoreIdleTimer;
    BOOL                _interrupted;

    KxMovieGLView       *_glView;
    UIImageView         *_imageView;

#ifdef DEBUG
    UILabel             *_messageLabel;
    NSTimeInterval      _debugStartTime;
    NSUInteger          _debugAudioStatus;
    NSDate              *_debugAudioStatusTS;
#endif

    CGFloat             _bufferedDuration;
    CGFloat             _minBufferedDuration;
    CGFloat             _maxBufferedDuration;
    BOOL                _buffered;
    BOOL                _savedIdleTimer;
    NSDictionary        *_parameters;
    
    // 컨트롤 패널 토글(감추기 여부).
    BOOL _isHideControl;
    
    // Mute 여부.
    BOOL _isMuted;
    
    // 블락채널 여부.
    BOOL _isBlockChannel;
    
    // CM06 에러 횟수.
    NSInteger _errorCount;
}

@property (readwrite) BOOL playing;
@property (readwrite) BOOL decoding;
@property (readwrite, strong) KxArtworkFrame *artworkFrame;
@property (strong, nonatomic) NSTimer *heartbeatTimer;

- (void)setupLayout;
- (void)showLoading;
- (void)hideLoading;
- (void)showBackground;
- (void)hideBackground;
- (void)showControl;
- (void)hideControl;
- (void)changeLayout:(CMMirrorTVStatus)status;
- (void)toggleControl:(BOOL)hidden;
- (void)setupChannelInfo;
- (void)requestAssetID;
- (void)requestStop;
- (void)requestHeartbeat;
- (NSString *)genContentPath:(NSString *)receivedAssetID;
- (BOOL)isBlockedChannel:(NSString *)sourceID;
- (void)showNotice:(NSString *)msg;

@end

@implementation CMPlayerViewController

- (void)dealloc
{
    [self pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_dispatchQueue)
    {
        // ARC일 경우 필요 없음.
        //dispatch_release(_dispatchQueue);
        _dispatchQueue = NULL;
    }
}

+ (void)initialize
{
    if (!gHistory)
        gHistory = [NSMutableDictionary dictionary];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        id<KxAudioManager> audioManager = [KxAudioManager audioManager];
        [audioManager activateAudioSession];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
        
        // disable buffering
        //parameters[KxMovieParameterMinBufferedDuration] = @(0.0f);
        //parameters[KxMovieParameterMaxBufferedDuration] = @(0.0f);
        
        // 테스트 용.
        //[self playWithContentPath:@"http://192.168.0.35/VideoSample/new-2/SERV2257.m3u8" parameters:nil];
        //[self performSelector:@selector(testPlay) withObject:nil afterDelay:5];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 상태바 감추기.
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS 7⬆︎.
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    // Device Rotation Change 옵저버 등록.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    // 전문 수신용 옵저버 등록: CM04, CM05, CM06.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM04 object:nil];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM041 object:nil];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM05 object:nil];
    [nc addObserver:self selector:@selector(receiveSocketData:) name:TR_NO_CM06 object:nil];
    
    // CMO6 heartbeat 타이머 설정(2초마다).
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:HEARTBEAT_TIME target:self selector:@selector(requestHeartbeat) userInfo:nil repeats:YES];
    
    // HLS URL 생성을 위해 AssetID 요청.
    [self requestAssetID];
    
    // 화면 설정.
    [self setupLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
    
    if (_decoder)
    {
        [self pause];
        
        if (_moviePosition == 0 || _decoder.isEOF)
        {
            [gHistory removeObjectForKey:_decoder.path];
        }
        else if (!_decoder.isNetwork)
        {
            [gHistory setValue:[NSNumber numberWithFloat:_moviePosition] forKey:_decoder.path];
        }
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
    _buffered = NO;
    _interrupted = YES;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self pause];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        // 뷰 로테이션(90도).
        CGAffineTransform rotationTransform = CGAffineTransformIdentity;
        rotationTransform = CGAffineTransformRotate(rotationTransform, M_PI/2);
        self.view.transform = rotationTransform;
    }
    
    if (orientation == UIDeviceOrientationLandscapeRight)
    {
        // 뷰 로테이션(-90도).
        CGAffineTransform rotationTransform = CGAffineTransformIdentity;
        rotationTransform = CGAffineTransformRotate(rotationTransform, -M_PI/2);
        self.view.transform = rotationTransform;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.playing)
    {
        [self pause];
        [self freeBufferedFrames];
        
        if (_maxBufferedDuration > 0)
        {
            _minBufferedDuration = _maxBufferedDuration = 0;
            [self play];
            DDLogDebug(@"didReceiveMemoryWarning, disable buffering and continue playing");
        }
        else
        {
            // 강제로 ffmpeg 메모리 해제.
            [_decoder closeFile];
            [_decoder openFile:nil error:nil];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                        message:NSLocalizedString(@"Out of memory", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                              otherButtonTitles:nil] show];
        }
    }
    else
    {
        [self freeBufferedFrames];
        [_decoder closeFile];
        [_decoder openFile:nil error:nil];
    }
}

#pragma mark - 퍼블릭 -

- (void)testPlay {
    [self playWithContentPath:@"http://192.168.0.35/VideoSample/new-2/SERV2257.m3u8" parameters:nil];
}

- (void)playWithContentPath:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSAssert(path.length > 0, @"empty path");
    
    _moviePosition = 0;
    //self.wantsFullScreenLayout = YES;
    _parameters = parameters;
    __weak CMPlayerViewController *weakSelf = self;
    KxMovieDecoder *decoder = [[KxMovieDecoder alloc] init];
    
    decoder.interruptCallback = ^BOOL() {
        __strong CMPlayerViewController *strongSelf = weakSelf;
        return strongSelf ? [strongSelf interruptDecoder] : YES;
    };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        [decoder openFile:path error:&error];
        __strong CMPlayerViewController *strongSelf = weakSelf;
        
        if (strongSelf)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [strongSelf setMovieDecoder:decoder withError:error];
                [self restorePlay];
                [self hideLoading];
            });
        }
    });
}

- (void)play
{
    if (self.playing)
        return;
    
    if (!_decoder.validVideo && !_decoder.validAudio)
    {
        return;
    }
    
    if (_interrupted)
    {
        return;
    }
    
    self.playing = YES;
    _interrupted = NO;
    _disableUpdateHUD = NO;
    _tickCorrectionTime = 0;
    _tickCounter = 0;
    
#ifdef DEBUG
    _debugStartTime = -1;
#endif
    
    [self asyncDecodeFrames];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self tick];
    });
    
    if (_decoder.validAudio)
    {
        [self enableAudio:YES];
    }
    
    DDLogDebug(@"미러TV 플레이");
}

- (void)pause
{
    if (!self.playing)
    {
        return;
    }
    
    self.playing = NO;
    //_interrupted = YES;
    [self enableAudio:NO];
    DDLogDebug(@"미러TV 일시 정지");
}

- (void)setMoviePosition:(CGFloat)position
{
    BOOL playMode = self.playing;
    
    self.playing = NO;
    _disableUpdateHUD = YES;
    [self enableAudio:NO];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self updatePosition:position playMode:playMode];
    });
}

#pragma mark - 액션

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
    alertView.disappearAnimationType = DQAlertViewAnimationTypeNone;
    alertView.isLandscape = YES;
    alertView.cancelButtonAction = ^{
        DDLogDebug(@"Cancel Clicked");
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
        // 볼륨 업.
        [[RemoteManager sender] sendClickForKey:KEYCODE_VOLUME_UP error:NULL];
    }
    else
    {
        // 볼륨 다운.
        [[RemoteManager sender] sendClickForKey:KEYCODE_VOLUME_DOWN error:NULL];
    }
    
    // 4초후에 컨트롤 패널 감추기.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControl) object:nil];
    [self performSelector:@selector(hideControl) withObject:nil afterDelay:CONTROL_PANNEL_HIDDEN_TIME];
}

// 볼륨 끄기/켜기.
- (IBAction)volumeMuteAction:(id)sender
{
    // 토글 시 버튼 이미지 변경.
    if (_isMuted)
    {
        [_volumeMuteButton setImage:[UIImage imageNamed:@"M_MuteOff_D"] forState:UIControlStateNormal];
        [_volumeMuteButton setImage:[UIImage imageNamed:@"M_MuteOff_H"] forState:UIControlStateHighlighted];
    }
    else
    {
        [_volumeMuteButton setImage:[UIImage imageNamed:@"M_MuteOn_D"] forState:UIControlStateNormal];
        [_volumeMuteButton setImage:[UIImage imageNamed:@"M_MuteOn_H"] forState:UIControlStateHighlighted];
    }
    
    _isMuted = !_isMuted;
    
    [[RemoteManager sender] sendClickForKey:KEYCODE_MUTE error:NULL];
    
    // 4초후에 컨트롤 패널 감추기.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControl) object:nil];
    [self performSelector:@selector(hideControl) withObject:nil afterDelay:CONTROL_PANNEL_HIDDEN_TIME];
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControl) object:nil];
    [self performSelector:@selector(hideControl) withObject:nil afterDelay:CONTROL_PANNEL_HIDDEN_TIME];
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
        
        self.channelNoIndicatorLabel.text = [NSString stringWithFormat:@"%@%d", self.channelNoIndicatorLabel.text, (int)button.tag];
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControl) object:nil];
    [self performSelector:@selector(hideControl) withObject:nil afterDelay:CONTROL_PANNEL_HIDDEN_TIME];
}

#pragma mark - 프라이빗

- (void)setMovieDecoder:(KxMovieDecoder *)decoder withError:(NSError *)error
{
    if (!error && decoder)
    {
        _decoder        = decoder;
        _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
        _videoFrames    = [NSMutableArray array];
        _audioFrames    = [NSMutableArray array];
        
        if (_decoder.subtitleStreamsCount)
        {
            _subtitles = [NSMutableArray array];
        }
        
        if (_decoder.isNetwork)
        {
            _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
        } else
        {
            _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
        }
        
        if (!_decoder.validVideo)
            _minBufferedDuration *= 10.0; // increase for audio
        
        // allow to tweak some parameters at runtime
        if (_parameters.count)
        {
            id val;
            
            val = [_parameters valueForKey: KxMovieParameterMinBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _minBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: KxMovieParameterMaxBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _maxBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: KxMovieParameterDisableDeinterlacing];
            if ([val isKindOfClass:[NSNumber class]])
                _decoder.disableDeinterlacing = [val boolValue];
            
            if (_maxBufferedDuration < _minBufferedDuration)
                _maxBufferedDuration = _minBufferedDuration * 2;
        }
        
        DDLogDebug(@"buffered limit: %.1f - %.1f", _minBufferedDuration, _maxBufferedDuration);
        
        if (self.isViewLoaded)
        {
            [self setupPresentView];
        }
    }
    else
    {
        if (self.isViewLoaded && self.view.window)
        {
            if (!_interrupted)
                [self handleDecoderMovieError: error];
        }
    }
}

- (void)restorePlay
{
    NSNumber *n = [gHistory valueForKey:_decoder.path];
    if (n)
        [self updatePosition:n.floatValue playMode:YES];
    else
        [self play];
}

- (void)setupPresentView
{
    CGRect bounds = self.view.bounds;
    
    if (_decoder.validVideo)
    {
        _glView = [[KxMovieGLView alloc] initWithFrame:bounds decoder:_decoder];
    }
    
    if (!_glView)
    {
        DDLogWarn(@"fallback to use RGB video frame and UIKit");
        [_decoder setupVideoFrameFormat:KxVideoFrameFormatRGB];
        _imageView = [[UIImageView alloc] initWithFrame:bounds];
        _imageView.backgroundColor = [UIColor blackColor];
    }
    
    UIView *frameView = [self frameView];
    frameView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view insertSubview:frameView atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
}

// TODO: 이 곳에서 에러 처리?
- (UIView *)frameView
{
    return _glView ? _glView : _imageView;
}

- (void)audioCallbackFillData:(float *)outData numFrames:(UInt32)numFrames numChannels:(UInt32)numChannels
{
    //fillSignalF(outData,numFrames,numChannels);
    //return;
    
    if (_buffered)
    {
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }
    
    @autoreleasepool {
        
        while (numFrames > 0) {
            
            if (!_currentAudioFrame) {
                
                @synchronized(_audioFrames) {
                    
                    NSUInteger count = _audioFrames.count;
                    
                    if (count > 0) {
                        
                        KxAudioFrame *frame = _audioFrames[0];
                        
#ifdef DUMP_AUDIO_DATA
                        LoggerAudio(2, @"Audio frame position: %f", frame.position);
#endif
                        if (_decoder.validVideo) {
                            
                            const CGFloat delta = _moviePosition - frame.position;
                            
                            if (delta < -0.1) {
                                
                                memset(outData, 0, numFrames * numChannels * sizeof(float));
#ifdef DEBUG
                                LoggerStream(0, @"desync audio (outrun) wait %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 1;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                break; // silence and exit
                            }
                            
                            [_audioFrames removeObjectAtIndex:0];
                            
                            if (delta > 0.1 && count > 1) {
                                
#ifdef DEBUG
                                LoggerStream(0, @"desync audio (lags) skip %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 2;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                continue;
                            }
                            
                        } else {
                            
                            [_audioFrames removeObjectAtIndex:0];
                            _moviePosition = frame.position;
                            _bufferedDuration -= frame.duration;
                        }
                        
                        _currentAudioFramePos = 0;
                        _currentAudioFrame = frame.samples;
                    }
                }
            }
            
            if (_currentAudioFrame) {
                
                const void *bytes = (Byte *)_currentAudioFrame.bytes + _currentAudioFramePos;
                const NSUInteger bytesLeft = (_currentAudioFrame.length - _currentAudioFramePos);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    _currentAudioFramePos += bytesToCopy;
                else
                    _currentAudioFrame = nil;
                
            } else {
                
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                //LoggerStream(1, @"silence audio");
#ifdef DEBUG
                _debugAudioStatus = 3;
                _debugAudioStatusTS = [NSDate date];
#endif
                break;
            }
        }
    }
}

- (void)enableAudio:(BOOL)on
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    
    if (on && _decoder.validAudio) {
        
        audioManager.outputBlock = ^(float *outData, UInt32 numFrames, UInt32 numChannels) {
            
            [self audioCallbackFillData: outData numFrames:numFrames numChannels:numChannels];
        };
        
        [audioManager play];
        DDLogDebug(@"audio device smr: %d fmt: %d chn: %d",
                   (int)audioManager.samplingRate,
                   (int)audioManager.numBytesPerSample,
                   (int)audioManager.numOutputChannels);
    }
    else
    {
        [audioManager pause];
        audioManager.outputBlock = nil;
    }
}

- (BOOL)addFrames:(NSArray *)frames
{
    if (_decoder.validVideo)
    {
        @synchronized(_videoFrames)
        {
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeVideo)
                {
                    [_videoFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
        }
    }
    
    if (_decoder.validAudio)
    {
        @synchronized(_audioFrames)
        {
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeAudio)
                {
                    [_audioFrames addObject:frame];
                    if (!_decoder.validVideo)
                        _bufferedDuration += frame.duration;
                }
        }
        
        if (!_decoder.validVideo)
        {
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeArtwork)
                    self.artworkFrame = (KxArtworkFrame *)frame;
        }
    }
    
    if (_decoder.validSubtitles)
    {
        @synchronized(_subtitles)
        {
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeSubtitle)
                {
                    [_subtitles addObject:frame];
                }
        }
    }
    
    return self.playing && _bufferedDuration < _maxBufferedDuration;
}

- (BOOL)decodeFrames
{
    //NSAssert(dispatch_get_current_queue() == _dispatchQueue, @"bugcheck");
    
    NSArray *frames = nil;
    
    if (_decoder.validVideo || _decoder.validAudio)
    {
        frames = [_decoder decodeFrames:0];
    }
    
    if (frames.count)
    {
        return [self addFrames: frames];
    }
    return NO;
}

- (void)asyncDecodeFrames
{
    if (self.decoding)
        return;
    
    __weak CMPlayerViewController *weakSelf = self;
    __weak KxMovieDecoder *weakDecoder = _decoder;
    
    const CGFloat duration = _decoder.isNetwork ? .0f : 0.1f;
    
    self.decoding = YES;
    dispatch_async(_dispatchQueue, ^{
        
        {
            __strong CMPlayerViewController *strongSelf = weakSelf;
            if (!strongSelf.playing)
                return;
        }
        
        BOOL good = YES;
        while (good) {
            
            good = NO;
            
            @autoreleasepool
            {
                __strong KxMovieDecoder *decoder = weakDecoder;
                
                if (decoder && (decoder.validVideo || decoder.validAudio))
                {
                    NSArray *frames = [decoder decodeFrames:duration];
                    if (frames.count) {
                        
                        __strong CMPlayerViewController *strongSelf = weakSelf;
                        if (strongSelf)
                            good = [strongSelf addFrames:frames];
                    }
                }
            }
        }
        
        {
            __strong CMPlayerViewController *strongSelf = weakSelf;
            if (strongSelf) strongSelf.decoding = NO;
        }
    });
}

- (void)tick
{
    if (_buffered && ((_bufferedDuration > _minBufferedDuration) || _decoder.isEOF))
    {
        _tickCorrectionTime = 0;
        _buffered = NO;
        //[_activityIndicatorView stopAnimating];
    }
    
    CGFloat interval = 0;
    if (!_buffered)
        interval = [self presentFrame];
    
    if (self.playing)
    {
        const NSUInteger leftFrames =
        (_decoder.validVideo ? _videoFrames.count : 0) +
        (_decoder.validAudio ? _audioFrames.count : 0);
        
        if (0 == leftFrames)
        {
            if (_decoder.isEOF)
            {
                [self pause];
                //[self updateHUD];
                return;
            }
            
            if (_minBufferedDuration > 0 && !_buffered)
            {
                _buffered = YES;
                //[_activityIndicatorView startAnimating];
            }
        }
        
        if (!leftFrames || !(_bufferedDuration > _minBufferedDuration))
        {
            [self asyncDecodeFrames];
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0.01);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self tick];
        });
    }
    
    if ((_tickCounter++ % 3) == 0)
    {
        //[self updateHUD];
    }
}

- (CGFloat)tickCorrection
{
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime)
    {
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    //if ((_tickCounter % 200) == 0)
    //    LoggerStream(1, @"tick correction %.4f", correction);
    
    if (correction > 1.f || correction < -1.f)
    {
        LoggerStream(1, @"tick correction reset %.2f", correction);
        correction = 0;
        _tickCorrectionTime = 0;
    }
    
    return correction;
}

- (CGFloat)presentFrame
{
    CGFloat interval = 0;
    
    if (_decoder.validVideo)
    {
        KxVideoFrame *frame;
        
        @synchronized(_videoFrames)
        {
            if (_videoFrames.count > 0)
            {
                frame = _videoFrames[0];
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
        }
        
        if (frame)
            interval = [self presentVideoFrame:frame];
    }
    else if (_decoder.validAudio)
    {
        //interval = _bufferedDuration * 0.5;
        
        if (self.artworkFrame) {
            
            _imageView.image = [self.artworkFrame asImage];
            self.artworkFrame = nil;
        }
    }
    
    if (_decoder.validSubtitles)
        //[self presentSubtitles];
    
#ifdef DEBUG
    if (self.playing && _debugStartTime < 0)
        _debugStartTime = [NSDate timeIntervalSinceReferenceDate] - _moviePosition;
#endif
    
    return interval;
}

- (CGFloat)presentVideoFrame:(KxVideoFrame *)frame
{
    if (_glView)
    {
        [_glView render:frame];
    }
    else
    {
        KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB *)frame;
        _imageView.image = [rgbFrame asImage];
    }
    
    _moviePosition = frame.position;
    
    return frame.duration;
}

- (void)fullscreenMode:(BOOL)on
{
    _fullscreen = on;
    UIApplication *app = [UIApplication sharedApplication];
    [app setStatusBarHidden:on withAnimation:UIStatusBarAnimationNone];
    // if (!self.presentingViewController) {
    //[self.navigationController setNavigationBarHidden:on animated:YES];
    //[self.tabBarController setTabBarHidden:on animated:YES];
    // }
}

- (void)setMoviePositionFromDecoder
{
    _moviePosition = _decoder.position;
}

- (void)setDecoderPosition: (CGFloat) position
{
    _decoder.position = position;
}

- (void)enableUpdateHUD
{
    _disableUpdateHUD = NO;
}

- (void)updatePosition:(CGFloat)position playMode:(BOOL)playMode
{
    [self freeBufferedFrames];
    
    position = MIN(_decoder.duration - 1, MAX(0, position));
    
    __weak CMPlayerViewController *weakSelf = self;
    
    dispatch_async(_dispatchQueue, ^{
        
        if (playMode)
        {
            {
                __strong CMPlayerViewController *strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf setDecoderPosition: position];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong CMPlayerViewController *strongSelf = weakSelf;
                if (strongSelf)
                {
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf play];
                }
            });
        }
        else
        {
            {
                __strong CMPlayerViewController *strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf setDecoderPosition: position];
                [strongSelf decodeFrames];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong CMPlayerViewController *strongSelf = weakSelf;
                if (strongSelf) {
                    
                    [strongSelf enableUpdateHUD];
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf presentFrame];
                    //[strongSelf updateHUD];
                }
            });
        }
    });
}

- (void)freeBufferedFrames
{
    @synchronized(_videoFrames)
    {
        [_videoFrames removeAllObjects];
    }
    
    @synchronized(_audioFrames)
    {
        [_audioFrames removeAllObjects];
        _currentAudioFrame = nil;
    }
    
    if (_subtitles)
    {
        @synchronized(_subtitles)
        {
            [_subtitles removeAllObjects];
        }
    }
    
    _bufferedDuration = 0;
}

- (void)handleDecoderMovieError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (BOOL)interruptDecoder
{
    //if (!_decoder)
    //    return NO;
    return _interrupted;
}

// 화면 설정.
- (void)setupLayout
{
    // 뷰 로테이션(-90도).
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    rotationTransform = CGAffineTransformRotate(rotationTransform, -M_PI/2);
    self.view.transform = rotationTransform;
    
    // 탭 제스처: 플레이어 컨트롤 토글 용.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeTapGesture:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
    // 컨트롤 토글 초기화.
    _isHideControl = YES;
    
    // 에러 횟수 초기화.
    _errorCount = 0;
    
    // 채널 정보 설정.
    [self setupChannelInfo];
}

// 제스처 콜백.
- (void)recognizeTapGesture:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // 플레이어 컨트롤을 토글 시킨다.
        [self toggleControl:_isHideControl];
    }
}

// 로딩 보이기.
- (void)showLoading
{
    self.loadingView.hidden = NO;
    [self.loadingImageView startAnimating];
}

// 로딩 감추기.
- (void)hideLoading
{
    self.loadingView.hidden = YES;
    [self.loadingImageView stopAnimating];
}

// 에러 표시: 백그라운드 보이기.
- (void)showBackground
{
    self.backgroundView.hidden = NO;
}

// 에러 표시: 백그라운드 감추기.
- (void)hideBackground
{
    self.backgroundView.hidden = YES;
}

// 컨르롤 보이기.
- (void)showControl
{
    self.controlPannel.hidden = NO;
    _isHideControl = NO;
}

// 컨트롤 감추가.
- (void)hideControl
{
    self.controlPannel.hidden = YES;
    _isHideControl = YES;
}

// 레이아웃 변경.
- (void)changeLayout:(CMMirrorTVStatus)status
{
    switch (status)
    {
        case CMMirrorTVStatusPlaying:
        {
            [self hideBackground];
            [self hideLoading];
            [self showControl];
        }
            break;
            
        case CMMirrorTVStatusLoading:
        {
            [self hideBackground];
            [self showLoading];
            [self hideControl];
        }
            break;
            
        case CMMirrorTVStatusError:
        {
            [self showBackground];
            [self hideLoading];
            [self hideControl];
        }
            break;
            
        default:
            break;
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
        [self hideControl];
    }
    else
    {
        [self showControl];
    }
    
    _isHideControl = !_isHideControl;
}

// 채널 정보 설정.
- (void)setupChannelInfo
{
    // 제목.
    self.titleLabel.text = self.channelInfo.programTitle;
    
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

// CM04: AssetID 요청.
- (void)requestAssetID
{
    // 로딩 시작.
    [self showLoading];
    
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

// 박스의 이름에서 IP를 가져온다.
// 예: stb_catv_cnm-192-168-0-131
- (NSString *)genAddress:(NSString *)boxName
{
    // 앞의 박스 이름을 제외하고 IP 부분만 가져온다.
    NSString *address = [boxName substringFromIndex:13];
    
    // "-"를 "."로 치환한다.
    return [address stringByReplacingOccurrencesOfString:@"-" withString:@"."];
}

// 미러TV 서버 패스 생성.
- (NSString *)genContentPath:(NSString *)receivedAssetID;
{
    if (!receivedAssetID) return nil;
    
    // 앞에서 8자리까지가 AssetID 이다.
    NSString *assetID = [receivedAssetID substringToIndex:8];
    NSString *address = [RemoteManager.currentBox.addresses objectAtIndex:0];
    
    return [NSString stringWithFormat:@"http://%@/%@.%@", address, assetID, HLS_EXTENTION];
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
    
    [self changeLayout:CMMirrorTVStatusError];
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

#pragma mark - 제스처 델리게이트 메서드

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - 데이터 수신

// CM06: Mirror TV Heartbeat.
- (void)receiveSocketData:(NSNotification *)notification
{
    // CM04: Mirror TV 실행 요청.
    if ([notification.name isEqualToString:TR_NO_CM04])
    {
        CM04 *data = [[notification userInfo] objectForKey:CMDataObject];
        NSLog(@"Received data trNo: %@, result: %@", data.trNo, data.result);
        
        NSInteger result = [data.result integerValue];
        if (result == 0)
        {
            // 플레이.
            [self playWithContentPath:[self genContentPath:data.assetID] parameters:nil];
            DDLogDebug(@"MirrorTV URL: %@", [self genContentPath:data.assetID]);
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
            // SecondTV 설정.
            if ([data.secondTV isEqualToString:@"1"]) {
                AppInfo.isSecondTV = YES;
            }
            
            // 플레이.
//            [self playWithContentPath:[self genContentPath:data.assetID] parameters:nil];
//            DDLogDebug(@"MirrorTV URL: %@", [self genContentPath:data.assetID]);
            
            // 테스트 용.
            [self testPlay];
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
                
            default:
                break;
        }
    }
}

@end
