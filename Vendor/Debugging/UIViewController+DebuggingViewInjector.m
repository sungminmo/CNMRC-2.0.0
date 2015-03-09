//
//  UIViewController+DebuggingViewInjector.m
//  DGBP
//
//  Created by lambert on 2014. 10. 17..
//
//

#import <objc/runtime.h>
#import "UIViewController+DebuggingViewInjector.h"

static char kWeakLinkViewControllerKey;

@interface UIView ()
@property (nonatomic, unsafe_unretained) UIViewController *debugVC;
@end

@implementation UIView (ViewControllerLinker)

- (void)setDebugVC:(UIViewController *)debugVC {
    objc_setAssociatedObject(self, &kWeakLinkViewControllerKey, debugVC, OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController *)debugVC {
    return objc_getAssociatedObject(self, &kWeakLinkViewControllerKey);
}

@end

@implementation UIViewController (DebuggingViewInjector)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewDidLoad);
        SEL swizzledSelector = @selector(customInjectionViewDidLoad);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)customInjectionViewDidLoad {
    self.view.debugVC = self;
    [self customInjectionViewDidLoad];
}

@end
