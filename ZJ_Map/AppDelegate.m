//
//  AppDelegate.m
//  ZJ_Map
//
//  Created by lanou3g on 15/12/20.
//  Copyright © 2015年 zhangjianjun. All rights reserved.
//

#import "AppDelegate.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import "ZJViewController.h"
#import "BNCoreServices.h"//导航头文件
@interface AppDelegate ()

@property (nonatomic, strong) BMKMapManager * mapManager;

@property (nonatomic, strong) ZJViewController * zjViewController1;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [self.mapManager start:@"NtgCl6tjxQuflGd6cDFLZUsG"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    else
    {
        //        NSLog(@"地图打开成功!!!");
    }
    
    [BNCoreServices_Instance initServices:@"NtgCl6tjxQuflGd6cDFLZUsG"];
    [BNCoreServices_Instance startServicesAsyn:nil fail:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.zjViewController1 = [[ZJViewController alloc] init];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self.zjViewController1];
    self.window.rootViewController = navigationController;
    
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
