//
//  CMDetailViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 26..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMVODDetailViewController.h"
#import "CMTableViewCell.h"
#import "NSString+Helper.h"
#import "NSDate+Helper.h"
#import "UILabel+Size.h"
#import "DQAlertView.h"
#import "WishList.h"

// 소켓 관련.
#import "CMTRGenerator.h"
#import "CM01.h"
#include "CM02.h"

#define HD_ICON_START_X 256.0
#define HD_ICON_START_Y 9.0
#define HD_ICON_WIDTH 33.0
#define WATCHING_LEVEL_ICON_START_X 295.0
#define WATCHING_LEVEL_ICON_WIDTH 20.0
#define WATCHING_LEVEL_ICON_HEIGHT 20.0
#define TITLE_START_X 73.0
#define TITLE_WIDTH 241.0
#define TITLE_HEIGHT 21.0

#define SYNOPSIS_TEXTVIEW_FRAME CGRectMake(0.0, 263.0, 320.0, 100.0)
#define SYNOPSIS_TEXTVIEW_FIVE_FRAME CGRectMake(0.0, 263.0, 320.0, 187.0)

@interface CMVODDetailViewController ()
- (void)bindData;
@end

@implementation CMVODDetailViewController

- (void)dealloc
{   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    // Do any additional setup after loading the view from its nib.
    
    self.titleLabel.text = @"상세보기";
    
    // 데이터 바인딩.
    [self bindData];
    
    // 전문 수신용 옵저버 등록: CM01, CM02.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(receiveData:) name:TR_NO_CM01 object:nil];
    [nc addObserver:self selector:@selector(receiveData:) name:TR_NO_CM02 object:nil];
}

- (void)viewDidUnload
{
    [self setHdIcon:nil];
    [self setWathchingLevelIcon:nil];
    [self setMovieTitleLabel:nil];
    [self setDirectorLabel:nil];
    [self setCastingLabel:nil];
    [self setWatchingLevelLabel:nil];
    [self setPriceLabel:nil];
    [self setSynopsisTextView:nil];
    [self setScreenshotImageView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 상속 메서드

- (void)setupLayout
{
    [super setupLayout];
    
    CGFloat paddingY = 0.0;
    if (isiOS7)
    {
        paddingY = 20.0;
    }
    
    CGFloat detailViewWidth = 0;
    switch ([LPPhoneVersion deviceSize]) {
        case iPhone55inch:
            detailViewWidth = 414;
            break;
            
        case iPhone47inch:
            detailViewWidth = 375;
            break;
            
        default:
            detailViewWidth = 320;
            break;
    }
    
    self.detailView.frame = CGRectMake(0.0, 55.0 + paddingY, detailViewWidth, self.view.frame.size.height + paddingY);
    [self.contentView addSubview:self.detailView];
    
    // 슬라이드메뉴 스와이프 제스처 추가.
    
    // 좌.
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeSwipeGesture:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    left.numberOfTouchesRequired = 1;
    [self.detailView addGestureRecognizer:left];
    
    // 우.
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeSwipeGesture:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    right.numberOfTouchesRequired = 1;
    [self.detailView addGestureRecognizer:right];
    
    // 줄거리 텍스트뷰 프레임 설정.
    //self.synopsisTextView.frame = DeviceSpecificSetting(SYNOPSIS_TEXTVIEW_FRAME, SYNOPSIS_TEXTVIEW_FIVE_FRAME);
}

// 목록의 좌/우 스와이프 제스처.
- (void)recognizeSwipeGesture:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.view == self.detailView)
    {
        [self slideAction:recognizer];
    }
}

#pragma mark - 프라이빗 메서드

- (void)bindData
{
    if (self.data == nil)
        return;
    
    // HD 아이콘.
    BOOL _isHD = [[self.data valueForKey:@"VOD_HD"] boolValue];
    
    // 타이틀 라벨 사이즈.
    CGSize maxSize = CGSizeMake(241.0, 21.0);
    CGSize size = [self.titleLabel calcLabelSizeWithString: [self.data valueForKey:@"VOD_Title"] andMaxSize:maxSize];
    
    if (!_isHD)
    {
        self.hdIcon.hidden = YES;
        
        // 등급 아이콘 위치를 조절한다.
//        self.wathchingLevelIcon.frame = CGRectMake(size.width + 5, HD_ICON_START_Y, WATCHING_LEVEL_ICON_WIDTH, WATCHING_LEVEL_ICON_HEIGHT);
    }
    else
    {
        // HD와 등급 아이콘 위치를 조절한다.
//        self.hdIcon.frame = CGRectMake(size.width + 5, HD_ICON_START_Y, HD_ICON_WIDTH, WATCHING_LEVEL_ICON_WIDTH);
//        self.wathchingLevelIcon.frame = CGRectMake(self.hdIcon.frame.origin.x + HD_ICON_WIDTH + 5, HD_ICON_START_Y, WATCHING_LEVEL_ICON_WIDTH, WATCHING_LEVEL_ICON_HEIGHT);
    }
    
    // VOD 등급.
    self.wathchingLevelIcon.image = [self vodIcon:[[self.data valueForKey:@"VOD_Grade"] integerValue]];
    
    // 제목.
    self.movieTitleLabel.text = [self.data valueForKey:@"VOD_Title"];
    
    // 포스터 이미지.
    self.screenshotImageView.imageURL = [NSURL URLWithString:[self.data valueForKey:@"VOD_IMG"]];
    
    // 감독.
    self.directorLabel.text = [self.data valueForKey:@"VOD_Director"];
    
    // 출연.
    self.castingLabel.text = [self.data valueForKey:@"VOD_Actor"];
    
    // 관람등급.
    self.watchingLevelLabel.text = [self.data valueForKey:@"VOD_Grade"];
    
    // 가격.
    self.priceLabel.text = [NSString stringWithFormat:@"%@원", [[self.data valueForKey:@"VOD_Price"] formatNumber]];
    
    // 시놉시스.
    self.synopsisTextView.text = [self.data valueForKey:@"VOD_Contents"];
}

#pragma mark - 퍼블릭 메서드

// VOD 찜하기.
- (IBAction)wishListAction:(id)sender
{
    // STB 연결상태 확인.
    if (RemoteManager.appState == kAppStateConnected)
    {
        // 연결이 되어 있는 경우.
        NSString *address = [RemoteManager.currentBox.addresses objectAtIndex:0];
        [SocketManager openSocketWithAddress:address andPort:27351];
        
        // 전문 생성.
        CMTRGenerator *generator = [[CMTRGenerator alloc] init];
        NSDate *currentDate = [NSDate date];
        NSString *tr = [generator genCM01WithDate:[currentDate stringFromDateWithType:StringFromDateTypeNetwork] assetID:[self.data valueForKey:@"VOD_ID"]];
        
        // 데이터 전송.
        [SocketManager sendData:tr];
    }
    else
    {
        // 연결이 안되어 있는 경우: 10개까지 로컬에 저장한다, 그리고 STB가 연결되면 일괄 전송한다.
        DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                            message:@"셋톱박스가 연결이 되어 있지 않습니다.\n폰에 저장한 후 셋톱박스가 연결되면 일괄 저장 됩니다!"
                                                  cancelButtonTitle:nil
                                                   otherButtonTitle:@"확인"];
        alertView.shouldDismissOnActionButtonClicked = YES;
        alertView.otherButtonAction = ^{
            DDLogDebug(@"OK Clicked");
            WishList *wishList = [WishList create];
            wishList.assetID = [self.data valueForKey:@"VOD_ID"];
            wishList.date = [NSDate date];
            [wishList save];
        };
        
        [alertView show];
    }
}

// 테스트용.
- (void)sendData
{
    // 전문 생성.
    CMTRGenerator *generator = [[CMTRGenerator alloc] init];
    //NSString *tr = [generator genCM01WithDate:@"20131125125344" assetID:@"www.hchoice.co.kr|M0264852LFO180044101"];
    //NSString *tr = [generator genCM02WithAssetID:@"www.hchoice.co.kr|M0264852LFO180044101"];
    NSString *tr = [generator genCM03];
    
    // 데이터 전송.
    [SocketManager sendData:tr];
}

// VOD TV에서 보기.
- (IBAction)mirroringAction:(id)sender
{
    // STB 연결상태 확인.
    if (RemoteManager.appState == kAppStateConnected)
    {
        // 연결이 되어 있는 경우.
        NSString *address = [RemoteManager.currentBox.addresses objectAtIndex:0];
        [SocketManager openSocketWithAddress:address andPort:27351];
        
        // 전문 생성.
        CMTRGenerator *generator = [[CMTRGenerator alloc] init];
        NSString *tr = [generator genCM02WithAssetID:[self.data valueForKey:@"VOD_ID"]];
        
        // 데이터 전송.
        [SocketManager sendData:tr];
    }
    else
    {
        // 연결이 안되어 있는 경우.
        DQAlertView *alertView = [[DQAlertView alloc] initWithTitle:@"알림"
                                                            message:@"셋톱박스가 연결되어 있지 않습니다!"
                                                  cancelButtonTitle:@"확인"
                                                   otherButtonTitle:nil];        
        [alertView show];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.menuTable)
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.menuTable)
    {
        // 현재 선택된 슬라이드메뉴 인덱스.
        self.selectedMenuIndex = indexPath.row;
        
        // 메뉴 테이블 처리.
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.menuTable)
    {
        // 메뉴 테이블 처리.
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 데이터 수신

// TODO: 에러처리 어떻게 할 지 결정할 것!
// CM01, CM02 전문은 에러처리만 한다.
- (void)receiveData:(NSNotification *)notification
{
    // VOD 찜하기.
    if ([notification.name isEqualToString:TR_NO_CM01])
    {
        CM01 *data = [[notification userInfo] objectForKey:CMDataObject];
        DDLogDebug(@"Received data trNo: %@, result: %@", data.trNo, data.result);
    }
    
    // VOD TV에서 보기.
    if ([notification.name isEqualToString:TR_NO_CM02])
    {
        CM02 *data = [[notification userInfo] objectForKey:CMDataObject];
        DDLogDebug(@"Received data trNo: %@, result: %@", data.trNo, data.result);
    }
}

@end
