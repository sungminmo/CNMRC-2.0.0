//
//  LPToast.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 16..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "LPToast.h"
#import <QuartzCore/QuartzCore.h>

// 보요줄 시간 설정.
static const CGFloat kDuration = 2;

// 정적 토스트 뷰 변수.
static NSMutableArray *toasts;

@interface LPToast ()

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, readonly) UIActivityIndicatorView *spinner;

- (void)fadeToastOut;
+ (void)nextToastInView:(UIView *)parentView;

@end

@implementation LPToast

#pragma mark - NSObject

- (id)initWithText:(NSString *)text showIndicator:(BOOL)showIndicator
{
    self = [self initWithFrame:CGRectZero];
	if (self)
    {
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
		self.layer.cornerRadius = 5;
		self.autoresizingMask = UIViewAutoresizingNone;
		self.autoresizesSubviews = NO;
		
		// Init and add label
		_textLabel = [[UILabel alloc] init];
		_textLabel.text = text;
		_textLabel.minimumFontSize = 14;
		_textLabel.font = [UIFont systemFontOfSize:14];
		_textLabel.textColor = [UIColor whiteColor];
		_textLabel.adjustsFontSizeToFitWidth = NO;
		_textLabel.backgroundColor = [UIColor clearColor];
		[_textLabel sizeToFit];
		[self addSubview:_textLabel];
        
         _textLabel.frame = CGRectOffset(_textLabel.frame, 10, 5);
        
        if (showIndicator)
        {
            _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [_spinner setHidesWhenStopped:YES];
            _spinner.frame = CGRectMake(0.0, 0.0, 14.0, 14.0);
            _spinner.frame = CGRectOffset(_spinner.frame, 10, 5);
            [_spinner startAnimating];
            [self addSubview:_spinner];
        }
	}
	
	return self;
}

#pragma mark - 퍼블릭 메서드.

+ (void)toastInView:(UIView *)parentView withText:(NSString *)text
{
	// 인스턴스를 큐에 추가.
	LPToast *view = [[LPToast alloc] initWithText:text showIndicator:NO];
    
	CGFloat lWidth = view.textLabel.frame.size.width;
	CGFloat lHeight = view.textLabel.frame.size.height;
	CGFloat pWidth = parentView.frame.size.width;
	CGFloat pHeight = parentView.frame.size.height;
	
	// Change toastview frame
	view.frame = CGRectMake((pWidth - lWidth - 20) / 2., pHeight - lHeight - 100, lWidth + 20, lHeight + 10);
	view.alpha = 0.0f;
	
	if (toasts == nil)
    {
		toasts = [[NSMutableArray alloc] initWithCapacity:1];
		[toasts addObject:view];
		[LPToast nextToastInView:parentView];
	}
	else
    {
		[toasts addObject:view];
	}
}

+ (void)toastWithSpinnerInView:(UIView *)parentView withText:(NSString *)text
{
    // 인스턴스를 큐에 추가.
	LPToast *view = [[LPToast alloc] initWithText:text showIndicator:YES];
    
    CGFloat lWidth = view.textLabel.frame.size.width;
	CGFloat lHeight = view.textLabel.frame.size.height;
	CGFloat pWidth = parentView.frame.size.width;
	CGFloat pHeight = parentView.frame.size.height;
	CGFloat sWidth = view.spinner.frame.size.width;
    
	// Change toastview frame
    view.frame = CGRectMake((pWidth - lWidth - 20) / 2., pHeight - lHeight - 100, lWidth + 20 + sWidth, lHeight + 10);
	view.alpha = 0.0f;
    
    // Spinner frame.
    view.spinner.frame = CGRectMake(view.textLabel.frame.size.width + sWidth, view.textLabel.frame.origin.y + 2, 15.0, 15.0);
	
	if (toasts == nil)
    {
		toasts = [[NSMutableArray alloc] initWithCapacity:1];
		[toasts addObject:view];
		[LPToast nextToastInView:parentView];
	}
	else
    {
		[toasts addObject:view];
	}
}

#pragma mark - 프라이빗 메서드

- (void)fadeToastOut
{
	// 페이드 인.
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction
     
                     animations:^{
                         self.alpha = 0.f;
                     }
                     completion:^(BOOL finished){
                         UIView *parentView = self.superview;
                         [self removeFromSuperview];
                         
                         // 현재 토스트를 배열에서 삭제.
                         [toasts removeObject:self];
                         if ([toasts count] == 0)
                         {
                             //[toasts release];
                             toasts = nil;
                         }
                         else
                             [LPToast nextToastInView:parentView];
                     }];
}

+ (void)nextToastInView:(UIView *)parentView
{
	if ([toasts count] > 0) {
        LPToast *view = [toasts objectAtIndex:0];
        
		// 페이드 인.
		[parentView addSubview:view];
        [UIView animateWithDuration:.5  delay:0 options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.alpha = 1.0;
                         } completion:^(BOOL finished){}];
        
        // 페이드 아웃을 위해 타이머 시작.
        [view performSelector:@selector(fadeToastOut) withObject:nil afterDelay:kDuration];
    }
}


@end
