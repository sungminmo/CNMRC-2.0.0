//
//  CMRCViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 17..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMRCViewController.h"
#include "keycodes.pb.h"
#import "CMVODViewController.h"
#import "CMChannelViewController.h"
#import "CMSearchViewController.h"
#import "CMBoxListViewController.h"
#import "DQAlertView.h"
#import "CMTapTracker.h"

using namespace anymote::messages;

static const CGFloat kMinScaleToZoomIn = 1.8;
static const CGFloat kMaxScaleToZoomOut = (1.0 / 1.8);

@interface CMRCViewController ()
{
    BOOL _isVolumeMuted;
}
@end

@implementation CMRCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 화면 설정.
    [self setupLayout];
    
    // TODO:
    // 페어링 확인.(최초)
    //[RemoteManager checkPairing];
    
    if (isiOS7)
    {
        self.navigation.center = CGPointMake(self.navigation.center.x, self.navigation.center.y + 20);
        
        // 상태바 백그라운드.
        UIView *statusBarBackground = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] statusBarFrame]];
        statusBarBackground.backgroundColor = [UIColor whiteColor];// UIColorFromRGB(0x252525);
        [self.view addSubview:statusBarBackground];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setOnOffButton:nil];
    [self setHomeButton:nil];
    [self setVodButton:nil];
    [self setChannelButton:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
}

- (void)setRcType:(CMMRemoteControlType)rcType
{
    if (rcType == CMMRemoteControlTypeChannelVolume)
    {
        // 채널/볼륨.
        if (self.cvPad)
        {
            self.cvPad.hidden = NO;
            [self.view bringSubviewToFront:self.cvPad];
            self.touchPad.hidden = YES;
            self.controlPad.hidden = YES;
        }
    }
    else if (rcType == CMMRemoteControlTypeFourDirection)
    {
        // 사방향키.
        if (self.touchPad)
        {
            self.touchPad.hidden = NO;
            [self.view bringSubviewToFront:self.touchPad];
            self.cvPad.hidden = YES;
            self.controlPad.hidden = YES;
        }
    }
    else
    {
        // 컨트롤(트릭플레이) 패드.
        if (self.controlPad)
        {
            self.controlPad.hidden = NO;
            [self.view bringSubviewToFront:self.controlPad];
            self.cvPad.hidden = YES;
            self.touchPad.hidden = YES;
        }
    }
}

#pragma mark - 프라이빗 메서드

- (void)setupLayout
{
    // 백그라운드 컬러.
    self.view.backgroundColor = UIColorFromRGB(0x252525);
    
    // 라운드 백그라운드.
    self.bg.backgroundColor = [UIColor whiteColor];
    self.bg.layer.cornerRadius = 9.9;
    self.bg.layer.masksToBounds = YES;
    
    // 라운드 박스.
    self.roundBox.backgroundColor = UIColorFromRGB(0xf4f4f4);
    self.roundBox.layer.cornerRadius = 9.9;
    self.roundBox.layer.masksToBounds = YES;
    
    // 사방향키.
    self.touchPad.delegate = self;
    
    CommandHandler *commandHandler = [RemoteManager commandHandler];
    if (!_tapTracker) {
        _tapTracker = [[CMTapTracker alloc] initWithBackgroundView:self.touchPad
                                                    commandHandler:commandHandler];
        [self.touchPad setTouchHandler:_tapTracker];
    }
    
    // 사방향키 패드에 제스처 추가.
    // 상.
//    UISwipeGestureRecognizer *up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeSwipeGesture:)];
//    up.direction = UISwipeGestureRecognizerDirectionUp;
//    up.numberOfTouchesRequired = 1;
//    [self.touchPad addGestureRecognizer:up];
//    
//    // 하.
//    UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeSwipeGesture:)];
//    down.direction = UISwipeGestureRecognizerDirectionDown;
//    down.numberOfTouchesRequired = 1;
//    [self.touchPad addGestureRecognizer:down];
//    
//    // 좌.
//    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeSwipeGesture:)];
//    left.direction = UISwipeGestureRecognizerDirectionLeft;
//    left.numberOfTouchesRequired = 1;
//    [self.touchPad addGestureRecognizer:left];
//    
//    // 우.
//    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeSwipeGesture:)];
//    right.direction = UISwipeGestureRecognizerDirectionRight;
//    right.numberOfTouchesRequired = 1;
//    [self.touchPad addGestureRecognizer:right];
    
    // 애니메이션과 트랙(터치)패드을 위한 팬 제스처 추가.
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    pan.delegate = self;
    pan.minimumNumberOfTouches = 2;
    pan.maximumNumberOfTouches = 2;
    [self.touchPad addGestureRecognizer:pan];
    
    // 줌을 위핸 핀치 제처처 추가.
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.touchPad addGestureRecognizer:pinch];
    
    // 트릭플레이 패드.
//    CMControlPad *ctr = [[[NSBundle mainBundle] loadNibNamed:DeviceSpecificSetting(@"CMControlPadSD", @"CMControlPad") owner:self options:nil] objectAtIndex:0];
//    //ctr.delegate = self;
//    ctr.frame = padBackground.bounds;
//    [padBackground addSubview:ctr];
//    self.controlPad = ctr;
//    
//    // 채널/볼륨 패드.
//    CMCVPad *cv = [[[NSBundle mainBundle] loadNibNamed:DeviceSpecificSetting(@"CMCVPadSD", @"CMCVPad") owner:self options:nil] objectAtIndex:0];
//    cv.delegate = self;
//    cv.frame = padBackground.bounds;
//    [padBackground addSubview:cv];
//    self.cvPad = cv;
    
    // 숫자키패드.
    self.numberKey.delegate = self;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

// 사방향키 패드의 상/하/좌/우 스와이프 제스처.
- (void)recognizeSwipeGesture:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.view == self.touchPad)
    {
        switch (recognizer.direction)
        {
            case UISwipeGestureRecognizerDirectionUp:
            {
                [[RemoteManager sender] sendClickForKey:KEYCODE_CHANNEL_UP error:NULL];
            }
                break;
                
            case UISwipeGestureRecognizerDirectionDown:
            {
                [[RemoteManager sender] sendClickForKey:KEYCODE_CHANNEL_DOWN error:NULL];
            }
                break;
                
            case UISwipeGestureRecognizerDirectionLeft:
            {
                [[RemoteManager sender] sendClickForKey:KEYCODE_VOLUME_DOWN error:NULL];
            }
                break;
                
            case UISwipeGestureRecognizerDirectionRight:
            {
                [[RemoteManager sender] sendClickForKey:KEYCODE_VOLUME_UP error:NULL];
            }
                break;
                
            default:
                break;
        }
    }
}

// 애니메이션을 위한 팬 제스처.
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    switch(recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [recognizer setTranslation:CGPointZero inView:self.view];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [recognizer locationInView:recognizer.view];
            
            // 애니메이션.
            if (point.y > 0 && point.y < self.touchPad.frame.size.height)
                [self.touchPad touchAnimation:point];
            
            CGPoint translation = [recognizer translationInView:self.view];
            [recognizer setTranslation:CGPointZero inView:self.view];
            [RemoteManager.commandHandler scrollDeltaX:translation.x deltaY:translation.y];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {

        }
           
            break;
        default:
            break;
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    // !!!: 트랙패들일 경우 얼럿을 띄우지 않는다.
    if (AppInfo.isPaired == NO)
    {
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        CGFloat scale = [recognizer scale];
        if (scale > kMinScaleToZoomIn)
        {
            [RemoteManager.commandHandler sendZoomIn];
        }
        else if (scale < kMaxScaleToZoomOut)
        {
            [RemoteManager.commandHandler sendZoomOut];
        }
    }
}

// 채널/볼륨 버튼 키코드 반환.
- (int)keycodeForCVButton:(UIButton *)button
{
    switch (button.tag)
    {
        case 0: // OK
            return KEYCODE_ENTER;
            
        case 1: // 볼륨 업.
            return KEYCODE_VOLUME_UP;
            
        case 2: // 볼륨 다운.
            return KEYCODE_VOLUME_DOWN;
            
        case 3: // 채널 업.
            return KEYCODE_CHANNEL_UP;
            
        case 4: // OK.
            return KEYCODE_CHANNEL_DOWN;
            
        case 5: // 음소거 토글.
            return KEYCODE_MUTE;
            
        default:
            return KEYCODE_UNKNOWN;
    }
}

// 숫자키패드 키코드 반환.
- (int)keycodeForNumberButton:(UIButton *)button
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

// 4방향키 키코드 반환.
- (int)keycodeForFourDirectionButton:(UIButton *)button
{
    switch (button.tag)
    {
        case 0: // 상.
            return KEYCODE_DPAD_UP;
            
        case 1: // 좌.
            return KEYCODE_DPAD_LEFT;
            
        case 2: // 하.
            return KEYCODE_DPAD_DOWN;
            
        case 3: // 우.
            return KEYCODE_DPAD_RIGHT;
            
        case 4: // OK.
            return KEYCODE_DPAD_CENTER;
            
        default:
            return KEYCODE_UNKNOWN;
    }
}

#pragma mark - 퍼블릭 메서드

// STB Power on/off.
- (IBAction)onOffAction:(id)sender
{
    [[RemoteManager sender] sendClickForKey:KEYCODE_STB_POWER error:NULL];
}

// home.
- (IBAction)homeAction:(id)sender
{
    [[RemoteManager sender] sendClickForKey:KEYCODE_GUIDE error:NULL];
}

//  VOD.
- (IBAction)vodAction:(id)sender
{
    CMVODViewController *viewController = [[CMVODViewController alloc] initWithNibName:@"CMVODViewController" bundle:nil];
    viewController.menuType = CMMenuTypeVOD;
    viewController.viewControllerType = CMViewControllerTypeList;
    viewController.selectedMenuIndex = 0;
    [self.navigationController pushViewController:viewController animated:YES];
}

// 채널.
- (IBAction)channelAction:(id)sender
{
    CMChannelViewController *viewController = [[CMChannelViewController alloc] initWithNibName:@"CMChannelViewController" bundle:nil];
    viewController.menuType = CMMenuTypeChannel;
     viewController.viewControllerType = CMViewControllerTypeList;
    [self.navigationController pushViewController:viewController animated:YES];
}

// 검색.
- (IBAction)searchAction:(id)sender
{
    CMSearchViewController *viewController = [[CMSearchViewController alloc] initWithNibName:@"CMSearchViewController" bundle:nil];
    viewController.menuType = CMMenuTypeSearch;
    [self.navigationController pushViewController:viewController animated:YES];
}

// 툴바 버튼의 액션 처리(키코드를 사용하는 경우...)
- (void)toolbarAction:(UIButton *)button
{
    switch (button.tag)
    {
        case CMMenuTypePrevious: // 이전.
            [[RemoteManager sender] sendClickForKey:KEYCODE_BACK error:NULL];
            break;
            
        case CMMenuTypeGreen: // 선호채널.
            [[RemoteManager sender] sendClickForKey:KEYCODE_PROG_GREEN error:NULL];
            break;
            
        case CMMenuTypeYellow: //  보기전환.
            [[RemoteManager sender] sendClickForKey:KEYCODE_PROG_YELLOW error:NULL];
            break;
            
        case CMMenuTypeOut: // 나가기.
            [[RemoteManager sender] sendClickForKey:BTN_GAME_14 error:NULL];
            break;
            
        default:
            break;
    }
}

// 셋탑박스 설정.
- (void)goSTBSettings
{
    [[RemoteManager sender] sendClickForKey:KEYCODE_SETTINGS error:NULL];
}

// 라이브TV(MirrorTV)
- (void)requestLiveTV
{
    [[RemoteManager sender] sendClickForKey:KEYCODE_LIVE error:NULL];
}

// 페어링 여부.
- (void)checkParing
{
    //[RemoteManager checkPairing];
}

#pragma mark - CMNumberKeyDelegate

- (void)selectedNumberKey:(UIButton *)numberKey
{
    NSInteger selectedKey = [(UIButton *)numberKey tag];
    NSLog(@"Selected number key: %ld", (long)selectedKey);
    
    [[RemoteManager sender] sendClickForKey:[self keycodeForNumberButton:numberKey] error:NULL];
}

#pragma mark - CMCVPadDelegate

- (void)cvPad:(CMCVPad *)pad selectedKey:(UIButton *)key
{
    NSInteger selectedKey = [(UIButton *)key tag];
    NSLog(@"Selected channel/volume key: %ld", (long)selectedKey);
    
    if (selectedKey == 5)
    {
        // 음소거 버튼.
        if (!_isVolumeMuted)
        {
            [key setImage:[UIImage imageNamed:@"mute_off.png"] forState:UIControlStateNormal];
            [key setImage:[UIImage imageNamed:@"mute_off.png"] forState:UIControlStateHighlighted];
        }
        else
        {
            [key setImage:[UIImage imageNamed:@"mute_off.png"] forState:UIControlStateNormal];
            [key setImage:[UIImage imageNamed:@"mute_off.png"] forState:UIControlStateHighlighted];
        }
        _isVolumeMuted = !_isVolumeMuted;
    }
    
    [[RemoteManager sender] sendClickForKey:[self keycodeForCVButton:key] error:NULL];
}

#pragma mark - CMTouchPadDelegate

// 4방향키/동영상 컨트롤키.
- (void)touchPad:(CMTouchPad *)pad selectedKey:(UIButton *)key
{
    NSInteger selectedKey = [(UIButton *)key tag];
    NSLog(@"Selected touch pad key: %ld", (long)selectedKey);
    
    [[RemoteManager sender] sendClickForKey:[self keycodeForFourDirectionButton:key] error:NULL];
}

@end
