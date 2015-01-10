//
//  UIAlertView+NetworkError.m
//  OrchestraNative
//
//  Created by Jong Pil Park on 12. 8. 17..
//  Copyright (c) 2012년 LambertPark. All rights reserved.
//

#import "UIAlertView+NetworkError.h"

@implementation UIAlertView (NetworkError)

+ (UIAlertView *)showWithError:(NSError *)networkError
{    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[networkError localizedDescription]
                                                    message:[networkError localizedRecoverySuggestion]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Confirm", @"확인")
                                          otherButtonTitles:nil];
    [alert show];
    return alert;
}

+ (UIAlertView *)showAlert:(id)obj
                      type:(LPAlertType)type
                       tag:(int)tag
                     title:(NSString *)title
                   message:(NSString *)msg;
{
	// 확인 버튼만 있는 경우.
	if (type == LPAlertTypeOneButton)
    {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:title
							  message:msg
							  delegate:obj
							  cancelButtonTitle:@"확인"
							  otherButtonTitles:nil, nil];
        alert.tag = tag;
		[alert show];
		
        return alert;
	}
	
	// 확인/취소 버튼 모두 있는 경우.
	if (type == LPAlertTypeTwoButton)
    {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:title
							  message:msg
							  delegate:obj
							  cancelButtonTitle:@"취소"
							  otherButtonTitles:@"확인", nil];
        alert.tag = tag;
		[alert show];
        
		return alert;
	}
    
    return nil;
}

@end
