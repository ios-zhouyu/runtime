//
//  UIViewController+MyVc.m
//  OCdemo
//
//  Created by 臣陈 on 2017/9/6.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "UIViewController+MyVc.h"
#import <objc/runtime.h>
@implementation UIViewController (MyVc)

#pragma mark 黑魔法之方法交换
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = [self class];
        
        SEL originalSelector = @selector(viewDidLoad);
        SEL swizzledSelector = @selector(swizzledViewDidLoad);
        
        Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
        BOOL didAddMethod = class_addMethod(aClass,originalSelector,method_getImplementation(swizzledMethod),method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(aClass,swizzledSelector,method_getImplementation(originalMethod),method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)swizzledViewDidLoad{
    //    NSLog(@"方法交换");
}
@end
