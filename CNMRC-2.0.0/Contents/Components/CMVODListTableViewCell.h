//
//  CMDetailTableViewCell.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 26..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTableViewCell.h"

@interface CMVODListTableViewCell : CMTableViewCell

@property (strong, nonatomic) UIImageView *screenshotImageView;
@property (strong, nonatomic) UIImageView *hdIcon;
@property (strong, nonatomic) UIImageView *wathchingLevelIcon;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *directorLabel;
@property (strong, nonatomic) UILabel *castingLabel;

// HD 유무.
@property (assign, nonatomic) BOOL isHD;

// VOD 등급.
@property (assign, nonatomic) NSInteger vodGrade;

@end
