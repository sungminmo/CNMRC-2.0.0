//
//  CMSlideMenuViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 5..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBaseViewController.h"

// 메뉴 타입.
typedef NS_ENUM(NSInteger, CMViewControllerType) {
    CMViewControllerTypeList = 0,
    CMViewControllerTypeView
};

/**
 *	VOD/채널에 사용할 부모 컨트롤러이다.
 */
@interface CMSlideMenuViewController : CMBaseViewController <UITableViewDataSource, UITableViewDelegate, CMHTTPClientDelegate>

// 뷰컨트롤러 타입.
@property (assign, nonatomic) CMViewControllerType viewControllerType;

// 현재 선택된 슬라이드메뉴 인덱스.
@property (assign, nonatomic) NSInteger selectedMenuIndex;

// 슬라이드 메뉴.
@property (strong, nonatomic) UITableView *menuTable;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSArray *menus;

// 목록.
@property (strong, nonatomic) UITableView *listTable;
@property (strong, nonatomic) NSMutableArray *lists;

// 상세.
@property (weak, nonatomic) IBOutlet UIView *detailView;

- (IBAction)slideAction:(id)sender;
- (void)requestData:(CMMenuType)menuType subMenuIndex:(NSInteger)index withDelegate:(id)delegate;

// 채널의 방송 시간은 반환 한다.
- (NSString *)programTime:(NSString *)date;

// GetChannelSchedule에서 사용할 날짜 인덱스(DateIndex: 0 ~ 6) 반환.
- (NSString *)dateIndex:(NSDate *)date;

// 현재시간 기준으로 시청 가능한 프로그램 여부 판다.
- (BOOL)isPossibleWatchTV:(NSString *)currentTime andNextTime:(NSString *)nextTime;

// 프로그램 방송시간(문자열)을 NSDate로 변환한다.
- (NSDate *)dateFromStringBroadcastingTime:(NSString *)broadcastingTime;

// UIRefreshControl을 이용한 데이터 갱신.
- (void)handleRefreshList:(UIRefreshControl *)refreshControl;

// 성인인증 확인.
- (void)checkAdult;

@end
