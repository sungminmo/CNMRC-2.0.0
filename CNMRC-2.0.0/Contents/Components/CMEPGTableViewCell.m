//
//  CMChannelDetailTableViewCell.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 5..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMEPGTableViewCell.h"

#define HD_ICON_START_X 250.0
#define WATCHING_LEVEL_ICON_START_X 290.0
#define PROGRAM_LABEL_START_X 65.0

@implementation CMEPGTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setupLayout];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        self.timeLabel.textColor = [UIColor whiteColor];
        self.programLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        self.timeLabel.textColor = [UIColor lightGrayColor];
        self.programLabel.textColor = [UIColor darkGrayColor];
    }
}

- (void)setupLayout
{
    // 시간.
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 5.0, 40.0, 34.0)];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.text = @"13:20";
    self.timeLabel.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:self.timeLabel];
    
    // 제목.
    self.programLabel = [[UILabel alloc] initWithFrame:CGRectMake(PROGRAM_LABEL_START_X, 5.0, 180.0, 34.0)];
    self.programLabel.backgroundColor = [UIColor clearColor];
    self.programLabel.text = @"스마일";
    self.programLabel.font = [UIFont boldSystemFontOfSize:15];
    [self addSubview:self.programLabel];
    
    // HD 아이콘.
    self.hdIcon = [[UIImageView alloc] initWithFrame:CGRectMake(HD_ICON_START_X, 12.0, 33.0, 20.0)];
    self.hdIcon.image = [UIImage imageNamed:@"hdicon.png"];
    self.hdIcon.hidden = YES;
    [self addSubview:self.hdIcon];
    
    // 시청등급 아이콘.
    self.wathchingLevelIcon = [[UIImageView alloc] initWithFrame:CGRectMake(WATCHING_LEVEL_ICON_START_X, 12.0, 20.0, 20.0)];
    self.wathchingLevelIcon.image = [UIImage imageNamed:@"ageall.png"];
    self.wathchingLevelIcon.hidden = YES;
    [self addSubview:self.wathchingLevelIcon];
}

- (void)adjustHDIcon:(BOOL)isHD andWatchingLevelIcon:(NSInteger)grade
{
    if (isHD)
    {
        self.hdIcon.hidden = NO;
    }
    else
    {
        self.hdIcon.hidden = YES;
        
        // 등급 아이콘과 제목의 위치를 조절한다.
        self.wathchingLevelIcon.frame = CGRectMake(HD_ICON_START_X, 12.0, 20.0, 20.0);
    }
    
    switch (grade)
    {
        case 0:
            self.wathchingLevelIcon.image = [UIImage imageNamed:@"ageall.png"];
            break;
            
        case 12:
            self.wathchingLevelIcon.image = [UIImage imageNamed:@"age12.png"];
            break;
            
        case 15:
            self.wathchingLevelIcon.image = [UIImage imageNamed:@"age15.png"];
            break;
            
        case 19:
            self.wathchingLevelIcon.image = [UIImage imageNamed:@"age19.png"];
            break;
            
        default:
            self.wathchingLevelIcon.image = [UIImage imageNamed:@"ageall.png"];
            break;
    }
    
    self.wathchingLevelIcon.hidden = NO;
    
    [self layoutSubviews];
}

- (void)resetCell
{
    self.hdIcon.hidden = YES;
    self.hdIcon.frame = CGRectMake(HD_ICON_START_X, 12.0, 33.0, 20.0);
    self.wathchingLevelIcon.hidden = YES;
    self.wathchingLevelIcon.frame = CGRectMake(WATCHING_LEVEL_ICON_START_X, 12.0, 20.0, 20.0);
    self.programLabel.frame = CGRectMake(PROGRAM_LABEL_START_X, 5.0, 180.0, 34.0);
    self.broadcastingDate = nil;
}

@end
