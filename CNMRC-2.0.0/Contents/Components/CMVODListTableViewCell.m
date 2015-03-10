//
//  CMDetailTableViewCell.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 26..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMVODListTableViewCell.h"

#define HD_ICON_START_X 231.0
#define HD_ICON_START_Y 6.0
#define HD_ICON_WIDTH 33.0
#define WATCHING_LEVEL_ICON_START_X 270.0
#define WATCHING_LEVEL_ICON_WIDTH 20.0
#define WATCHING_LEVEL_ICON_HEIGHT 20.0
#define TITLE_START_X 71.0
#define TITLE_WIDTH 160.0
#define TITLE_HEIGHT 21.0
#define PADDING 10

@implementation CMVODListTableViewCell

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
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        self.titleLabel.textColor = [UIColor whiteColor];
        self.directorLabel.textColor = [UIColor whiteColor];
        self.castingLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        self.titleLabel.textColor = [UIColor blackColor];
        self.directorLabel.textColor = [UIColor darkGrayColor];
        self.castingLabel.textColor = [UIColor darkGrayColor];
    }
}

- (void)setIsHD:(BOOL)isHD
{
    if (_isHD != isHD)
    {
        _isHD = isHD;
        
        if (!_isHD)
        {
            self.hdIcon.hidden = YES;
            
            // 등급 아이콘과 제목의 위치를 조절한다.
            CGFloat titleLabelWidth = 0;
            switch ([LPPhoneVersion deviceSize]) {
                case iPhone55inch:
                    titleLabelWidth = 230.0;
                    break;
                    
                case iPhone47inch:
                    titleLabelWidth = 200.0;
                    break;
                    
                default:
                    titleLabelWidth = 160.0;
                    break;
            }
            
            self.wathchingLevelIcon.frame = CGRectMake(TITLE_START_X + titleLabelWidth, HD_ICON_START_Y, WATCHING_LEVEL_ICON_WIDTH, WATCHING_LEVEL_ICON_HEIGHT);
            
            [self layoutSubviews];
        }
    }
}

- (void)setVodGrade:(NSInteger)vodGrade
{
    if (_vodGrade != vodGrade)
    {
        _vodGrade = vodGrade;
        
        switch (_vodGrade)
        {
            case 0:
                self.wathchingLevelIcon.image = [UIImage imageNamed:@"Age_All"];
                break;
                
            case 12:
                self.wathchingLevelIcon.image = [UIImage imageNamed:@"Age_12"];
                break;
                
            case 15:
                self.wathchingLevelIcon.image = [UIImage imageNamed:@"Age_15"];
                break;
                
            case 19:
                self.wathchingLevelIcon.image = [UIImage imageNamed:@"Age_19"];
                break;
                
            default:
                self.wathchingLevelIcon.image = [UIImage imageNamed:@"Age_All"];
                break;
        }
    }
}

- (void)setupLayout
{
    // 디자인을 위해...
    _isHD = YES;
    
    // 이미지.
    self.screenshotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 1.5, 53.0, 68.5)];
    self.screenshotImageView.image = [UIImage imageNamed:@"Empty_Image_List"];
    [self addSubview:self.screenshotImageView];
    
    // 제목.
    CGFloat titleLabelWidth = 0;
    switch ([LPPhoneVersion deviceSize]) {
        case iPhone55inch:
            titleLabelWidth = 230.0;
            break;
            
        case iPhone47inch:
            titleLabelWidth = 200.0;
            break;
            
        default:
            titleLabelWidth = 160.0;
            break;
    }
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_START_X, HD_ICON_START_Y - 1, titleLabelWidth, TITLE_HEIGHT)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = @"미스터고";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self addSubview:self.titleLabel];
    
    // HD 아이콘.
    self.hdIcon = [[UIImageView alloc] initWithFrame:CGRectMake(TITLE_START_X + titleLabelWidth, HD_ICON_START_Y, HD_ICON_WIDTH, 20.0)];
    self.hdIcon.image = [UIImage imageNamed:@"HD"];
    [self addSubview:self.hdIcon];
    
    // 시청등급 아이콘.
    self.wathchingLevelIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.hdIcon.frame.origin.x + HD_ICON_WIDTH + PADDING, HD_ICON_START_Y, WATCHING_LEVEL_ICON_WIDTH, WATCHING_LEVEL_ICON_HEIGHT)];
    self.wathchingLevelIcon.image = [UIImage imageNamed:@"Age_All"];
    [self addSubview:self.wathchingLevelIcon];
    
    // 감독.
    self.directorLabel = [[UILabel alloc] initWithFrame:CGRectMake(71.0, 31.0, 229.0, 21.0)];
    self.directorLabel.backgroundColor = [UIColor clearColor];
    self.directorLabel.text = @"감독: 김용화";
    self.directorLabel.font = [UIFont boldSystemFontOfSize:15];
    self.directorLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:self.directorLabel];
    
    // 출연.
    CGFloat castingLabelWidth = 0;
    switch ([LPPhoneVersion deviceSize]) {
        case iPhone55inch:
            castingLabelWidth = 300.0;
            break;
            
        case iPhone47inch:
            castingLabelWidth = 250.0;
            break;
            
        default:
            castingLabelWidth = 229.0;
            break;
    }
    
    self.castingLabel = [[UILabel alloc] initWithFrame:CGRectMake(71.0, 50.0, castingLabelWidth, 21.0)];
    self.castingLabel.backgroundColor = [UIColor clearColor];
    self.castingLabel.text = @"출연: 성동일, 서교";
    self.castingLabel.font = [UIFont boldSystemFontOfSize:15];
    self.castingLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:self.castingLabel];
}

@end
