//
//  CMTabTracker.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 29..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTapTracker.h"
#import "CommandHandler.h"

@implementation CMTapTracker

// O.S. 동시에 5개의 터치를 지원한다.
static const int kSimultaneousTouchesCount = 5;

- (id)init
{
    NSAssert(NO, @"Call the designated initializer");
    return [self initWithBackgroundView:nil commandHandler:nil];
}

- (id)initWithBackgroundView:(UIView *)backgroundView
              commandHandler:(CommandHandler *)commandHandler
{
    self = [super init];
    if (self != nil) {
        _backgroundView = backgroundView;
        _comandHandler = commandHandler;
        _touchHandler = [[CMTouchHandler alloc] init];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger maxNumTaps = 0;
    for (UITouch *touch in touches) {
        if (maxNumTaps < [touch tapCount]) {
            maxNumTaps = [touch tapCount];
        }
    }
    
    if (maxNumTaps == 2)
    {
        // 2번의 탭이면 클릭을 보낸다.
        [_comandHandler click];
    }
    else if ([touches count] == 1)
    {
        // ...또는 단지 하나의 터치만 추적한다. 멀티 핑거 제스처는 UIGestureRecognizers (iOS >3.2)가 처리한다.
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:_backgroundView];
        NSTimeInterval time = [touch timestamp];
        NSAssert(_touchHandler, @"We should have a touchHandler");
        [_touchHandler startOn:point atTime:time];
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    NSLog(@"Move track pad.");
    // !!!: 트랙패들일 경우 얼럿을 띄우지 않는다.
    if (AppInfo.isPaired == NO)
    {
        return;
    }
    
    // 오직 하나의 터치만 추적한다.
    if ([touches count] == 1)
    {
        UITouch *touch = [touches anyObject];
        UIInterfaceOrientation orient =
        [[UIApplication sharedApplication] statusBarOrientation];
        [_touchHandler setPosition:[touch locationInView:_backgroundView]
                            atTime:[touch timestamp]
                       orientation:orient];
        if ([_touchHandler state] == kHandlerStateNone)
        {
            CGPoint delta = [_touchHandler computeCursorDelta:orient];
            if (!CGPointEqualToPoint(delta, CGPointZero))
            {
                [_comandHandler moveRelativeDeltaX:delta.x deltaY:delta.y];
            }
        }
    }
}

- (void)touchesEndedOrCancelled
{
    [_touchHandler reset];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1)
    {
        UITouch *touch = [touches anyObject];
        [_touchHandler endOn:[touch locationInView:_backgroundView]
                      atTime:[touch timestamp]];
        if ([_touchHandler state] == kHandlerStateClick)
        {
            [_comandHandler click];
        }
    }
    [self touchesEndedOrCancelled];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEndedOrCancelled];
}

@end
