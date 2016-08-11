//
//  AppDelegate.m
//  Receive
//
//  Created by 吕家腾 on 16/8/1.
//  Copyright © 2016年 Kingsoft. All rights reserved.
//

#import "AppDelegate.h"
#import "WPSDragDataSDK.h"

@interface AppDelegate () < WPSDragDataDelegate >

@end

static void callback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    if (![[WPSDragDataSDK shareManager] isOpenSucceed])
    {
        // 同时只能有一个接收者(控制器)去连接对方，不能同时多个接收者(控制器)去连接
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDragData" object:nil];
    }
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [WPSDragDataSDK setDebugMode:YES];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[WPSDragDataSDK shareManager] removeObserver:self];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[WPSDragDataSDK shareManager] setApplicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[WPSDragDataSDK shareManager] addObserver:self callback:callback];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[WPSDragDataSDK shareManager] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    if ([WPSDragDataSDK parseHandleOpenURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDesignationFile" object:nil];
        return YES;
    }
    return NO;
}

@end
