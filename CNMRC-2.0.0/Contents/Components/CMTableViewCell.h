//
//  CMTableViewCell.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 25..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *	사용할 수 있는 컬러.
 */
typedef enum
{
    CMTableViewCellSelectionStyleDefault = 0,
    CMTableViewCellSelectionStyleCyan = 1,
    CMTableViewCellSelectionStyleGreen = 2,
    CMTableViewCellSelectionStyleYellow = 3,
    CMTableViewCellSelectionStylePurple = 4,
} CMTableViewCellSelectionStyle;

/**
 *	그라디언트 스타일.
 */
typedef enum
{
    CMTableViewCellSelectionGradientDirectionVertical = 0,
    CMTableViewCellSelectionGradientDirectionHorizontal = 1,
    CMTableViewCellSelectionGradientDirectionDiagonalTopLeftToBottomRight = 2,
    CMTableViewCellSelectionGradientDirectionDiagonalBottomLeftToTopRight = 3,
} CMTableViewCellSelectionGradientDirection;

/**
 *	백그라운드 뷰
 */
@interface CMTableViewCellBackgroundView : UIView
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, assign) int lineCount;
@property (nonatomic, assign) int dashWidth, dashGap, dashStroke;
@end

/**
 *	선택된 백그라운드 뷰: 백그라운드 뷰의 서브클래스.
 */
@interface CMTableViewCellSelectedBackgroundView : CMTableViewCellBackgroundView
@property (nonatomic, strong) NSArray *selectedBackgroundGradientColors;
@property (nonatomic, assign) CMTableViewCellSelectionGradientDirection gradientDirection;
@end

@interface CMTableViewCell : UITableViewCell

/**
 *	라인 관련 프라퍼티.
 */
@property (nonatomic, assign) int dashWidth;
@property (nonatomic, assign) int dashGap;
@property (nonatomic, assign) int dashStroke;
@property (nonatomic, assign) int lineCount;

- (void)setDashWidth:(int)dashWidth dashGap:(int)dashGap dashStroke:(int)dashStroke;
- (void)setSeparatorColor:(UIColor *)separatorColor;
- (void)setLineCount:(int)lineCount;

/**
 *	선택된 셀의 백그라운드 컬러.
 *
 *	@param	colors	CGColor 타입의 배열.
 */
- (void)setBackgroundViewColor:(UIColor *)color;

/**
 *	선택된 셀의 백그라운드 컬러.
 *
 *	@param	colors	CGColor 타입의 배열.
 */
- (void)setSelectedBackgroundViewColor:(UIColor *)color;

/**
 *	선택된 셀의 그라디언트 백그라운드 컬러.
 *
 *	@param	colors	CGColor 타입의 배열.
 */
- (void)setSelectedBackgroundViewGradientColors:(NSArray *)colors;

/**
 *	선택된 셀의 백그라운드 컬러의 방향.
 *
 *	@param	direction	CMTableViewCellSelectionGradientDirection 타입의 방향
 */
- (void)setSelectionGradientDirection:(CMTableViewCellSelectionGradientDirection)direction;

/**
 *	선택된 셀의 백그라운드 컬러 타입.
 */
@property (nonatomic, assign, setter = setCMTableViewCellSelectionStyle:) CMTableViewCellSelectionStyle cmTableViewCellSelectionStyle;

@end
