//
//  UIView+myView.m
//  OCdemo
//
//  Created by 臣陈 on 2017/9/5.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "UIView+myView.h"
#include <objc/runtime.h>

@implementation UIView (myView)

- (void)setType:(NSString *)type{
    /**
     为某个类关联某个对象
     @param self object#> 要关联的对象 description#>
     @param name key#>    要关联的属性key description#>
     @param value value#>  你要关联的属性 description#>
     @param policy policy#> 添加的成员变量的修饰符 description#>
     @return nil
     */
    objc_setAssociatedObject(self, "type", type, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)type{
    /**
     获取到某个类的某个关联对象
     @param self object#> 关联的对象 description#>
     @param name key#>    属性的key值 description#>
     @return 返回这个对象的值
     */
    return objc_getAssociatedObject(self, "type");
}

@end
