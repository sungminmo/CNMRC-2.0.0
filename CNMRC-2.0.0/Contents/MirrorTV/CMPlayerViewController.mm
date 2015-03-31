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

// 애니모트.
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

@interface CMPlayerViewController ()

@end

@implementation CMPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
