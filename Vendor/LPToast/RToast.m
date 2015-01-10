/*
Ê* Copyright 2012 Google Inc. All Rights Reserved.
Ê*
Ê* Licensed under the Apache License, Version 2.0 (the "License");
Ê* you may not use this file except in compliance with the License.
Ê* You may obtain a copy of the License at
Ê*
Ê* Ê Ê Êhttp://www.apache.org/licenses/LICENSE-2.0
Ê*
Ê* Unless required by applicable law or agreed to in writing, software
Ê* distributed under the License is distributed on an "AS IS" BASIS,
Ê* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
Ê* See the License for the specific language governing permissions and
Ê* limitations under the License.
Ê*/

#import "RToast.h"
#import "GTMUIFont+LineHeight.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kMaximumWidthRatio = 0.70;
static const NSInteger kPadding = 5;
static const NSInteger kBottomMargin = 50;

static RToast *toast;

@interface RToast()
+ (RToast *)toast;
- (void)createView;
- (void)showMessage:(NSString *)message
        forDuration:(NSTimeInterval)duration
      showIndicator:(BOOL)showIndicator;
@end


@implementation RToast

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self createView];
  }
  return self;
}

- (void)dealloc {
  [message_ release];
  [super dealloc];
}

- (void)createView {
  UIColor *borderColor = [UIColor colorWithWhite:1 alpha:0.3];

  [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.85]];
  [[self layer] setBorderColor:[borderColor CGColor]];
  [[self layer] setBorderWidth:1];
  [[self layer] setCornerRadius:5];

  message_ = [[UILabel alloc] initWithFrame:CGRectZero];
  [message_ setNumberOfLines:0];
  [message_ setLineBreakMode:UILineBreakModeTailTruncation];
  [message_ setTextAlignment:UITextAlignmentCenter];
  [message_ setFont:[UIFont boldSystemFontOfSize:14]];
  [message_ setTextColor:[UIColor lightGrayColor]];
  [message_ setBackgroundColor:[UIColor clearColor]];
  [self addSubview:message_];

  spinner_ = [[UIActivityIndicatorView alloc]
              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [spinner_ setHidesWhenStopped:YES];
  [self addSubview:spinner_];

  [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

- (void)showMessage:(NSString *)message
        forDuration:(NSTimeInterval)duration
      showIndicator:(BOOL)showIndicator {
  CGRect screen = [[UIScreen mainScreen] applicationFrame];

  [message_ setText:message];

  if (showIndicator) {
    [spinner_ startAnimating];
    CGFloat lineHeight = [[message_ font] gtm_lineHeight];
    [spinner_ setFrame:CGRectMake(kPadding, kPadding, lineHeight, lineHeight)];
  } else {
    [spinner_ stopAnimating];
  }

  CGRect textFrame = CGRectZero;
  textFrame.size.width = floor(screen.size.width * kMaximumWidthRatio);
  [message_ setFrame:textFrame];
  [message_ sizeToFit];

  CGRect outerFrame = CGRectZero;
  outerFrame.size.width = [message_ frame].size.width + kPadding * 2;
  if (showIndicator) {
    outerFrame.size.width += ([spinner_ frame].size.width + kPadding);
  }
  outerFrame.size.height = [message_ frame].size.height + kPadding * 2;
  outerFrame.origin.x =
      floor((screen.size.width - outerFrame.size.width) / 2);
  outerFrame.origin.y =
      screen.size.height - kBottomMargin - outerFrame.size.height;
  [self setFrame:outerFrame];

  textFrame = [message_ frame];
  if (showIndicator) {
    textFrame.origin.x = 2 * kPadding + [spinner_ frame].size.width;
  } else {
    textFrame.origin.x =
        floor((outerFrame.size.width - textFrame.size.width) / 2);
  }
  textFrame.origin.y =
      floor((outerFrame.size.height - textFrame.size.height) / 2);
  [message_ setFrame:textFrame];

  [self setAlpha:1];

  if (!showIndicator) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:duration];
    [UIView setAnimationDuration:0.5];
    [self setAlpha:0];
    [UIView commitAnimations];
  }
}

+ (RToast *)toast {
  if (!toast) {
    toast = [[RToast alloc] initWithFrame:CGRectZero];
  }
  return toast;
}

+ (void)showToast:(NSString *)message forDuration:(NSTimeInterval)duration {
  [[self toast] showMessage:message forDuration:duration showIndicator:NO];
}

+ (void)showToastWithSpinner:(NSString *)message {
  [[self toast] showMessage:message forDuration:0 showIndicator:YES];
}

+ (void)hide {
  [toast setAlpha:1];
}

@end
