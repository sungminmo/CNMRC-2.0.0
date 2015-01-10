//
//  CMDetailListViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 26..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMVODListViewController : CMSlideMenuViewController <CMHTTPClientDelegate>

@property (strong, nonatomic) NSDictionary *data;

@end
