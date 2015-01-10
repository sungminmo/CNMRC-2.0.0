//
//  CMBoxFinder.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 24..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMBoxService.h"

@protocol CMBoxFinderDelegate <NSObject>
@required
/**
 *	이용가능한 박스들이 변경될 때마다 호출된다.
 *
 *	@param	boxes	CMBoxService 객체를 담고 있는 배열이다.
 */
- (void)didChangeBoxList:(NSArray *)boxes;

@end

@interface CMBoxFinder : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate>
{
@private
    NSNetServiceBrowser *_browser;
    NSMutableArray *_unresolvedAddresses;
    NSMutableArray *_boxes;
    BOOL _isSearching;
}

@property (assign, nonatomic) id<CMBoxFinderDelegate> delegate;

/**
 *	발견된 박스의 숫자.
 *
 *	@return	발견된 박스의 숫자를 int 타입으로 반환한다.
 */
- (int)count;

/**
 *	검색된 박스들을 런칭한다.
 */
- (void)searchForBoxes;

/**
 *	박스 검색을 중단한다.
 */
- (void)stopSearching;

@end
