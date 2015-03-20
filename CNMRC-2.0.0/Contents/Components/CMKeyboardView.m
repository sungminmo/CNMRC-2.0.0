//
//  CMKeyboardView.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 20..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMKeyboardView.h"

@implementation CMKeyboardView

- (IBAction)keyAction:(id)sender
{
    DDLogDebug(@"선택된 버튼: %@", @([(UIButton *)sender tag]));
    if (self.delegate && [self.delegate respondsToSelector:@selector(pressedKey:)])
    {
        [self.delegate pressedKey:sender];
    }
}

@end
