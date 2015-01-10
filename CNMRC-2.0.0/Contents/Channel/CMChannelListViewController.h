//
//  CMChannelListViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 6..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMSlideMenuViewController.h"

@interface CMChannelListViewController : CMSlideMenuViewController <CMHTTPClientDelegate>

@property (strong, nonatomic) NSDictionary *data;

@end
