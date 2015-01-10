//
//  LPToast.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 16..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPToast : UIView
{
@private
    UILabel *_textLabel;
    UIActivityIndicatorView *_spinner;
}

+ (void)toastInView:(UIView *)parentView withText:(NSString *)text;
+ (void)toastWithSpinnerInView:(UIView *)parentView withText:(NSString *)text;

@end
