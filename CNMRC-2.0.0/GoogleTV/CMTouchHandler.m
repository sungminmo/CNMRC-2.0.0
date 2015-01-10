//
//  CMTouchHandler.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 29..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMTouchHandler.h"

// 하나의 탭의 지속 시간 이 값보다 적다.
static const NSTimeInterval kMaxTapTime = 0.4;

// 하나의 탭은 반드시 이 픽셀의 값의 범위에 포함되어야 한다.
static const CGFloat kMaxPixelRange = 10;

// 최근 포인트 히스토리.
static const int kHistoryMaxCount = 4;

@interface NSMutableArray (TouchHandler)
- (CGPoint)pointAtIndex:(unsigned)index;
- (void)addPoint:(CGPoint)point;
@end

@implementation NSMutableArray (TouchHandler)

- (CGPoint)pointAtIndex:(unsigned)index
{
    return [[self objectAtIndex:index] cgpoint];
}

- (void)addPoint:(CGPoint)point
{
    [self addObject:[NSData dataWithCGPoint:point]];
}

@end

@implementation NSData (TouchHandler)

+ (NSData *)dataWithCGPoint:(CGPoint)p
{
    return [NSData dataWithBytes:&p length:sizeof(p)];
}

- (CGPoint)cgpoint
{
    CGPoint p;
    [self getBytes:&p length:sizeof(p)];
    return p;
}

@end

// 프라이빗 메서드.
@interface CMTouchHandler ()

// 사용자의 오리엔테이션 안에서 두 포인트의 차이를 반환한다.
- (Delta)deltaPoint:(CGPoint)currentPoint
      previousPoint:(CGPoint)previousPoint
        orientation:(UIInterfaceOrientation)orientation;

// 마지막 포인트를 현재의 것으로 사용한다.
- (Delta)computePointsDelta:(NSMutableArray *)points
                orientation:(UIInterfaceOrientation)orientation;

@end


@implementation CMTouchHandler

- (id)init
{
    self = [super init];
    if (self != nil) {
        primaryPoints_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startOn:(CGPoint)point atTime:(NSTimeInterval)time
{
    startTime_ = time;
    state_ = kHandlerStateNone;
    [primaryPoints_ addPoint:point];
}

// 만약 한 손가락의 다운되면 포인트 히스토리에 포인트를 추가한다.
- (void)setPosition:(CGPoint)point
             atTime:(NSTimeInterval)time
        orientation:(UIInterfaceOrientation)orientation
{
    [primaryPoints_ addPoint:point];
    if (kHistoryMaxCount < [primaryPoints_ count])
    {
        [primaryPoints_ removeObjectAtIndex:0];
    }
}

// 하나의 탭의 끝인지?
- (void)endOn:(CGPoint)point atTime:(NSTimeInterval)time
{
    if ([primaryPoints_ count] == 0)
    {
        return;
    }
    CGPoint firstPoint = [primaryPoints_ pointAtIndex:0];
    if (time - startTime_ < kMaxTapTime
        && abs(firstPoint.x - point.x) < kMaxPixelRange
        && abs(firstPoint.y - point.y) < kMaxPixelRange)
    {
        state_ = kHandlerStateClick;
    }
}


- (Delta)deltaPoint:(CGPoint)currentPoint
      previousPoint:(CGPoint)previousPoint
        orientation:(UIInterfaceOrientation)orientation
{
    Delta delta;
    NSInteger devX, devY;
    devX = round((float) (currentPoint.x - previousPoint.x));
    devY = round((float) (currentPoint.y - previousPoint.y));
    
    // 오리엔테이션.
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            delta.x = -devX;
            delta.y = -devY;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            delta.x = -devY;
            delta.y = devX;
            break;
        case UIInterfaceOrientationLandscapeRight:
            delta.x = devY;
            delta.y = -devX;
            break;
        default:
            delta.x = devX;
            delta.y = devY;
            break;
    }
    
    return delta;
}

- (Delta)computePointsDelta:(NSMutableArray *)points
                orientation:(UIInterfaceOrientation)orientation
{
    // 마지막 터치 이벤트로부터 x/y 델타를 계산한다.
    CGPoint currentPoint = CGPointZero;
    CGPoint previousPoint = CGPointZero;
    int count = [points count];
    if (0 < count)
    {
        currentPoint = [points pointAtIndex:count - 1];
        previousPoint = currentPoint;
    }
    if (1 < count)
    {
        previousPoint = [points pointAtIndex:count - 2];
    }
    Delta delta = [self deltaPoint:currentPoint
                     previousPoint:previousPoint
                       orientation:orientation];
    return CGPointMake(delta.x, delta.y);
}

- (Delta)computeCursorDelta:(UIInterfaceOrientation)orientation
{
    return [self computePointsDelta:primaryPoints_ orientation:orientation];
}

- (void)reset
{
    [primaryPoints_ removeAllObjects];
    startTime_ = 0;
    state_ = kHandlerStateClick;
}

@end
