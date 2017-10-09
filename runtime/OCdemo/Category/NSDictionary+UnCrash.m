//
//  NSDictionary+UnCrash.m
//  OCdemo
//
//  Created by zhouyu on 2017/9/6.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "NSDictionary+UnCrash.h"
#include <objc/runtime.h>

@implementation NSDictionary (UnCrash)

    //-[__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[0]'
+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        //-[__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[0]'
        [self swizzleMethodWithClassName:@"__NSPlaceholderDictionary" originalSelectorStr:@"initWithObjects:forKeys:count:" swizzledSelectorStr:@"unCrash_initWithObjects:forKeys:count:"];

    });
}

#pragma mark 防止初始化时有nil项
- (id)unCrash_initWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)count{
    id nObjects[count];
    id nKeys[count];
    int i=0, newCount=0;
    //过滤掉key或者vaule为nil的选项
    for (; i<count && newCount<count; i++) {
        if (objects[i] && keys[i]) {
            nObjects[newCount] = objects[i];
            nKeys[newCount] = keys[i];
            newCount++;
        }
        if (!objects[i] || !keys[i]) {
            NSLog(@"字典第%d个元素key或者value出现了nil值,被过滤掉",i);
        }
    }
    return [self unCrash_initWithObjects:nObjects forKeys:nKeys count:newCount];
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



@implementation NSMutableDictionary (UnCrash)

+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // -[__NSDictionaryM setObject:forKey:]
        [self swizzleMethodWithClassName:@"__NSDictionaryM" originalSelectorStr:@"setObject:forKey:" swizzledSelectorStr:@"unCrash_setObject:forKey:"];
        
    });
}

- (void)unCrash_setObject:(id)obj forKey:(id<NSCopying>)key {
    
    if (!obj || !key) {
        NSLog(@"NSMutableDictionary插入值时遇到nil值,被过滤掉");
        return;
    }else {
        [self unCrash_setObject:obj forKey:key];
    }
}


@end
