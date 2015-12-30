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
        
        // 通过 appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
        GeTuiSdk.startSdkWithAppId(kGtAppId, appKey: kGtAppKey, appSecret: kGtAppSecret, delegate: self);
        
        // 注册Apns
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
        
        // [3]:向个推服务器注册deviceToken
        GeTuiSdk.registerDeviceToken(token);
        
        NSLog("\n>>>[DeviceToken Success]:%@\n\n",token);
    }
    
    /** 远程通知注册失败委托 */
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        //[3-EXT]:如果APNS注册失败,通知个推服务器
        GeTuiSdk.registerDeviceToken("")
        
         NSLog("\n>>>[DeviceToken Error]:%@\n\n",error.description);
    }
    
    // MARK: - APP运行中接收到通知(推送)处理

    /** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        application.applicationIconBadgeNumber = 0;        // 标签
        
        NSLog("\n>>>[Receive RemoteNotification]:%@\n\n",userInfo);
    }
    
    // MARK: - GeTuiSdkDelegate
    
    /** SDK启动成功返回cid */
    func GeTuiSdkDidRegisterClient(clientId: String!) {
        // [4-EXT-1]: 个推SDK已注册，返回clientId
        NSLog("\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
    }
    
    /** SDK收到透传消息回调 */
    func GeTuiSdkDidReceivePayload(payloadId: String!, andTaskId taskId: String!, andMessageId aMsgId: String!, andOffLine offLine: Bool, fromApplication appId: String!) {
        
        /**
        *汇报个推自定义事件
        *actionId：用户自定义的actionid，int类型，取值90001-90999。
        *taskId：下发任务的任务ID。
        *msgId： 下发任务的消息ID。
        *返回值：BOOL，YES表示该命令已经提交，NO表示该命令未提交成功。注：该结果不代表服务器收到该条命令
        **/
        GeTuiSdk .sendFeedbackMessage(90001, taskId: taskId, msgId: aMsgId);
    }
    
    /** SDK遇到错误回调 */
    func GeTuiSdkDidOccurError(error: NSError!) {
        // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
        NSLog("\n>>>[GexinSdk error]:%@\n\n", error.localizedDescription);
    }
    
    /** SDK收到sendMessage消息回调 */
    func GeTuiSdkDidSendMessage(messageId: String!, result: Int32) {
        // [4-EXT]:发送上行消息结果反馈
        let msg:String = "sendmessage=\(messageId),result=\(result)";
        NSLog("\n>>>[GexinSdk DidSendMessage]:%@\n\n",msg);
    }
}

