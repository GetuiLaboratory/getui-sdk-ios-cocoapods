//
//  AppDelegate.swift
//  GtSdkDemo-swift
//
//  Created by 赵伟 on 15/10/12.
//  Copyright © 2015年 赵伟. All rights reserved.
//

import UIKit

let kGtAppId:String = "iMahVVxurw6BNr7XSn9EF2"
let kGtAppKey:String = "yIPfqwq6OMAPp6dkqgLpG5"
let kGtAppSecret:String = "G0aBqAD6t79JfzTB6Z5lo5"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GeTuiSdkDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // [ GTSdk ]：是否允许APP后台运行
//        GeTuiSdk.runBackgroundEnable(true);
        
        // [ GTSdk ]：是否运行电子围栏Lbs功能和是否SDK主动请求用户定位
        GeTuiSdk.lbsLocationEnable(true, andUserVerify: true);
        
        // [ GTSdk ]：自定义渠道
        GeTuiSdk.setChannelId("GT-Channel");
        
        // [ GTSdk ]：使用APPID/APPKEY/APPSECRENT启动个推
        GeTuiSdk.startSdkWithAppId(kGtAppId, appKey: kGtAppKey, appSecret: kGtAppSecret, delegate: self);
        
        // 注册APNs - custom method - 开发者自定义的方法
        self.registerUserNotification(application);
        
        return true
    }
    
    // MARK: - 用户通知(推送) _自定义方法
    
    /** 注册用户通知(推送) */
    func registerUserNotification(application: UIApplication) {
        let result = UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch)
        if (result != NSComparisonResult.OrderedAscending) {
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            let userSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(userSettings)
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes([.Alert, .Sound, .Badge])
        }
    }
    
    // MARK: - 远程通知(推送)回调

    /** 远程通知注册成功委托 */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"));
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
            
        // [ GTSdk ]：向个推服务器注册deviceToken
        GeTuiSdk.registerDeviceToken(token);

        NSLog("\n>>>[DeviceToken Success]:%@\n\n",token);
    }
    
    /** 远程通知注册失败委托 */
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
         NSLog("\n>>>[DeviceToken Error]:%@\n\n",error.description);
    }
    
    // MARK: - APP运行中接收到通知(推送)处理

    /** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        application.applicationIconBadgeNumber = 0;        // 标签
        
        NSLog("\n>>>[Receive RemoteNotification]:%@\n\n",userInfo);
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        // [ GTSdk ]：将收到的APNs信息传给个推统计
        GeTuiSdk.handleRemoteNotification(userInfo);
        
        NSLog("\n>>>[Receive RemoteNotification]:%@\n\n",userInfo);
        completionHandler(UIBackgroundFetchResult.NewData);
    }
    
    // MARK: - GeTuiSdkDelegate
    
    /** SDK启动成功返回cid */
    func GeTuiSdkDidRegisterClient(clientId: String!) {
        // [4-EXT-1]: 个推SDK已注册，返回clientId
        NSLog("\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
    }
    
    /** SDK遇到错误回调 */
    func GeTuiSdkDidOccurError(error: NSError!) {
        // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
        NSLog("\n>>>[GeTuiSdk error]:%@\n\n", error.localizedDescription);
    }
    
    /** SDK收到sendMessage消息回调 */
    func GeTuiSdkDidSendMessage(messageId: String!, result: Int32) {
        // [4-EXT]:发送上行消息结果反馈
        let msg:String = "sendmessage=\(messageId),result=\(result)";
        NSLog("\n>>>[GeTuiSdk DidSendMessage]:%@\n\n",msg);
    }
    
    func GeTuiSdkDidReceivePayloadData(payloadData: NSData!, andTaskId taskId: String!, andMsgId msgId: String!, andOffLine offLine: Bool, fromGtAppId appId: String!) {
        
        var payloadMsg = "";
        if((payloadData) != nil) {
            payloadMsg = String.init(data: payloadData, encoding: NSUTF8StringEncoding)!;
        }
        
        let msg:String = "Receive Payload: \(payloadMsg), taskId:\(taskId), messageId:\(msgId)";
        
        NSLog("\n>>>[GeTuiSdk DidReceivePayload]:%@\n\n",msg);
    }
}

