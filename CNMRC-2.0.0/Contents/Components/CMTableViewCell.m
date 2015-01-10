//
//  CMTableViewCell.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 25..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CMTableViewCellBackgroundView

- (BOOL)isOpaque
{
    return YES;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // 기본값.
    if (self.separatorColor == nil)
    {
        [self setSeparatorColor:UIColorFromRGB(0xd0d0d0)];
    }
    
    // TODO: 라인컬러 설정 버그 수정해야 함!
    if (self.lineCount == 2)
    {
        [self setSeparatorColor:UIColorFromRGB(0x333333)];
        UIColor *shadowLineColor = UIColorFromRGB(0x5b5b5b);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [_separatorColor CGColor]);
        CGContextSetLineWidth(context, self.dashStroke);
        
        // 라인.
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0.0f, rect.size.height-self.dashStroke);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height-self.dashStroke);
        CGContextStrokePath(context);
        
        // 그림자 라인.
        CGContextSetStrokeColorWithColor(context, [shadowLineColor CGColor]);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0.0f, rect.size.height-self.dashStroke/2);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height-self.dashStroke/2);
        CGContextStrokePath(context);
    }
    else
    {
        [self setSeparatorColor:UIColorFromRGB(0xd0d0d0)];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [_separatorColor CGColor]);
        CGContextSetLineWidth(context, self.dashStroke);
        
        // 만약 0이면 실선이다.
        if (self.dashGap > 0)
        {
//            float dash[2] = {self.dashWidth , self.dashGap};
//            CGContextSetLineDash(context, 0, dash, 2);
        }
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0.0f, rect.size.height-self.dashStroke/2);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height-self.dashStroke/2);
        CGContextStrokePath(context);
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    if (_separatorColor != separatorColor)
    {
        _separatorColor = separatorColor;
        
        [self layoutSubviews];
        [self setNeedsDisplay];
    }
}

@end

@interface CMTableViewCellSelectedBackgroundView()
@property (nonatomic, assign) float prevLayerHeight;
@end

@implementation CMTableViewCellSelectedBackgroundView

- (void)drawRect:(CGRect)rect
{
    if (self.frame.size.height != self.prevLayerHeight)
    {
        for (int i = 0; i < [self.layer.sublayers count]; i++)
        {
            id layer = [self.layer.sublayers objectAtIndex:i];
            if ([layer isKindOfClass:[CAGradientLayer class]])
            {
                [layer removeFromSuperlayer];
            }
        }
    }
    
    // !!!: 만약 백그라운드 컬러가 주어지면 백그라운드 컬러를 사용한다.
    if (self.backgroundColor)
    {
        return;
    }
    
    if (!self.selectedBackgroundGradientColors)
    {
        // 기본값은 백그라운드 컬러이다.
        self.selectedBackgroundGradientColors = @[(id)[[UIColor colorWithWhite:0.9 alpha:1] CGColor],(id)[[UIColor colorWithWhite:0.95 alpha:1] CGColor]];
    }
    else if ([self.selectedBackgroundGradientColors count] == 1)
    {
        // 그라디언트를 위해 최소 2가지 이상의 컬러가 필요하다. 만약 한 가지 컬러만 주어진다면 같은 컬러를 사용한다.
        self.selectedBackgroundGradientColors = @[[self.selectedBackgroundGradientColors objectAtIndex:0], [self.selectedBackgroundGradientColors objectAtIndex:0]];
    }
    
    // 선택된 셀의 백그라운드 그라디언트를 그린다.
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height-self.dashStroke)];
    if (self.gradientDirection == CMTableViewCellSelectionGradientDirectionVertical)
    {
        [gradient setStartPoint:CGPointMake(0, 0)];
        [gradient setEndPoint:CGPointMake(0, 1)];
    }
    else if (self.gradientDirection == CMTableViewCellSelectionGradientDirectionHorizontal)
    {
        [gradient setStartPoint:CGPointMake(0, 0)];
        [gradient setEndPoint:CGPointMake(1, 0)];
    }
    else if (self.gradientDirection == CMTableViewCellSelectionGradientDirectionDiagonalTopLeftToBottomRight)
    {
        [gradient setStartPoint:CGPointMake(0, 0)];
        [gradient setEndPoint:CGPointMake(1, 1)];
    }
    else if (self.gradientDirection == CMTableViewCellSelectionGradientDirectionDiagonalBottomLeftToTopRight)
    {
        [gradient setStartPoint:CGPointMake(0, 1)];
        [gradient setEndPoint:CGPointMake(1, 0)];
    }
    [self.layer insertSublayer:gradient atIndex:0];
    [gradient setColors:self.selectedBackgroundGradientColors];
    
    [super drawRect:rect];
    
    self.prevLayerHeight = self.frame.size.height;
}

@end

@implementation CMTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // 백그라운드 뷰 설정.
        CMTableViewCellBackgroundView *backgroundView = [[CMTableViewCellBackgroundView alloc] initWithFrame:CGRectZero];
        [self setBackgroundView:backgroundView];
        
        // 선택된 셀의 백그라운드 뷰 설정.
        CMTableViewCellSelectedBackgroundView *selectedBackgroundView = [[CMTableViewCellSelectedBackgroundView alloc] initWithFrame:CGRectZero];
        [self setSelectedBackgroundView:selectedBackgroundView];

        // 텍스트 라벨의 벡그라운드 컬러를 클리어 한다.
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        
        [self setDashWidth:1 dashGap:0 dashStroke:1];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.backgroundView setNeedsDisplay];
    [self.selectedBackgroundView setNeedsDisplay];
}

- (void)setBackgroundViewColor:(UIColor *)color
{
    [(CMTableViewCellBackgroundView *)self.backgroundView setBackgroundColor:color];
}

- (void)setSelectedBackgroundViewColor:(UIColor *)color
{
    [(CMTableViewCellSelectedBackgroundView *)self.selectedBackgroundView setBackgroundColor:color];
}

- (void)setSelectedBackgroundViewGradientColors:(NSArray *)colors
{
    [(CMTableViewCellSelectedBackgroundView *)self.selectedBackgroundView setSelectedBackgroundGradientColors:colors];
}

- (void)setCMTableViewCellSelectionStyle:(CMTableViewCellSelectionStyle)style
{
    _cmTableViewCellSelectionStyle = style;
    
    NSMutableArray *colors = [NSMutableArray array];
    if (_cmTableViewCellSelectionStyle == CMTableViewCellSelectionStyleCyan)
    {
        [colors addObject:(id)[[UIColor colorWithRed:134/255.0 green:214/255.0 blue:231/255.0 alpha:1] CGColor]];
        [colors addObject:(id)[[UIColor colorWithRed:111/255.0 green:198/255.0 blue:217/255.0 alpha:1] CGColor]];
    }
    else if (_cmTableViewCellSelectionStyle == CMTableViewCellSelectionStyleGreen)
    {
        [colors addObject:(id)[[UIColor colorWithRed:124/255.0 green:243/255.0 blue:127/255.0 alpha:1] CGColor]];
        [colors addObject:(id)[[UIColor colorWithRed:111/255.0 green:222/255.0 blue:114/255.0 alpha:1] CGColor]];
    }
    else if (_cmTableViewCellSelectionStyle == CMTableViewCellSelectionStyleYellow)
    {
        [colors addObject:(id)[[UIColor colorWithRed:248/255.0 green:242/255.0 blue:145/255.0 alpha:1] CGColor]];
        [colors addObject:(id)[[UIColor colorWithRed:243/255.0 green:236/255.0 blue:124/255.0 alpha:1] CGColor]];
    }
    else if (_cmTableViewCellSelectionStyle == CMTableViewCellSelectionStylePurple)
    {
        [colors addObject:(id)[[UIColor colorWithRed:217/255.0 green:143/255.0 blue:230/255.0 alpha:1] CGColor]];
        [colors addObject:(id)[[UIColor colorWithRed:190/255.0 green:110/255.0 blue:204/255.0 alpha:1] CGColor]];
    }
    else
    {
        [colors addObject:(id)[[UIColor colorWithWhite:0.95 alpha:1] CGColor]];
        [colors addObject:(id)[[UIColor colorWithWhite:0.9 alpha:1] CGColor]];
    }
    [self setSelectedBackgroundViewGradientColors:colors];
}

- (void)setSelectionGradientDirection:(CMTableViewCellSelectionGradientDirection)direction
{
    [(CMTableViewCellSelectedBackgroundView*)self.selectedBackgroundView setGradientDirection:direction];
}

// 셀의 라인 컬러 변경을 위한 오버라이드 메서드: 호출할 필요는 없다..
- (void)setSeparatorColor:(UIColor *)separatorColor
{
    [(CMTableViewCellSelectedBackgroundView *)self.selectedBackgroundView setSeparatorColor:separatorColor];
    [(CMTableViewCellBackgroundView *)self.backgroundView setSeparatorColor:separatorColor];
}

- (void)setLineCount:(int)lineCount
{
    [(CMTableViewCellBackgroundView *)self.backgroundView setLineCount:lineCount];
}

- (void)setDashWidth:(int)dashWidth dashGap:(int)dashGap dashStroke:(int)dashStroke
{
    [self setDashWidth:dashWidth];
    [self setDashGap:dashGap];
    [self setDashStroke:dashStroke];
}

- (void)setDashGap:(int)dashGap
{
    _dashGap = dashGap;
    [(CMTableViewCellSelectedBackgroundView *)self.selectedBackgroundView setDashGap:self.dashGap];
    [(CMTableViewCellBackgroundView *)self.backgroundView setDashGap:self.dashGap];
}

// set the separator stroke width
- (void)setDashStroke:(int)dashStroke
{
    _dashStroke = dashStroke;
    [(CMTableViewCellSelectedBackgroundView *)self.selectedBackgroundView setDashStroke:self.dashStroke];
    [(CMTableViewCellBackgroundView *)self.backgroundView setDashStroke:self.dashStroke];
}

- (void)setDashWidth:(int)dashWidth
{
    _dashWidth = dashWidth;
    [(CMTableViewCellSelectedBackgroundView *)self.selectedBackgroundView setDashWidth:self.dashWidth];
    [(CMTableViewCellBackgroundView *)self.backgroundView setDashWidth:self.dashWidth];
}

@end
