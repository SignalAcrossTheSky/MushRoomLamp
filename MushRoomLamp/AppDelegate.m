//
//  AppDelegate.m
//  MushRoomLamp
//
//  Created by SongGang on 6/23/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "AppDelegate.h"
#import "ZJMainTabBarController.h"
#import "ZJHomeController.h"
#import "ZJAddEquipmentViewController.h"
#import "ZJSettingViewController.h"
#import "ZJLoginViewController.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "ZJAEInputWifiViewController.h"
#import "ZJCommonFuction.h"
#import "JPUSHService.h"
#import "ZJDayReportViewController.h"
#import "ZJLoginAndRegisterViewController.h"
#import <AdSupport/AdSupport.h>
#import "ZJDayReportViewController.h"

@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    
    //Required
    // init Push(2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil  )
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:@"6278744dd641c09c39c46b60"
                          channel:@"Publish channel"
                 apsForProduction:false
            advertisingIdentifier:advertisingId];
    
    [self setUMengAppKey];
   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSString *token = [userDefault objectForKey:@"token"];
    
//    ZJDayReportViewController *vc = [[ZJDayReportViewController alloc] init];
//    self.window.rootViewController = vc;
    
    if (token == nil || [token isEqualToString:@""]) {
        ZJLoginAndRegisterViewController *vc = [[ZJLoginAndRegisterViewController alloc] init];
//      ZJLoginViewController *vc = [[ZJLoginViewController alloc] init];
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = nv;
    }else
    {
        ZJMainTabBarController *tabBarController = [[ZJMainTabBarController alloc] init];
        self.window.rootViewController = tabBarController;

    }
    [NSThread sleepForTimeInterval:2.0];
    //启动并显示窗口
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application  didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [JPUSHService registerDeviceToken:deviceToken];

    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *newdeviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken:%@", newdeviceToken);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    [self handleNotfication:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"Regist fail%@",error);
}
/**
 * 设置友盟
 */
- (void)setUMengAppKey
{
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:@"578c9262e0f55a3056001dc4"];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wxd6627c4f081032e0" appSecret:@"e2e952a8d0981cc61e6bea4b86b8a437" url:@"http://www.umeng.com/social"];
    //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
//    [UMSocialQQHandler setQQWithAppId:@"1105552432" appKey:@"UQu7TGZhUkhGv2bj" url:@"http://www.baidu.com"];
//    打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。需要 #import "UMSocialSinaSSOHandler.h"
//    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"3921700954"
//                                              secret:@"04b48b094faeb16683c32669824ebdad"
//                                         RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
    }
    return result;

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STOPWEBSOCKET" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAddEqu" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STARTWEBSOCKET" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
//     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WEBSOCKET" object:nil];
}


- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
   
    NSDictionary * userInfo = notification.request.content.userInfo;
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    [self handleNotfication:userInfo];
}



/**
 * 处理通知
 */
- (void)handleNotfication:(NSDictionary *)userInfo
{
    if([userInfo[@"type"] isEqualToString:@"blood_result"])
    {
        if ([[ZJCommonFuction getCurrentVC] isKindOfClass:[ZJMainTabBarController class]]) {
            
            ZJMainTabBarController *bc = (ZJMainTabBarController *)[ZJCommonFuction getCurrentVC];
            
            if(bc.selectedIndex == 0)
            {
                UINavigationController *nc = bc.selectedViewController;
                UIViewController *currentVC = [[nc viewControllers] lastObject];
                if ([currentVC isKindOfClass:[ZJHomeController class]]) {
                    ZJHomeController *hv = (ZJHomeController *)currentVC;
                    if (hv.bpView == nil) {
                        [hv popBloodPressView];
                    }
                    [hv.bpView setResultStateWithDic:userInfo];
                }else
                {
                    ZJHomeController *hv = (ZJHomeController *)[[nc viewControllers] firstObject];
                    if (hv.bpView == nil) {
                        [hv popBloodPressView];
                    }
                    [hv.bpView setResultStateWithDic:userInfo];
                    [nc popToRootViewControllerAnimated:YES];
                }
            }else
            {
                bc.selectedIndex = 0;
                UINavigationController *nc = (UINavigationController *)[bc.viewControllers firstObject];
                ZJHomeController *hv = (ZJHomeController *)[[nc viewControllers] firstObject];
                if (hv.bpView == nil) {
                    [hv popBloodPressView];
                }
                [hv.bpView setResultStateWithDic:userInfo];
            }
        }
    }else if([userInfo[@"type"] isEqualToString:@"deviceDailyReport"]) {
        if ([[ZJCommonFuction getCurrentVC] isKindOfClass:[ZJMainTabBarController class]]) {
            
            ZJMainTabBarController *bc = (ZJMainTabBarController *)[ZJCommonFuction getCurrentVC];
            
            if(bc.selectedIndex == 0)
            {
                UINavigationController *nc = bc.selectedViewController;
                UIViewController *currentVC = [[nc viewControllers] lastObject];
                if ([currentVC isKindOfClass:[ZJHomeController class]]) {
                    ZJHomeController *hv = (ZJHomeController *)currentVC;
                    ZJDayReportViewController *vc = [[ZJDayReportViewController alloc] init];
                    [hv presentViewController:vc animated:YES completion:^{
                        
                    }];
                }else
                {
                    ZJHomeController *hv = (ZJHomeController *)[[nc viewControllers] firstObject];
                    ZJDayReportViewController *vc = [[ZJDayReportViewController alloc] init];
                    [hv presentViewController:vc animated:YES completion:^{
                        
                    }];
                }
            }else
            {
                bc.selectedIndex = 0;
                UINavigationController *nc = (UINavigationController *)[bc.viewControllers firstObject];
                ZJHomeController *hv = (ZJHomeController *)[[nc viewControllers] firstObject];
                ZJDayReportViewController *vc = [[ZJDayReportViewController alloc] init];
                [hv presentViewController:vc animated:YES completion:^{
                    
                }];
            }
        }
    }    
}

@end
