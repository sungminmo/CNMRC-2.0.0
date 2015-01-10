//
//  CMBaseViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMBaseViewController : UIViewController 

@property (assign, nonatomic) CMMenuType menuType;
@property (strong, nonatomic) UIView *naviBar;
@property (strong, nonatomic) UILabel *titleLabel;

- (void)setupLayout;
- (void)setupNavigation;
- (IBAction)backAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)doneAction:(id)sender;

- (UITableViewCell *)cellWithTableView:(UITableView *)tableView cellIdentifier:(NSString *)cellIdentifier nibName:(NSString *)nibName;

// HUD
- (void)show;
- (void)hide;

// 에러 메시지.
- (void)showError:(NSInteger)errorCode;

// VOD 시청 등급 아이콘.
- (UIImage *)vodIcon:(NSInteger)vodGrade;

@end
