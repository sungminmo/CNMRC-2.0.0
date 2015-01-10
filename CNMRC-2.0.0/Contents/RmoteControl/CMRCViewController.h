//
//  CMRCViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 17..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMNumberKey.h"
#import "CMCVPad.h"
#import "CMTouchPad.h"
#import "CMControlPad.h"

// 리모콘 타입.
typedef NS_ENUM(NSInteger, CMMRemoteControlType) {
    CMMRemoteControlTypeChannelVolume = 0,
    CMMRemoteControlTypeFourDirection,
    CMMRemoteControlTypeControl
};

@class CMTapTracker;

@interface CMRCViewController : UIViewController <CMNumberKeyDelegate, CMCVPadDelegate, CMTouchPadDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *navigation;
@property (weak, nonatomic) IBOutlet UIButton *onOffButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *vodButton;
@property (weak, nonatomic) IBOutlet UIButton *channelButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (assign, nonatomic) CMMRemoteControlType rcType;
@property (strong, nonatomic) CMNumberKey *numberKey;
@property (strong, nonatomic) CMCVPad *cvPad;
@property (strong, nonatomic) CMTouchPad *touchPad;
@property (strong, nonatomic) CMControlPad *controlPad;
@property (strong, nonatomic) CMTapTracker *tapTracker;

- (IBAction)onOffAction:(id)sender;
- (IBAction)homeAction:(id)sender;
- (IBAction)vodAction:(id)sender;
- (IBAction)channelAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (void)toolbarAction:(UIButton *)button;
- (void)goSTBSettings;
- (void)requestLiveTV;
- (void)checkParing;

@end
