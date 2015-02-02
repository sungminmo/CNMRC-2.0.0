//
//  CMSettingsCell.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 22..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMSettingsCell.h"

@implementation CMSettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellType:(CMSettingsCellType)cellType
{
    switch (cellType)
    {
        case CMSettingsCellTypeSwitch:
        {
            self.settingsSwitch.hidden = NO;
            //[self insertSubview:self.settingsSwitch aboveSubview:self.contentView];
        }
            break;
            
        case CMSettingsCellTypeSlider:
        {
            self.settingsSlider.minimumTrackTintColor = UIColorFromRGB(0x7961aa);
            self.settingsSlider.hidden = NO;
            [self insertSubview:self.settingsSlider aboveSubview:self.contentView];
        }
            break;
            
        case CMSettingsCellTypeButton:
        {
            self.settingsButton.hidden = NO;
            if (self.buttonTitle)
            {
                [self.settingsButton setTitle:self.buttonTitle forState:UIControlStateNormal];
            }

            [self insertSubview:self.settingsButton aboveSubview:self.contentView];
        }
            break;
            
        case CMSettingsCellTypeLabel:
        {
            self.settingsLabel.hidden = NO;
            self.settingsLabel.textColor = UIColorFromRGB(0x7961aa);
            [self insertSubview:self.settingsLabel aboveSubview:self.contentView];
        }
            break;
            
        default:
            break;
    }
}

@end
