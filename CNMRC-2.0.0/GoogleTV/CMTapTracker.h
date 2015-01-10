//
//  CMTabTracker.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 29..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMTouchHandler.h"

@class CommandHandler;

@interface CMTapTracker : NSObject
{
@private
    UIView *_backgroundView;
    CommandHandler *_comandHandler;
    CMTouchHandler *_touchHandler;
}

- (id)initWithBackgroundView:(UIView *)backgroundView
              commandHandler:(CommandHandler *)handler;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;


@end
