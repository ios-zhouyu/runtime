//
//  NSArray+UnCrash.m
//  OCdemo
//
//  Created by zhouyu on 2017/9/6.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "NSArray+UnCrash.h"
#include <objc/runtime.h>

@implementation NSArray (UnCrash)

+ (void)load{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // -[__NSArrayI objectAtIndex:]: index 4 beyond bounds [0 .. 2]'
        [self swizzleMethodWithClassName:@"__NSArrayI" originalSelectorStr:@"objectAtIndex:" swizzledSelectorStr:@"unCrash_objectAtIndex:"];
        
        //-[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[1]'
        [self swizzleMethodWithClassName:@"__NSPlaceholderArray" originalSelectorStr:@"initWithObjects:count:" swizzledSelectorStr:@"unCrash_initWithObjects:count:"];
        
    });
}

//MARK: 防止数组初始化时出现nil值程序崩溃
- (id)unCrash_initWithObjects:(const id [])objects count:(NSUInteger)count {
    id nObjects[count];
    //遍历过滤掉为nil的项,重新组成新的objects
    int i=0,newCount=0;
    for (; i<count && newCount<count; i++) {
        if (objects[i]) {
            nObjects[newCount] = objects[i];
            newCount++;
        }
        if (!objects[i]) {
            NSLog(@"数组第%d个元素出现了nil值,被过滤掉",i);
        }
    }
    return [self unCrash_initWithObjects:nObjects count:newCount];
}

/*
//MARK unCrash_initWithObjects:count:有这个方法,unCrash_arrayWithObjects:count:这个就不用
//+ (instancetype)unCrash_arrayWithObjects:(const id [])objects count:(NSUInteger)count {
//    id nObjects[count];
//    int i=0, j=0;
//    for (; i<count && j<count; i++) {
//        if (objects[i]) {
//            nObjects[j] = objects[i];
//            j++;
//        }
//    }
//    return [self unCrash_arrayWithObjects:objects count:count];
//}
*/

//MARK: 防止NSArray数组越界崩溃
- (id)unCrash_objectAtIndex:(NSUInteger)index{
    if (self.count - 1 < index) { //数组越界
        //做异常处理,否则会崩溃
        @try{
            //MARK: 调用此方法会交换城调用[self objectAtIndex:index];方法
            //return [self unCrash_objectAtIndex:index];
            NSLog(@"NSArray数组越界");
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            return nil;
        }@catch(NSException *exception) {
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@",[exception callStackSymbols]);
            return nil;
        }@finally{}
    } else { //否则数组不越界
        return [self unCrash_objectAtIndex:index];
    }
}

#pragma mark 方法交换
+ (void)swizzleMethodWithClassName:(NSString *)className originalSelectorStr:(NSString *)originalSelectorStr swizzledSelectorStr:(NSString *)swizzledSelectorStr {
    
    Class class = NSClassFromString(className);
    
    SEL originalSelector = NSSelectorFromString(originalSelectorStr);
    SEL swizzledSelector = NSSelectorFromString(swizzledSelectorStr);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class,originalSelector,method_getImplementation(swizzledMethod),method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,swizzledSelector,method_getImplementation(originalMethod),method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end

@implementation NSMutableArray (UnCrash)

+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // [__NSArrayM objectAtIndex:]: index 4 beyond bounds [0 .. 2]'
        [self swizzleMethodWithClassName:@"__NSArrayM" originalSelectorStr:@"objectAtIndex:" swizzledSelectorStr:@"unCrash_objectAtIndex:"];
        
        //-[__NSArrayM setObject:atIndexedSubscript:]: object cannot be nil'
        [self swizzleMethodWithClassName:@"__NSArrayM" originalSelectorStr:@"setObject:atIndexedSubscript:" swizzledSelectorStr:@"unCrash_setObject:atIndexedSubscript:"];
        
         //-[__NSArrayM insertObject:atIndex:]: object cannot be nil'
        [self swizzleMethodWithClassName:@"__NSArrayM" originalSelectorStr:@"insertObject:atIndex:" swizzledSelectorStr:@"unCrash_insertObject:atIndex:"];
        
    });
}

//MARK: 防止NSMutableArray数组添加nil值
- (void)unCrash_insertObject:(id)obj atIndex:(NSUInteger)index {
    //过滤掉nil值
    if (!obj) {
        NSLog(@"NSMutableArray第%lu个元素遇到nil值,被过滤掉",(unsigned long)index);
        return;
    } else {
        [self unCrash_insertObject:obj atIndex:index];
    }
}

//MARK: 防止NSMutableArray数组插入nil值
- (void)unCrash_setObject:(id)obj atIndexedSubscript:(NSUInteger)index {
    //过滤掉nil值
    if (!obj) {
        NSLog(@"NSMutableArray第%lu个元素遇到nil值,被过滤掉",(unsigned long)index);
        return;
    } else {
        [self unCrash_setObject:obj atIndexedSubscript:index];
    }
}


//MARK: 防止NSMutableArray数组越界崩溃
- (id)unCrash_objectAtIndex:(NSUInteger)index{
    if (self.count - 1 < index) { //数组越界
        //做异常处理,否则会崩溃
        @try{
            //MARK: 调用此方法会交换城调用[self objectAtIndex:index];方法
            //return [self unCrash_objectAtIndex:index];
            NSLog(@"NSMutableArray数组越界");
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            return nil;
        }@catch(NSException *exception) {
            NSLog(@"---------- %s Crash Because Method %s  ----------\n", class_getName(self.class), __func__);
            NSLog(@"%@",[exception callStackSymbols]);
            return nil;
        }@finally{}
    } else { //否则数组不越界
        return [self unCrash_objectAtIndex:index];
    }
}

@end




