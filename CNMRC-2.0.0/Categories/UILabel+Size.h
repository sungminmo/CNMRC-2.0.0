//
//  UILabel+Size.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 19..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Size)

// 동적으로 라벨의 사이즈를 결정한다.
- (CGSize)calcLabelSizeWithString:(NSString *)string andMaxSize:(CGSize)maxSize;

@end
