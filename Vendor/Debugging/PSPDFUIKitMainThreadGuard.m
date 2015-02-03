//
//  PSPDFUIKitMainThreadGuard.m
//  LambertPark
//
//  Created by lambert on 2014. 4. 18..
//
// 출처: PDF framework http://pspdfkit.com.
// Copyright (c) 2013 Peter Steinberger. All rights reserved.
// Licensed under MIT (http://opensource.org/licenses/MIT)
//
// !!!: 개발 중 디버거(DEBUG) 모드에서만 사용할 것().

#import "PSPDFUIKitMainThreadGuard.h"

#import <objc/runtime.h>
#import <objc/message.h>

// 컴파일 시 selector 확인.
#if DEBUG
#define PROPERTY(propName) NSStringFromSelector(@selector(propName))
#else
#define PROPERTY(propName) @#propName
#endif

// NSAssert가 런타임에 의존도가 강하고 로그가 없어 매크로로 대체.
// 참고: http://www.mikeash.com/pyblog/friday-qa-2013-05-03-proper-use-of-asserts.html
// [사용법]
// - PSPDFAssert(x > 0);
// - PSPDFAssert(y > 3, @"Bad value for y");
#define PSPDFAssert(expression, ...) \
do { if(!(expression)) { \
NSLog(@"%@", [NSString stringWithFormat: @"Assertion failure: %s in %s on line %s:%d. %@", #expression, __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:@"" __VA_ARGS__]]); \
abort(); }} while(0)

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 메서드 스위즐링용 헬퍼

BOOL PSPDFReplaceMethodWithBlock(Class c, SEL origSEL, SEL newSEL, id block)
{
    PSPDFAssert(c && origSEL && newSEL && block);
    Method origMethod = class_getInstanceMethod(c, origSEL);
    const char *encoding = method_getTypeEncoding(origMethod);
    
    // 새로운 메서드 추가.
    IMP impl = imp_implementationWithBlock(block);
    if (!class_addMethod(c, newSEL, impl, encoding))
    {
        NSLog(@"Failed to add method: %@ on %@", NSStringFromSelector(newSEL), c);
        return NO;
    }
    else
    {
        // 새로운 selector가 같은 parameters를 갖고 있다는 것을 보장함.
        Method newMethod = class_getInstanceMethod(c, newSEL);
        PSPDFAssert(strcmp(method_getTypeEncoding(origMethod), method_getTypeEncoding(newMethod)) == 0, @"Encoding must be the same.");
        
        // 만약 원본이 구현되지 않았다면 swizzle을 이용해 생성함.
        if (class_addMethod(c, origSEL, method_getImplementation(newMethod), encoding))
        {
            class_replaceMethod(c, newSEL, method_getImplementation(origMethod), encoding);
        }
        else
        {
            method_exchangeImplementations(origMethod, newMethod);
        }
    }
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 메인 스레드가 아닌 다른 스레드에서 UIKit을 호출하는 것을 추적한다.

static void PSPDFAssertIfNotMainThread(void)
{
    PSPDFAssert(NSThread.isMainThread, @"\nERROR: All calls to UIKit need to happen on the main thread. You have a bug in your code. Use dispatch_async(dispatch_get_main_queue(), ^{ ... }); if you're unsure what thread you're in.\n\nBreak on PSPDFAssertIfNotMainThread to find out where.\n\nStacktrace: %@", [NSThread callStackSymbols]);
}

// UIKit의 threading-errors를 체크.
__attribute__((constructor)) static void PSPDFUIKitMainThreadGuard(void)
{
    @autoreleasepool {
        for (NSString *selStr in @[PROPERTY(setNeedsLayout), PROPERTY(setNeedsDisplay), PROPERTY(setNeedsDisplayInRect:)])
        {
            SEL selector = NSSelectorFromString(selStr);
            SEL newSelector = NSSelectorFromString([NSString stringWithFormat:@"pspdf_%@", selStr]);
            if ([selStr hasSuffix:@":"]) {
                PSPDFReplaceMethodWithBlock(UIView.class, selector, newSelector, ^(__unsafe_unretained UIView *_self, CGRect r) {
                    PSPDFAssertIfNotMainThread();
                    ((void ( *)(id, SEL, CGRect))objc_msgSend)(_self, newSelector, r);
                });
            }
            else
            {
                PSPDFReplaceMethodWithBlock(UIView.class, selector, newSelector, ^(__unsafe_unretained UIView *_self) {
                    PSPDFAssertIfNotMainThread();
                    ((void ( *)(id, SEL))objc_msgSend)(_self, newSelector);
                });
            }
        }
    }
}
