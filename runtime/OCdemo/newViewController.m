//
//  newViewController.m
//  OCdemo
//
//  Created by zhouyu on 2017/9/5.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "newViewController.h"
#include <objc/runtime.h>
#import "SecondViewController.h"

@interface newViewController ()
@property (nonatomic, strong) SecondViewController *secondVc;
@end

@implementation newViewController

- (instancetype)init{
    
    if (self == [super init]) {
        _secondVc = [[SecondViewController alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark 对象方法的动态处理
void dynamicMethodResolutionInstance(id self, SEL _cmd){
    NSLog(@"进入了实例动态方法处理");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"%@",NSStringFromSelector(sel));
    if (sel == @selector(testMessageDynamicResolution)) {
        //MARK: 注销了本类的动态添加方法,才会进行消息转发
        //        class_addMethod([self class], sel, (IMP)dynamicMethodResolutionInstance, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

#pragma mark 类方法的动态处理
void dynamicMethodResolutionClass(id self, SEL _cmd){
    NSLog(@"进入了类动态方法处理");
}

+ (BOOL)resolveClassMethod:(SEL)sel {
    NSLog(@"%@",NSStringFromSelector(sel));
    if (sel == @selector(testClassMessageDynamicResolution)) {
        //类方法必须添加到元类里面
        Class metaClass = objc_getMetaClass("newViewController");
        class_addMethod(metaClass, sel, (IMP)dynamicMethodResolutionClass, "v@:");
        return YES;
    }
    return [super resolveClassMethod:sel];
}

#pragma mark 消息第一次转发处理  本类将消息转发给其他类之前必须拥有其他类作为自己的属性,切这个类必须实现了这个方法
- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"%@",NSStringFromSelector(aSelector));
    if (aSelector == @selector(testMessageDynamicResolution)) {
        //        return self.secondVc;
        //MARK: 返回nil才会调用forwardInvocation这个方法,调用之前先调用数字签名的方法
        return nil;
    } else {
        return [super forwardingTargetForSelector:aSelector];
    }
}

#pragma mark 最后一次处理消息转发的机会,先进行数字签名,在进行转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *signature = nil;
    NSString *selStr = NSStringFromSelector(aSelector);
    if ([selStr isEqualToString:@"testMessageDynamicResolution"]) {
        //此处返回的signature是方法forwardInvocation的参数anInvocation中的methodSignature
        signature = [self.secondVc methodSignatureForSelector:@selector(testMessageDynamicResolution)];
    }else{
        
        signature = [super methodSignatureForSelector:aSelector];
    }
    return signature;
}

//MARK: 转发的对象必须的实现这个方法,否则不会走
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"%@",anInvocation);
    NSString *selStr = NSStringFromSelector(anInvocation.selector);
    if ([selStr isEqualToString:@"testMessageDynamicResolution"]) {
        [anInvocation setTarget:self.secondVc];
        [anInvocation setSelector:@selector(testMessageDynamicResolution)];
        //        BOOL hasArguments = NO;
        //第一个和第一个参数是target和sel
        //        [anInvocation setArgument:&hasArguments atIndex:2];
        //        [anInvocation retainArguments];
        [anInvocation invoke];
    }else{
        [super forwardInvocation:anInvocation];
    }
}

//- (void)testMessageDynamicResolution {
//    NSLog(@"%s",__func__);
//}

@end
