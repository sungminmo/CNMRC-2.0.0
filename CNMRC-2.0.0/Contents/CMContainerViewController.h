//
//  CMContainerViewController.h
//  CNMRC-2.0.0
//
//  Created by ParkJong Pil on 2015. 1. 10..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMCircleMenu.h"

@class CMOverlayView;

// 메뉴 타입.
typedef NS_ENUM(NSInteger, CMCircleMenuType) {
    CMCircleMenuTypeChannelVolume = 0,
    CMCircleMenuTypeFourDirection,
    CMCircleMenuTypeMirrotTV,
    CMCircleMenuTypeQwerty,
    CMCircleMenuTypeSettings
};

@interface CMContainerViewController : UINavigationController <CMCircleMenuDelegate, CMHTTPClientDelegate>

@property (strong, nonatomic) CMCircleMenu *circleMenu;
@property (strong, nonatomic) CMOverlayView *backgroundView;
@property (assign, nonatomic) CMCircleMenuType currentCircleMenu;
@property (strong, nonatomic) NSArray *blockChannelInfo;

- (void)toolbarAction:(id)sender;

@end
