//
//  UILabel+Size.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 19..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "UILabel+Size.h"

@implementation UILabel (Size)

- (CGSize)calcLabelSizeWithString:(NSString *)string andMaxSize:(CGSize)maxSize
{
    return [string sizeWithFont:self.font
              constrainedToSize:maxSize
                  lineBreakMode:self.lineBreakMode];
}

@end
