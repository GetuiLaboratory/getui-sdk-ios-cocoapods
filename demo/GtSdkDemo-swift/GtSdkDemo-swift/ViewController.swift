//
//  ViewController.swift
//  GtSdkDemo-swift
//
//  Created by 赵伟 on 15/10/12.
//  Copyright © 2015年 赵伟. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickActionButton(sender: AnyObject) {
        switch sender.tag {
        case 20:    // 启动/停止
            if (GeTuiSdk.status() == SdkStatusStoped) {
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                GeTuiSdk .startSdkWithAppId(kGtAppId, appKey: kGtAppKey, appSecret: kGtAppSecret, delegate: delegate);
                
                NSLog("\n\n>>>[GeTui]:%@\n\n","启动APP");
            }else if (GeTuiSdk.status() == SdkStatusStarted || GeTuiSdk.status() == SdkStatusStarting) {
                [GeTuiSdk.stopSdk()];
                
                NSLog("\n\n>>>[GeTui]:%@\n\n","停止APP");
            }
            
            break
        case 21:    // 获取状态
            if (GeTuiSdk.status() == SdkStatusStarted) {
                NSLog("\n\n>>>[GeTui status]:%@\n\n","启动");
            }else if (GeTuiSdk.status() == SdkStatusStarting) {
                NSLog("\n\n>>>[GeTui status]:%@\n\n","正在启动");
            }else if (GeTuiSdk.status() == SdkStatusStoped) {
                NSLog("\n\n>>>[GeTui status]:%@\n\n","停止");
            }
            
            break
            
        case 22:           // 获取CID
            NSLog("\n\n>>>[GeTui clientId]:%@\n\n",GeTuiSdk.clientId());
            
            break
            
        case 23:           // 获取个推SDK版本
            NSLog("\n\n>>>[GeTui version]:%@\n\n",GeTuiSdk.version());
            
            break
            
        case 24:           // 注册DeviceToken
            GeTuiSdk.registerDeviceToken("");
            NSLog("调用注册DeviceToken");
            
            break
            
        case 25:      // 设置标签
            let tagName: NSString = "个推,推送,iOS";
            let tagNames: NSArray = tagName.componentsSeparatedByString(",");
            
            if (!GeTuiSdk.setTags(tagNames as [AnyObject])) {
                let alertView: UIAlertView = UIAlertView();
                alertView.title = "Failed";
                alertView.message = "setTag failed";
                alertView.addButtonWithTitle("OK");
                alertView.show();
            }
            
            NSLog("调用设置标签");
            
            break
            
        case 26:           // 绑定别名
            GeTuiSdk.bindAlias("个推研发")
            
            NSLog("调用绑定别名")
            
            break
        case 27:          // 取消绑定别名
            GeTuiSdk.unbindAlias("个推研发")
            
            NSLog("调用取消绑定别名")
            
            break
        case 28:            // 发送消息
            
            let content = "测试个推发消息功能"

            do{
                try
                    GeTuiSdk.sendMessage(content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
            } catch let error as NSError {
                print("sendMessage With Error: \(error.description)")
            }
            
            NSLog("调用发送消息");
            
            break
        default: break
        }
    }
    
}

