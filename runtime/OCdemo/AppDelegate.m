//
//  AppDelegate.m
//  OCdemo
//
//  Created by zhouyu on 2017/9/2.
//  Copyright © 2017年 zhouyu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark 防止数组越界
- (void)testNSArrayBoundsUnCrash{
    
    NSArray *arr = [NSArray arrayWithObjects:@"1",@"2",@"3", nil];
    // 此处会引起崩溃
    NSString *str = [arr objectAtIndex:4];
    
    NSMutableArray *arrM = [NSMutableArray arrayWithObjects:@"1",@"2",@"3", nil];
    // 此处会引起崩溃
    NSString *strM = [arrM objectAtIndex:4];
}

#pragma mark 防止插入nil值
- (void)testNSArrayNilUnCrash{
    
    id nilObj = nil;
    
    //-[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[1]'
    // 此处会引起崩溃
    NSArray *arr = @[@"obj",nilObj,@"last"];
    
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:2];
    
    // 此处会引起崩溃
    mArray[0] = nilObj;
    
    // 此处会引起崩溃
    [mArray addObject:nilObj];
}

- (void)testDictionaryBoundsUnCrash{
    id nilObj  = nil;
    NSString *str = nil;
    
    // 此处会引起崩溃
    NSDictionary *dict1 = @{str: @"aa", @"bb": @"bb"};
    [dict1 objectForKey:str];
    NSLog(@"dict: %@", dict1);
    
    // 此处会引起崩溃
    NSDictionary *dict2 = @{@"aa": nilObj, @"bb": @"bb"};
    NSLog(@"dict: %@", dict2);
    
    NSMutableDictionary *mDict = [NSMutableDictionary new];
    mDict[@"aaa"] = nilObj; // 此处不会有问题
    [mDict setObject:@"bbb" forKey:@"bbb"];
    
    // 2. 此处会引起崩溃
    [mDict setObject:nilObj forKey:@"ccc"];
    [mDict setObject:@"aaa" forKey:str];
    
    NSLog(@"mDict: %@", mDict);
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self testNSArrayBoundsUnCrash];
    [self testNSArrayNilUnCrash];
    [self testDictionaryBoundsUnCrash];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
