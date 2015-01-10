//
//  CMAuthAdultViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 8..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBaseViewController.h"

// 메뉴 타입.
typedef NS_ENUM(NSInteger, CMAuthAdultViewType) {
    CMAuthAdultViewTypeSettings = 0,
    CMAuthAdultViewTypeVOD
};

@interface CMAuthAdultViewController : CMBaseViewController <UITextFieldDelegate, CMHTTPClientDelegate>

@property (assign, nonatomic) CMAuthAdultViewType authAdultViewType;

@property (weak, nonatomic) IBOutlet UIView *warningView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ssnTextField;
@property (weak, nonatomic) IBOutlet UISwitch *autoAuthAdultSwitch;

- (IBAction)textFieldAction:(id)sender;
- (IBAction)switchAction:(id)sender;


@end
