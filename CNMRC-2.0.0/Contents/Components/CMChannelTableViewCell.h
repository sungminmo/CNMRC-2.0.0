//
//  CMChannelTableViewCell.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 5..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTableViewCell.h"

@interface CMChannelTableViewCell : CMTableViewCell

@property (strong, nonatomic) UILabel *channelNoLabel;
@property (strong, nonatomic) UIImageView *channelIcon;
@property (strong, nonatomic) UILabel *programLabel;
@property (strong, nonatomic) UILabel *nextProgramLabel;

@end
