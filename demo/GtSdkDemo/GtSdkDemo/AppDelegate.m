//
//  AppDelegate.m
//  Demo
//
//  Created by CoLcY on 11-12-29.
//  Copyright (c) 2011年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

#define NotifyActionKey "NotifyAction"
NSString *const NotificationCategoryIdent = @"ACTIONABLE";
NSString *const NotificationActionOneIdent = @"ACTION_ONE";
NSString *const NotificationActionTwoIdent = @"ACTION_TWO";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.viewController.title = [NSString stringWithFormat:@"个推开发平台测试客户端V%@", [GeTuiSdk version]];

    _naviController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    _naviController.navigationBar.translucent = NO;
    self.window.rootViewController = _naviController;
    [self.window makeKeyAndVisible];

    // [1]:使用APPID/APPKEY/APPSECRENT创建个推实例
    // 注：该代码写法仅适用演示Demo，正式集成可简化，请参考“集成Demo”
    // 该方法需要在主线程中调用
    [self startSdkWith:[AppDelegate getGtAppId] appKey:[AppDelegate getGtAppKey] appSecret:[AppDelegate getGtAppSecret]];

    // [2]:注册APNS
    [self registerRemoteNotification];

    // [2-EXT]: 获取启动时收到的APN数据
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], userInfo];
        [_viewController logMsg:record];
    }

    //    [ExceptionHandler installExceptionHandler];

    return YES;
}

#pragma mark - background fetch  唤醒
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    //[5] Background Fetch 恢复SDK 运行
    [GeTuiSdk resume];

    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - 用户通知(推送) _自定义方法

/** 注册远程通知 */
- (void)registerRemoteNotification {

#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        //IOS8 新的通知机制category注册
        UIMutableUserNotificationAction *action1;
        action1 = [[UIMutableUserNotificationAction alloc] init];
        [action1 setActivationMode:UIUserNotificationActivationModeBackground];
        [action1 setTitle:@"取消"];
        [action1 setIdentifier:NotificationActionOneIdent];
        [action1 setDestructive:NO];
        [action1 setAuthenticationRequired:NO];

        UIMutableUserNotificationAction *action2;
        action2 = [[UIMutableUserNotificationAction alloc] init];
        [action2 setActivationMode:UIUserNotificationActivationModeBackground];
        [action2 setTitle:@"回复"];
        [action2 setIdentifier:NotificationActionTwoIdent];
        [action2 setDestructive:NO];
        [action2 setAuthenticationRequired:NO];

        UIMutableUserNotificationCategory *actionCategory;
        actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier:NotificationCategoryIdent];
        [actionCategory setActions:@[ action1, action2 ]
                        forContext:UIUserNotificationActionContextDefault];

        NSSet *categories = [NSSet setWithObject:actionCategory];
        UIUserNotificationType types = (UIUserNotificationTypeAlert |
                                        UIUserNotificationTypeSound |
                                        UIUserNotificationTypeBadge);

        UIUserNotificationSettings *settings;
        settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                   UIRemoteNotificationTypeSound |
                                                                   UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}

#pragma mark - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken:%@", token);

    // [3]:向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // [3-EXT]:如果APNS注册失败，通知个推服务器
    [GeTuiSdk registerDeviceToken:@""];
    [_viewController logMsg:[NSString stringWithFormat:@"didFailToRegisterForRemoteNotificationsWithError:%@", [error localizedDescription]]];
}

#pragma mark - APP运行中接收到通知(推送)处理

/** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    // [4-EXT]:处理APN
    NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], userInfo];
    [_viewController logMsg:record];
}

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {

    // [4-EXT]:处理APN
    NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], userInfo];
    [_viewController logMsg:record];

    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - 启动GeTuiSdk

/**
 获取个推的AppId、AppKey、AppSecret
 注：该代码写法仅适用演示Demo，正式集成可简化，请参考“集成Demo”
 */
+ (NSString *)getGtAppId {
    NSString *reValue = kGtAppId;

    // 添加额外代码，方便测试修改App配置
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"gtsdk" ofType:@"plist"];
    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:configPath];
    if (configs) {
        // SDK测试使用的appid
        NSString *appid = configs[@"com.getui.kGTAppId"];
        if (appid && [appid isKindOfClass:[NSString class]] && appid.length) {
            reValue = appid;
        }
    }

    return reValue;
}
+ (NSString *)getGtAppKey {
    NSString *reValue = kGtAppKey;

    // 添加额外代码，方便测试修改App配置
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"gtsdk" ofType:@"plist"];
    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:configPath];
    if (configs) {
        // SDK测试使用的appkey
        NSString *appkey = configs[@"com.getui.kGTAppKey"];
        if (appkey && [appkey isKindOfClass:[NSString class]] && appkey.length) {
            reValue = appkey;
        }
    }

    return reValue;
}
+ (NSString *)getGtAppSecret {
    NSString *reValue = kGtAppSecret;

    // 添加额外代码，方便测试修改App配置
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"gtsdk" ofType:@"plist"];
    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:configPath];
    if (configs) {
        // SDK测试使用的appid
        NSString *appsecret = configs[@"com.getui.kGTAppSecret"];
        if (appsecret && [appsecret isKindOfClass:[NSString class]] && appsecret.length) {
            reValue = appsecret;
        }
    }

    return reValue;
}

- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret {

    // 添加额外代码，方便测试修改App配置
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"gtsdk" ofType:@"plist"];
    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:configPath];
    if (configs) {
        // SDK测试使用的appid
        NSString *appid = configs[@"com.getui.kGTAppId"];
        if (appid && [appid isKindOfClass:[NSString class]] && appid.length) {
            appID = appid;
        }

        NSString *appkey = configs[@"com.getui.kGTAppKey"];
        if (appkey && [appkey isKindOfClass:[NSString class]] && appkey.length) {
            appKey = appkey;
        }

        NSString *appsecret = configs[@"com.getui.kGTAppSecret"];
        if (appsecret && [appsecret isKindOfClass:[NSString class]] && appsecret.length) {
            appSecret = appsecret;
        }
    }

    //[1-1]:通过 AppId、 appKey 、appSecret 启动SDK
    //该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:appID appKey:appKey appSecret:appSecret delegate:self];
    [GeTuiSdk runBackgroundEnable:YES];
    [GeTuiSdk lbsLocationEnable:YES andUserVerify:YES];
}

#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    NSLog(@">>>[GeTuiSdk RegisterClient]:%@", clientId);
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId andOffLine:(BOOL)offLine fromApplication:(NSString *)appId {
    // [4]: 收到个推消息
    NSData *payload = [GeTuiSdk retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length
                                            encoding:NSUTF8StringEncoding];
    }

    NSString *record = [NSString stringWithFormat:@"%d, %@, %@%@", ++_lastPayloadIndex, [self formateTime:[NSDate date]], payloadMsg, offLine ? @"<离线消息>" : @""];
    [_viewController logMsg:record];

    NSString *msg = [NSString stringWithFormat:@"%@ : %@%@", [self formateTime:[NSDate date]], payloadMsg, offLine ? @"<离线消息>" : @""];
    NSLog(@"GexinSdkReceivePayload : %@, taskId: %@, msgId :%@", msg, taskId, aMsgId);

    /**
     *汇报个推自定义事件
     *actionId：用户自定义的actionid，int类型，取值90001-90999。
     *taskId：下发任务的任务ID。
     *msgId： 下发任务的消息ID。
     *返回值：BOOL，YES表示该命令已经提交，NO表示该命令未提交成功。注：该结果不代表服务器收到该条命令
     **/
    [GeTuiSdk sendFeedbackMessage:90001 taskId:taskId msgId:aMsgId];
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
    NSString *record = [NSString stringWithFormat:@"Received sendmessage:%@ result:%d", messageId, result];
    [_viewController logMsg:record];
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    [_viewController logMsg:[NSString stringWithFormat:@">>>[GexinSdk error]:%@", [error localizedDescription]]];
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // [EXT]:通知SDK运行状态
    [_viewController updateStatusView:self];
}

//SDK设置推送模式回调
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        [_viewController logMsg:[NSString stringWithFormat:@">>>[SetModeOff error]: %@", [error localizedDescription]]];
        return;
    }

    [_viewController logMsg:[NSString stringWithFormat:@">>>[GexinSdkSetModeOff]: %@", isModeOff ? @"开启" : @"关闭"]];

    UIViewController *vc = _naviController.topViewController;
    if ([vc isKindOfClass:[ViewController class]]) {
        ViewController *nextController = (ViewController *) vc;
        [nextController updateModeOffButton:isModeOff];
    }
}

- (NSString *)formateTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

@end
