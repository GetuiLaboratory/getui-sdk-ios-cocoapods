#!/bin/sh
InputAppid=$1
InputAppkey=$2
InputAppsecret=$3
if [[ -z $InputAppid ]] || [[ -z $InputAppkey ]] || [[ -z $InputAppsecret ]]; then
  echo "appid appkey appSecret输入有误，请重新运行"
  exit
  fi
fi
PACKAGENAME="xcworkspace"
APPDELEGATE_H="AppDelegate.h"
APPDELEGATE_M="AppDelegate.m"
PLIST="Info.plist"
ENTITLEMENTS="entitlements"
GTSDK="#import <GTSDK/GeTuiSdk.h>"
APPID="#define kGtAppId @\"$InputAppid\""
APPKEY="#define kGtAppKey @\"$InputAppkey\""
APPSECRET="#define kGtAppSecret @\"$InputAppsecret\""
IF="#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0"
USERNOTIFICATION="#import <UserNotifications\/UserNotifications.h>"
ENDIF="#endif"
#使用appid/appkey/appsecrent启动个推
GTSTARTANNOTATION="//[GTSdk ]:使用APPID/APPKEY/APPSECRET启动个推"
GTSTART="[GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];"
#注册apns
GTREGISTERAPNSANNOTATION="//注册APNs"
GTREGISTERAPNS="[self registerRemoteNotification];"
REGISTREMOTEN="- \(void\)registerRemoteNotification {"
NOTIFICATIONWARN="警告：Xcode8的需要手动开启\“TARGETS -> Capabilitiew -> Push Notifications”"
SYSTEMVERSION="if \([[UIDevice currentDevice].systemVersion floatValue] >="
UNUSERNOTIFICATIONCENTER="UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];"
CENTERREQUEST="[center requestAuthorizationWithOptions:\(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay\) completionHandler:^\(BOOL granted, NSError *_Nullable error\) {"
UIUSERNOTIFICATIONTYPE="\(UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge\);"
UIUSERNOTIFICATIONSET="UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];"
REGISTUNSETTING="[[UIApplication sharedApplication] registerUserNotificationSettings:settings];"
REGISTFORRN="[[UIApplication sharedApplication] registerForRemoteNotifications];"
GETTOKENSTRING="stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@\"<>\"]];"
DIDFINISHLAUNCHING="- \(BOOL\)application:\(UIApplication *\)application didFinishLaunchingWithOptions:\(NSDictionary *\)launchOptions {"
DIDREGISTFORRNWITHDEVICETOKEN="- \(void\)application:\(UIApplication *\)application didRegisterForRemoteNotificationsWithDeviceToken:\(NSData *\)deviceToken {"
DIDRECEIVEREMOTENOTIFICATION="- \(void\)application:\(UIApplication *\)application didReceiveRemoteNotification:\(NSDictionary *\)userInfo fetchCompletionHandler:\(void \(^\)\(UIBackgroundFetchResult result\)\)completionHandler {"
WILLPRESENTNOTIFICATION="- \(void\)userNotificationCenter:\(UNUserNotificationCenter *\)center willPresentNotification:\(UNNotification *\)notification withCompletionHandler:\(void \(^\)\(UNNotificationPresentationOptions\)\)completionHandler {"
DIDRECEIVENOTIFICATIONRESPONCE="- \(void\)userNotificationCenter:\(UNUserNotificationCenter *\)center didReceiveNotificationResponse:\(UNNotificationResponse *\)response withCompletionHandler:\(void \(^\)\(\)\)completionHandler {"
REGISTERCLIENT="- \(void\)GeTuiSdkDidRegisterClient:\(NSString *\)clientId {"
GTSDKRECEIVEPAYLOADDATA="- \(void\)GeTuiSdkDidReceivePayloadData:\(NSData *\)payloadData andTaskId:\(NSString *\)taskId andMsgId:\(NSString *\)msgId andOffLine:\(BOOL\)offLine fromGtAppId:\(NSString *\)appId {"
STRINGBYPLACE="stringByReplacingOccurrencesOfString:@\" \" withString:@\"\"];"
ergodic() {
  for file in ` ls  `
    do
      #echo $file
      #echo “filename: ${file%.*}”
      #echo “extension: ${file##*.}”
      if [ ${file##*.} = $PACKAGENAME ]; then
        cd `dirname $0`/${file%.*}
        count=`ls |grep *${ENTITLEMENTS} |wc -l`
        for file in ` ls  `
          do
            #echo $file
            if [ ${file} = $APPDELEGATE_H ]; then
              sed -i '' "/#import <UIKit\/UIKit.h>/a\\
		    $GTSDK \\
        $APPID \\
        $APPKEY \\
        $APPSECRET \\
		" $APPDELEGATE_H

              sed -i '' "s/UIApplicationDelegate/&,GeTuiSdkDelegate/" $APPDELEGATE_H

              echo ${APPDELEGATE_H}配置成功

            fi

            if [ ${file} = $APPDELEGATE_M ]; then
                sed -i '' "/#import \"AppDelegate.h\"/a\\
        $IF \\
        $USERNOTIFICATION \\
        $ENDIF \\
        " $APPDELEGATE_M

                echo ${APPDELEGATE_M}头文件配置成功

                #需要判断didFinishLaunchingWithOptions这个方法是否存在,如果DidFinishLaunching大于0则存在，否则不存在
                DidFinishLaunching=`sed -n '/didFinishLaunchingWithOptions:(NSDictionary /=' $APPDELEGATE_M`
                if [[ -n $DidFinishLaunching ]]; then
                  cat -n $APPDELEGATE_M  |tail -n +$DidFinishLaunching > termple.txt
                  DidFinish=`cat termple.txt |grep { |awk '{print $1}' |head -1`
                  rm -f termple.txt
                  sed -i '' "$DidFinish a\\
                  $GTSTARTANNOTATION \\
                  $GTSTART \\
                  $GTREGISTERAPNSANNOTATION \\
                  $GTREGISTERAPNS \\
                  " $APPDELEGATE_M
                else
                  EndCountDidFinish=`cat -n $APPDELEGATE_M|grep '@end' |awk '{print $1}' |tail -1`
                  sed -i '' "$EndCountDidFinish i\\
                  $DIDFINISHLAUNCHING \\
                  $GTSTARTANNOTATION \\
                  $GTSTART \\
                  $GTREGISTERAPNSANNOTATION \\
                  $GTREGISTERAPNS \\
                  return YES; \\
                  } \\
                  " $APPDELEGATE_M
                fi
                echo didFinishLaunchingWithOptions方法配置完成

                #需要判断didRegisterForRemoteNotificationWithDeviceToken这个方法是否存在，大于0则存在，否则不存在
                DidRegistFRNWDeviceToken=`sed -n '/didRegisterForRemoteNotificationsWithDeviceToken/=' $APPDELEGATE_M`
                if [[ -n $DidRegistFRNWDeviceToken ]]; then
                  cat -n $APPDELEGATE_M |tail -n +$DidRegistFRNWDeviceToken > termple.txt
                  DidRegistFRNWDT=`cat termple.txt |grep { |awk '{print $1}' |head -1`
                  rm -f termple.txt
                  sed -i '' "$DidRegistFRNWDT a\\
                  NSString *token = [[deviceToken description] ${GETTOKENSTRING} \\
                  token = [token ${STRINGBYPLACE} \\
                  NSLog\(@\"DeviceToken:%@\",token\); \\
                  \/\/ [ GTSdk ]：向个推服务器注册deviceToken \\
                  [GeTuiSdk registerDeviceToken:token]; \\
                  " $APPDELEGATE_M
                else
                  EndCountPFWCHandler=`cat -n $APPDELEGATE_M|grep '@end' |awk '{print $1}' |tail -1`
                  sed -i '' "$EndCountPFWCHandler i\\
                  #pragma mark - 远程通知\(推送\)回调 \\
                  \/** 远程通知注册成功委托*\/ \\
                  $DIDREGISTFORRNWITHDEVICETOKEN \\
                  NSString *token = [[deviceToken description] ${GETTOKENSTRING} \\
                  token = [token ${STRINGBYPLACE} \\
                  NSLog\(@\"DeviceToken:%@\",token\); \\
                  \/\/ [ GTSdk ]：向个推服务器注册deviceToken \\
                  [GeTuiSdk registerDeviceToken:token]; \\
                  } \\
                  " $APPDELEGATE_M
                fi
                echo didRegisterForRemoteNotificationsWithDeviceToken方法配置完成

                #需要判断didReceiveRemoteNotification这个方法是否存在，大于0则存在，否则不存在(ios 10以下版本收到推送)
                DidReceiveRN=`sed -n '/didReceiveRemoteNotification/=' $APPDELEGATE_M`
                if [[ -n $DidReceiveRN ]]; then
                  cat -n $APPDELEGATE_M |tail -n +$DidReceiveRN > termple.txt
                  DidReceiveRemoteNotification=`cat termple.txt |grep { |awk '{print $1}' |head -1`
                  rm -f termple.txt
                  sed -i '' "$DidReceiveRemoteNotification a\\
                  \/\/ [ GTSdk ]：将收到的APNs信息传给个推统计 \\
                  [GeTuiSdk handleRemoteNotification:userInfo]; \\
                  NSString* payload = [userInfo objectForKey:@\"payload\"]; \\
                  completionHandler\(UIBackgroundFetchResultNewData\); \\
                  " $APPDELEGATE_M
                else
                  EndCountReciveRN=`cat -n $APPDELEGATE_M|grep '@end' |awk '{print $1}' |tail -1`
                  sed -i '' "$EndCountReciveRN i\\
                  #pragma mark - APP运行中接收到通知\(推送\)处理 － iOS 10以下版本收到推送 \\
                  \/** APP已经接受到\“远程\”通知\(推送\) - \(App运行在后台\) *\/ \\
                  $DIDRECEIVEREMOTENOTIFICATION \\
                  \/\/ [ GTSdk ]：将收到的APNs信息传给个推统计 \\
                  [GeTuiSdk handleRemoteNotification:userInfo]; \\
                  NSString* payload = [userInfo objectForKey:@\"payload\"]; \\
                  completionHandler\(UIBackgroundFetchResultNewData\); \\
                  } \\
                  " $APPDELEGATE_M
                fi
                echo didReceiveRemoteNotification方法配置完成


                #需要判断willPresentNotification这个方法是否存在，大于0则存在，否则不存在(iOS 10：APP在前台获取到通知)
                WillPresentNoti=`sed -n '/willPresentNotification/=' $APPDELEGATE_M`
                if [[ -n $WillPresentNoti ]]; then
                  cat -n $APPDELEGATE_M |tail -n +$WillPresentNoti > termple.txt
                  WillPresentNotification=`cat termple.txt |grep { |awk '{print $1}' |head -1`
                  rm -f termple.txt
                  sed -i '' "$WillPresentNotification a\\
                  \/\/ 根据APP需要，判断是否要提示用户Badge、Sound、Alert \\
                  completionHandler\(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert\); \\
                  " $APPDELEGATE_M
                else
                  EndCountWillPreNoti=`cat -n $APPDELEGATE_M|grep '@end' |awk '{print $1}' |tail -1`
                  sed -i '' "$EndCountWillPreNoti i\\
                  #pragma mark － iOS 10中收到推送消息 \\
                  \/\/ iOS 10: App在前台获取到通知 \\
                  $WILLPRESENTNOTIFICATION \\
                  \/\/ 根据APP需要，判断是否要提示用户Badge、Sound、Alert \\
                  completionHandler\(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert\); \\
                  } \\
                  " $APPDELEGATE_M
                fi
                echo willPresentNotification方法配置完成

                #需要判断didReceiveNotificationResponse这个方法是否存在，大于0则存在，否则不存在(iOS 10：点击通知进入app时触发)
                DidReceiveNotificationResponse=`sed -n '/didReceiveNotificationResponse/=' $APPDELEGATE_M`
                if [[ -n $DidReceiveNotificationResponse ]]; then
                  cat -n $APPDELEGATE_M |tail -n +$DidReceiveNotificationResponse > termple.txt
                  DidReceiveNotiResponce=`cat termple.txt |grep { |awk '{print $1}' |head -1`
                  rm -f termple.txt
                  sed -i '' "$DidReceiveNotiResponce a\\
                  \/\/ [ GTSdk ]：将收到的APNs信息传给个推统计 \\
                  [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo]; \\
                  completionHandler\(\); \\
                  " $APPDELEGATE_M
                else
                  EndCountDidNotiResponce=`cat -n $APPDELEGATE_M|grep '@end' |awk '{print $1}' |tail -1`
                  sed -i '' "$EndCountDidNotiResponce i\\
                  \/\/ iOS 10: 点击通知进入App时触发 \\
                  $DIDRECEIVENOTIFICATIONRESPONCE \\
                  \/\/ [ GTSdk ]：将收到的APNs信息传给个推统计 \\
                  [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo]; \\
                  completionHandler\(\); \\
                  } \\
                  " $APPDELEGATE_M
                fi
                echo didReceiveNotificationResponse方法配置完成


                #需要判断registerRemoteNotification方法是否存在
                RegisterRemoteNotiFunction=`sed -n '/(void)registerRemoteNotification/=' $APPDELEGATE_M`
                if [[ -n $RegisterRemoteNotiFunction ]]; then
                  cat -n $APPDELEGATE_M |tail -n +$RegisterRemoteNotiFunction > termple.txt
                  RegisterRemoteNotiF=`cat termple.txt |grep { |awk '{print $1}' |head -1`
                  rm -f termple.txt
                  sed -i '' "$RegisterRemoteNotiF a\\
                  "\/*" \\
                  $NOTIFICATIONWARN \\
                  "*\/" \\
                  ${SYSTEMVERSION} 10.0\) { \\
                  $IF \\
                  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter]; \\
                  center.delegate=self; \\
                  $CENTERREQUEST \\
                  if \(!error\) { \\
                  NSLog\(@\"request authorization succeeded!\"\); \\
                  } \\
                  }]; \\
                  $REGISTFORRN \\
                  #else \/\/Xcode 7编译会调用 \\
                  UIUserNotificationType types = ${UIUSERNOTIFICATIONTYPE} \\
                  $UIUSERNOTIFICATIONSET \\
                  $REGISTUNSETTING \\
                  $REGISTFORRN \\
                  #endif \\
                } else ${SYSTEMVERSION} 8.0\) { \\
                  UIUserNotificationType types = ${UIUSERNOTIFICATIONTYPE} \\
                  $UIUSERNOTIFICATIONSET \\
                  $REGISTUNSETTING \\
                  $REGISTFORRN \\
                  } else { \\
                  UIRemoteNotificationType apn_type = \(UIRemoteNotificationType\)${UIUSERNOTIFICATIONTYPE} \\
                  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type]; \\
                  } \\
                  " $APPDELEGATE_M
                else
                  EndCountRN=`cat -n $APPDELEGATE_M|grep '@end' |awk '{print $1}' |tail -1`
                  sed -i '' "$EndCountRN i\\
                  #pragma mark - 用户通知(推送) _自定义方法 \\
                  $REGISTREMOTEN \\
                  "\/*" \\
                  $NOTIFICATIONWARN \\
                  "*\/" \\
                  ${SYSTEMVERSION} 10.0\) { \\
                  $IF \\
                  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter]; \\
                  center.delegate=self; \\
                  $CENTERREQUEST \\
                  if \(!error\) { \\
                  NSLog\(@\"request authorization succeeded!\"\); \\
                  } \\
                  }]; \\
                  $REGISTFORRN \\
                  #else \/\/Xcode 7编译会调用 \\
                  UIUserNotificationType types = ${UIUSERNOTIFICATIONTYPE} \\
                  $UIUSERNOTIFICATIONSET \\
                  $REGISTUNSETTING \\
                  $REGISTFORRN \\
                  #endif \\
                } else ${SYSTEMVERSION} 8.0\) { \\
                  UIUserNotificationType types = ${UIUSERNOTIFICATIONTYPE} \\
                  $UIUSERNOTIFICATIONSET \\
                  $REGISTUNSETTING \\
                  $REGISTFORRN \\
                  } else { \\
                  UIRemoteNotificationType apn_type = \(UIRemoteNotificationType\)${UIUSERNOTIFICATIONTYPE} \\
                  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type]; \\
                  } \\
                  } \\
                  " $APPDELEGATE_M
                fi
                echo registerRemoteNotification方法配置完成

                #返回CID
                RegisterClientFunction=`sed -n '/GeTuiSdkDidRegisterClient/=' $APPDELEGATE_M`
                if [[ -n $RegisterClientFunction ]]; then
                  cat -n $APPDELEGATE_M |tail -n +$RegisterClientFunction > termple.txt
                  RegisterClientF=`cat termple.txt |grep { |awk '{print $1}' |head -1`
                  rm -f termple.txt
                  sed -i '' "$RegisterClientF a\\
                  \/\/ [ GTSdk ]：个推SDK已注册，返回clientId \\
                  NSLog\(@\"[GTSdk RegisterClient]:%@\", clientId\); \\
                  " $APPDELEGATE_M
                else
                  EndCountCID=`cat -n $APPDELEGATE_M|grep '@end' |awk '{print $1}' |tail -1`
                  sed -i '' "$EndCountCID i\\
                  #pragma mark - GeTuiSdkDelegate \\
                  \/** SDK启动成功返回CID *\/ \\
                  $REGISTERCLIENT \\
                  \/\/ [ GTSdk ]：个推SDK已注册，返回clientId \\
                  NSLog\(@\"[GTSdk RegisterClient]:%@\", clientId\); \\
                  } \\
                  " $APPDELEGATE_M
                fi
                echo GeTuiSdkDidRegisterClient方法配置完成


                #SDK收到透传信息回调
                ReceivePayloadDataFunction=`sed -n '/GeTuiSdkDidReceivePayloadData/=' $APPDELEGATE_M`
                if [[ -n $ReceivePayloadDataFunction ]]; then
                  cat -n $APPDELEGATE_M |tail -n +$ReceivePayloadDataFunction > termple.txt
                  ReceivePayloadDataF=`cat termple.txt |grep { |awk '{print $1}' |head -1`
                  rm -f termple.txt
                  sed -i '' "$ReceivePayloadDataF a\\
                  \/\/ [ GTSdk ]：汇报个推自定义事件\(反馈透传消息\) \\
                  [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId]; \\
                  if (payloadData) { \\
                  payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding]; \\
                  NSLog\(@\"[GTSdk ReceivePayload]:%@, taskId: %@, msgId :%@\", payloadMsg, taskId, msgId\); \\
                  } \\
                  " $APPDELEGATE_M
                else
                  EndCountReceivePAYLOADData=`cat -n $APPDELEGATE_M|grep '@end' |awk '{print $1}' |tail -1`
                  sed -i '' "$EndCountReceivePAYLOADData i\\
                  \/** SDK收到透传消息回调 *\/ \\
                  $GTSDKRECEIVEPAYLOADDATA \\
                  \/\/ [ GTSdk ]：汇报个推自定义事件\(反馈透传消息\) \\
                  [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId]; \\
                  NSString *payloadMsg = nil; \\
                  if (payloadData) { \\
                  payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding]; \\
                  NSLog\(@\"[GTSdk ReceivePayload]:%@, taskId: %@, msgId :%@\", payloadMsg, taskId, msgId\); \\
                  } \\
                  } \\
                  " $APPDELEGATE_M
                fi
                echo GeTuiSdkDidReceivePayloadData方法配置完成

            fi

            if [ ${file} = $PLIST ]; then
              UIBackgroundModesLine=`sed -n '/UIBackgroundModes/=' $PLIST`
              if [[ -z $UIBackgroundModesLine ]]; then
                DICTLine=`sed -n '/<\/dict>/=' $PLIST`
                sed -i '' "$DICTLine i\\
                <key>UIBackgroundModes<\/key> \\
                <array> \\
                <string>remote-notification<\/string> \\
                </array> \\
                " $PLIST
              fi
              echo plist文件配置完成
            fi

            if [ ${file##*.} = $ENTITLEMENTS ]; then
              ENVIRONMENTLine=`sed -n '/aps-environment/=' $file`
              if [[ -z $ENVIRONMENTLine ]]; then
                EDICTLine=`sed -n '/<\/dict>/=' $file`
                sed -i '' "$EDICTLine i\\
                <key>aps-environment<\/key> \\
                <string>development<\/string> \\
                " $file
              fi
            fi
          done
          if [[ $count=0 ]]; then
            echo 缺少.entitlements文件
          fi
      fi
    done
    echo "-----Finish-----"
}
ergodic
