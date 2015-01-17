//
//  UIToolbar+FlatUI.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIToolbar+FlatUI.h"
#import "UIImage+FlatUI.h"
#import "CMDepthIndicator.h"

#define LOGO_TAG 200
#define INDICATOR_TAG 201

@implementation UIToolbar (FlatUI)

static char storedIsOpened;

- (NSString *)isClosed
{
    return objc_getAssociatedObject(self, &storedIsOpened);
}

- (void)setIsClosed:(NSString *)isClosed
{
    objc_setAssociatedObject(self, &storedIsOpened, isClosed, OBJC_ASSOCIATION_COPY);
}

- (void)configureFlatToolbarWithColor:(UIColor *)color
{
    [self setBackgroundImage:[UIImage imageWithColor:color cornerRadius:0]
          forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    // 화면설정.
    [self setupLayout];
}

- (void)setupLayout
{
    self.isClosed = @"NO";
    
    // 이전 버튼.
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.tag = CMMenuTypePrevious;
    previousButton.frame = CGRectMake(12.0, 6.0, 32.0, 32.0);
    [previousButton setImage:[UIImage imageNamed:@"Previous_D"] forState:UIControlStateNormal];
    [previousButton setBackgroundImage:[UIImage imageNamed:@"icon_pre_press@2x.png"] forState:UIControlStateHighlighted];
    [previousButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:previousButton];
    
    // 그런(선호채널) 버튼.
    UIButton *greenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    greenButton.tag = CMMenuTypeGreen;
    greenButton.frame = CGRectMake(52.0, 6.0, 66.0, 32.0);
    [greenButton setImage:[UIImage imageNamed:@"Green_D"] forState:UIControlStateNormal];
    [greenButton setImage:[UIImage imageNamed:@"bottom_icon_green@2x.png"] forState:UIControlStateHighlighted];
    [greenButton setBackgroundImage:[UIImage imageNamed:@"icon_green_yellow_press@2x.png"] forState:UIControlStateHighlighted];
    [greenButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:greenButton];
    
    // 그런 버튼 터치 확장용.
    UIButton *greenButtonMask = [UIButton buttonWithType:UIButtonTypeCustom];
    greenButtonMask.tag = CMMenuTypeGreen;
    greenButtonMask.frame = CGRectMake(52.0, 6.0, 62.0, 40.0);
    [greenButtonMask setBackgroundImage:[UIImage imageNamed:@"icon_green_yellow_press@2x.png"] forState:UIControlStateHighlighted];
    [greenButtonMask addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:greenButtonMask];
    
    // 메뉴 버튼.
    UIButton *circleMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    circleMenuButton.tag = CMMenuTypeCircle;
    circleMenuButton.frame = CGRectMake(129.0, -8.0, 63.0, 52.0);
    [circleMenuButton setBackgroundImage:[UIImage imageNamed:@"RCMenu_D"] forState:UIControlStateNormal];
    [circleMenuButton setBackgroundImage:[UIImage imageNamed:@"rcmenu_btn_press@2x.png"] forState:UIControlStateHighlighted];
    [circleMenuButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:circleMenuButton];
    
    // 옐로우(보기전환) 버튼.
    UIButton *yellowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    yellowButton.tag = CMMenuTypeYellow;
    yellowButton.frame = CGRectMake(206.0, 6.0, 66.0, 32.0);
    [yellowButton setImage:[UIImage imageNamed:@"Yellow_D"] forState:UIControlStateNormal];
    [yellowButton setImage:[UIImage imageNamed:@"bottom_icon_yellow@2x.png"] forState:UIControlStateHighlighted];
    [yellowButton setBackgroundImage:[UIImage imageNamed:@"icon_green_yellow_press@2x.png"] forState:UIControlStateHighlighted];
    [yellowButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:yellowButton];
    
    // 옐로우 버튼 터치 확장용.
    UIButton *yellowButtonMask = [UIButton buttonWithType:UIButtonTypeCustom];
    yellowButtonMask.tag = CMMenuTypeYellow;
    yellowButtonMask.frame = CGRectMake(206.0, 6.0, 62.0, 40.0);
    [yellowButtonMask setBackgroundImage:[UIImage imageNamed:@"icon_green_yellow_press@2x.png"] forState:UIControlStateHighlighted];
    [yellowButtonMask addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:yellowButtonMask];
    
    // 나가기 버튼.
    UIButton *outButton = [UIButton buttonWithType:UIButtonTypeCustom];
    outButton.tag = CMMenuTypeOut;
    outButton.frame = CGRectMake(280.0, 6.0, 32.0, 32.0);
    [outButton setImage:[UIImage imageNamed:@"Exit_D"] forState:UIControlStateNormal];
    [outButton setBackgroundImage:[UIImage imageNamed:@"icon_pre_press@2x.png"] forState:UIControlStateHighlighted];
    [outButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:outButton];
    
    // 툴바의 버튼을 숨길때 사용할 로고.
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"c&mremotecontrol.png"]];
    logo.tag = LOGO_TAG;
    logo.frame = CGRectMake(10.0, 17.0, 103.0, 10.0);
    logo.hidden = YES;
    [self addSubview:logo];
    
    // VOD/Channel 메뉴 진입 시 사용되는 Depth 인디케이터.
    CMDepthIndicator *indicator = [[CMDepthIndicator alloc] initWithFrame:CGRectMake(231.0, 17.5, 79.0, 9.0)];
    indicator.tag = INDICATOR_TAG;
    indicator.hidden = YES;
    [self addSubview:indicator];
    
}

// 컨테이너로 메시지 전달.
- (IBAction)buttonAction:(id)sender
{
    [CMAppDelegate.container toolbarAction:sender];
}

// 툴바 열기.
- (void)openToolbar
{
    if ([self.isClosed isEqualToString:@"NO"]) { return; }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                        [self viewWithTag:LOGO_TAG].hidden = YES;
                        [self viewWithTag:INDICATOR_TAG].hidden = YES;
                    }
                     completion:^(BOOL finished) {
                         
                     }];
    
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            subview.hidden = NO;
        }
    }
    
    self.isClosed = @"NO";
}

// 툴바 닫기.
- (void)closeToolbar
{
    if ([self.isClosed isEqualToString:@"YES"]) { return; }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self viewWithTag:LOGO_TAG].hidden = NO;
                         CMDepthIndicator *indicator = (CMDepthIndicator *)[self viewWithTag:INDICATOR_TAG];
                         indicator.hidden = NO;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]] && subview.tag != CMMenuTypeCircle)
        {
            subview.hidden = YES;
        }
    }
    
    self.isClosed = @"YES";
}

// 인디케이터 보여주기.
- (void)showIndicator:(NSInteger)depth
{
    CMDepthIndicator *indicator = (CMDepthIndicator *)[self viewWithTag:INDICATOR_TAG];
    [indicator showIndicator:depth];
}

@end
