//
//  CMTouchHandler.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 29..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <Foundation/Foundation.h>

// 터치 패드의 모션.
typedef CGPoint Delta;

// 스크롤링 상태.
typedef enum HandlerState {
    kHandlerStateNone,
    kHandlerStateClick
} HandlerState;

@interface NSData (TouchHandler)
+ (NSData *)dataWithCGPoint:(CGPoint)p;
- (CGPoint)cgpoint;
@end

/**
 *	터치패드의 상태를 저장하고 터치와 관련되 유틸리티 기능을 제공한다.
 *  오직 한 손가락 드래그와 하나의 탭만 지원한다.
 */
@interface CMTouchHandler : NSObject
{
@private
    // 참조 포인트들. 현재의 포인트는 마지막 객체이다.
    NSMutableArray *primaryPoints_;
    
    // 타임스탬프.
    NSTimeInterval startTime_;
    
    // 스크롤링 상태.
    HandlerState state_;
}

// 현재의 터치가 스크롤링인지 판변할다.
@property (nonatomic, assign, readonly) HandlerState state;

// 터치 시작.
- (void)startOn:(CGPoint)point atTime:(NSTimeInterval)time;

// 포인트와 타임스탬프로 구성된 현재의 터치를 설정한다. 
- (void)setPosition:(CGPoint)point
             atTime:(NSTimeInterval)time
        orientation:(UIInterfaceOrientation)orientation;

// 터치 끝(취소가 아니라 끝이다.).
- (void)endOn:(CGPoint)point atTime:(NSTimeInterval)time;

// 마지막 터치로부터 커서의 모션과 관련된 계산의 한다. 계산 결과의 좌표는 디바이스의 오리엔테이션과는 관계가 없다.
- (Delta)computeCursorDelta:(UIInterfaceOrientation)orientation;

// 핸들러 초기화 리셋. 각 터치 시퀀스 전에 호출된다.
- (void)reset;

@end
