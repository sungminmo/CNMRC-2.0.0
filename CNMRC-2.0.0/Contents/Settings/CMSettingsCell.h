//
//  CMSettingsCell.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 22..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

// 메뉴 타입.
typedef NS_ENUM(NSInteger, CMSettingsCellType) {
    CMSettingsCellTypeSwitch = 0,
    CMSettingsCellTypeSlider,
    CMSettingsCellTypeButton,
    CMSettingsCellTypeLabel
};


@interface CMSettingsCell : UITableViewCell

@property (assign, nonatomic) CMSettingsCellType cellType;

@property (weak, nonatomic) IBOutlet UISwitch *settingsSwitch;
@property (weak, nonatomic) IBOutlet UISlider *settingsSlider;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;

@property (strong, nonatomic) NSString *buttonTitle;

@end
