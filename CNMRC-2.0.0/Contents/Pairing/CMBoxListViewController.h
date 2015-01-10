//
//  CMBoxListViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 24..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMBaseViewController.h"
#import "CMBoxFinder.h"
#import "CMBoxService.h"
#import "CMSetIPViewController.h"

@protocol CMBoxListDelegate;

@interface CMBoxListViewController : CMBaseViewController <UITableViewDataSource, UITableViewDelegate, CMBoxFinderDelegate, CMSetIPViewControllerDelegate>
{
@private
    CMBoxFinder *_finder;
    NSArray *_boxes;    // NSNetServices 타입.
}

@property(strong, nonatomic) NSArray *availableBoxes;
@property(assign, nonatomic) id<CMBoxListDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *boxTable;

@end

@protocol CMBoxListDelegate
@required
/**
 *	박스를 선택했을 경우 호출된다.
 *
 *	@param box CMBoxService 타입의 박스.
 */
- (void)didSelectBox:(CMBoxService *)box;

/**
 *	취소했을 경우 호출된다.
 *
 *	@param	viewController	CMBoxListViewController 타입의 뷰 컨트롤러.
 */
- (void)boxListViewControllerWasCancelled:(CMBoxListViewController *)viewController;
@end