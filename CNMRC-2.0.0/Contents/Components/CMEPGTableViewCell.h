//
//  CMChannelDetailTableViewCell.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 5..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTableViewCell.h"

@interface CMEPGTableViewCell : CMTableViewCell

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *programLabel;
@property (strong, nonatomic) UIImageView *hdIcon;
@property (strong, nonatomic) UIImageView *wathchingLevelIcon;

// 방송날짜/시간.
@property (strong, nonatomic) NSDate *broadcastingDate;

- (void)resetCell;
- (void)adjustHDIcon:(BOOL)isHD andWatchingLevelIcon:(NSInteger)grade;

@end
