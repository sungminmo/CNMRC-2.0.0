//
//  CMDetailViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 26..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBaseViewController.h"

@interface CMVODDetailViewController : CMSlideMenuViewController

@property (weak, nonatomic) IBOutlet UIImageView *hdIcon;
@property (weak, nonatomic) IBOutlet UIImageView *wathchingLevelIcon;
@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *screenshotImageView;
@property (weak, nonatomic) IBOutlet UILabel *directorLabel;
@property (weak, nonatomic) IBOutlet UILabel *castingLabel;
@property (weak, nonatomic) IBOutlet UILabel *watchingLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UITextView *synopsisTextView;

@property (strong, nonatomic) NSDictionary *data;

- (IBAction)wishListAction:(id)sender;
- (IBAction)mirroringAction:(id)sender;

@end
