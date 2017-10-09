//
//  ViewController.m
//  OCdemo
//
//  Created by zhouyu on 2017/9/2.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "ViewController.h"
#include <objc/runtime.h>
#import "UIView+myView.h"
#import "newViewController.h"

@interface ViewController ()
{
    int _age;
    char *version;
}
@property (nonnull,nonatomic,strong) NSString *type;
@property (nonnull,nonatomic,strong) UILabel *label;
@property (nonnull,nonatomic,strong) UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //分类添加属性
//    [self addPropertyForCategory];
    
    //消息动态解析和消息转发
//    [self messageDemo];
    
    //动态创建类,添加变量,属性,方法,并进进行访问操作
//    [self demoClass];
}

#pragma mark 消息动态解析和消息转发
- (void)messageDemo{
    //MARK: 动态方法处理
    newViewController *newVc = [[newViewController alloc] init];
    [newVc testMessageDynamicResolution];
    [newViewController testClassMessageDynamicResolution];
}

#pragma mark 分类动态添加属性
- (void)addPropertyForCategory{
    //给分类利用runtime添加属性
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 100, 100)];
    myView.type = @"myView";
}

#pragma mark 动态创建类,添加成员变量,属性,方法
- (void)demoClass{

    const char *className;
    className = [@"CreateClass" UTF8String];
    //创建新类
    Class newClass = objc_getClass(className); //nil
    if (!newClass) {
        //指定元类
        Class superClass = [NSObject class];
        newClass = objc_allocateClassPair(superClass, className, 0);
        NSLog(@"%@",newClass);//CreateClass: 0x6000000101a0
    }
    
    //添加3个成员变量_name,_tpye,_address--都是NSString * 类型的
    class_addIvar(newClass, "_name", sizeof(NSString *), 0, "@");
    class_addIvar(newClass, "_type", sizeof(NSString *), 0, "@");
    class_addIvar(newClass, "_address", sizeof(NSString *), 0, "@");
    
    //_name添加@property属性--objc_property_attribute_t  {name,value}
    /*
     1 属性类型  name值：T  value：变化
     2 编码类型  name值：C(copy) &(strong) W(weak) 空(assign) 等 value：无
     3 非/原子性 name值：空(atomic) N(Nonatomic)  value：无
     */
    objc_property_attribute_t type = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "copy" };
    objc_property_attribute_t backingivar  = { "V", "_name"};
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    class_addProperty(newClass, "name", attrs, 3);
    
    //添加方法
    //set方法
    class_addMethod(newClass, @selector(setName:), (IMP)setName, "V@:");
    //get方法
    class_addMethod(newClass, @selector(name), (IMP)name, "@@:");
    
    //注册class到运行时环境
    objc_registerClassPair(newClass);
    //创建对象
    id newObject = [[newClass alloc] init];
    
    //给属性赋值setter
    [newObject setName:@"zhouyu"];
    //调用getter方法获取属性值--三种方法实现
    //    NSString *newName = [newObject name];
    NSString *newName = [newObject performSelector:@selector(name)];
    //    objc_ms
    NSLog(@"%@",newName);
    
    //直接给实例变量赋值
    //首先获取结构体类型的实例变量--实例变量都是在类结构体中
    Ivar nameIvar = class_getInstanceVariable([newObject class], "_name");
    object_setIvar(newObject, nameIvar,@"wangpengfei");
    
    Ivar typeIvar = class_getInstanceVariable(newClass, "_type");
    object_setIvar(newObject, typeIvar, @"女");
    
    //访问属性
    NSLog(@"%@",object_getIvar(newObject, nameIvar));
    NSLog(@"%@",object_getIvar(newObject, typeIvar));
    
    //MARK: 遍历和改变成员变量
    unsigned int count = 0;
    //1. 获取某个类的成员变量列表
    Ivar *ivarList = class_copyIvarList(newClass, &count);
    //2.遍历成员变量列表
    for (int i=0; i < count; i++) {
        const char *ivarName = ivar_getName(ivarList[i]);
        NSString *ivarNameStr = [NSString stringWithUTF8String:ivarName];
        NSLog(@"%@",ivarNameStr);
        //3.找到要改变的变量
        if ([ivarNameStr isEqualToString:@"_name"]) {
            //4.修改变量的值
            object_setIvar(newObject, ivarList[i], @"张三");
        }
    }
    //5.释放内存
    free(ivarList);
    NSLog(@"%@",object_getIvar(newObject, nameIvar));
    //MARK: 总结:  添加和获取实例变量用类操作,设置和修改实例变量的值用对象操作
    
    //MARK: 获取所有方法
    unsigned int methodCount;
    //获取所有方法列表
    Method *methodList = class_copyMethodList([newObject class], &methodCount);
    for (int i = 0; i < methodCount; i++) {
        //每一个方法的封装体
        Method methodName = methodList[i];
        //方法的声明和实现
        SEL methodDefine = method_getName(methodName);
        IMP imp = method_getImplementation(methodName);
        //方法的名字字符和参数个数和类型编码
        const char *funcName = sel_getName(methodDefine);
        int argumentConut = method_getNumberOfArguments(methodName);
        const char *encodeing = method_getTypeEncoding(methodName);
        NSLog(@"方法名: %@,  参数个数: %d,  编码方式: %@",[NSString stringWithUTF8String:funcName],argumentConut,[NSString stringWithUTF8String:encodeing]);
    }
    free(methodList);
    
    //MARK: 获取类的所有属性和属性的内容
    unsigned int propertyCount;
    objc_property_t *propertyList = class_copyPropertyList(newClass, &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t objcProperty = propertyList[i];
        const char *propertyNameChar = property_getName(objcProperty);
        NSString *propertyNameStr = [NSString stringWithUTF8String:propertyNameChar];
        NSString *propertyValueStr = [newObject valueForKey:propertyNameStr];
        NSLog(@"属性名: %@, 属性值: %@",propertyNameStr,propertyValueStr);
    }

}

#pragma mark  runtime是C语法,所以只有函数没有方法,函数调用时直接调用,和方法无关,思路得转变过来
//IMP方法是C语言函数
//runtime定义set函数
void setName(id self, SEL _cmd, NSString *str){
    NSLog(@"%s",__func__);
    //typedef struct objc_ivar *Ivar;
    Ivar ivar = class_getInstanceVariable([self class], "_name");
    id oldName = object_getIvar(self, ivar);
    if (oldName != str) {
        object_setIvar(self, ivar, [str copy]);
    }
}
//runtime定义get函数
NSString *name(id self, SEL _cmd){
    NSLog(@"%@",self);
    NSLog(@"%s",__func__);
    Ivar ivar = class_getInstanceVariable([self class], "_name");
    return object_getIvar(self, ivar);
}

//OC版的get,set方法
//- (NSString *)name{
//    
//}
//- (void)setName:(NSString *)name{
//    
//}



@end
