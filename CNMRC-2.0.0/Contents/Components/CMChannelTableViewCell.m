//
//  CMChannelTableViewCell.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 5..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMChannelTableViewCell.h"

@implementation CMChannelTableViewCell

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
        self.channelNoLabel.textColor = [UIColor whiteColor];
        self.programLabel.textColor = [UIColor whiteColor];
        self.nextProgramLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        self.channelNoLabel.textColor = [UIColor blackColor];
        self.programLabel.textColor = [UIColor darkGrayColor];
        self.nextProgramLabel.textColor = [UIColor lightGrayColor];
    }
}

- (void)setupLayout
{
    // 채널 번호.
    self.channelNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 40.0, 34.0)];
    self.channelNoLabel.backgroundColor = [UIColor clearColor];
    self.channelNoLabel.text = @"101";
    self.channelNoLabel.font = [UIFont boldSystemFontOfSize:17];
    [self addSubview:self.channelNoLabel];
    
    // 채널 로고.
    self.channelIcon = [[UIImageView alloc] initWithFrame:CGRectMake(40.0, 0.0, 80.0, 45.0)];
    self.channelIcon.backgroundColor = [UIColor clearColor];
    self.channelIcon.image = [UIImage imageNamed:@"sbs.jpg"];
    [self addSubview:self.channelIcon];
    
    CGFloat titleLabelWidth = 0;
    switch ([LPPhoneVersion deviceSize]) {
        case iPhone55inch:
            titleLabelWidth = 220;
            break;
            
        case iPhone47inch:
            titleLabelWidth = 200;
            break;
            
        default:
            titleLabelWidth = 170;
            break;
    }
    
    // 제목.
    self.programLabel = [[UILabel alloc] initWithFrame:CGRectMake(125.0, 4.0, titleLabelWidth, 18.0)];
    self.programLabel.backgroundColor = [UIColor clearColor];
    self.programLabel.textColor = [UIColor darkGrayColor];
    self.programLabel.text = @"13:20 스마일";
    self.programLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:self.programLabel];
    
    // 부제목.
    self.nextProgramLabel = [[UILabel alloc] initWithFrame:CGRectMake(125.0, 24.0, titleLabelWidth, 18.0)];
    self.nextProgramLabel.backgroundColor = [UIColor clearColor];
    self.nextProgramLabel.textColor = [UIColor lightGrayColor];
    self.nextProgramLabel.text = @"13:40(자막)우리동네이모저모";
    self.nextProgramLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.nextProgramLabel];
}

@end
