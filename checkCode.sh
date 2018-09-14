#!/bin/sh
PACKAGENAME="xcworkspace"
APPDELEGATE_H="AppDelegate.h"
APPDELEGATE_M="AppDelegate.m"
PLIST="Info.plist"
ENTITLEMENTS="entitlements"
ergodic() {
  for file in ` ls  `
    do
      if [ ${file##*.} = $PACKAGENAME ]; then
        cd `dirname $0`/${file%.*}
        count=`ls |grep *${ENTITLEMENTS} |wc -l`
        for file in ` ls  `
          do
            #echo $file
            if [ ${file} = $APPDELEGATE_H ]; then
                GTSDKLine=`sed -n '/#import <GTSDK\/GeTuiSdk.h>/=' $APPDELEGATE_H`
                if [[ -z $GTSDKLine ]]; then
                  echo 需要在${APPDELEGATE_H}添加个推SDK的头文件\<GTSDK/GeTuiSdk.h\>
                fi

                GeTuiSdkDelegateLine=`sed -n '/GeTuiSdkDelegate/=' $APPDELEGATE_H`
                if [[ -z $GeTuiSdkDelegateLine ]]; then
                  echo 需要在${APPDELEGATE_H}遵守GeTuiSdk的代理
                fi
            fi

            if [ ${file} = $APPDELEGATE_M ]; then

                UserNotificationsLine=`sed -n '/#import <UserNotifications\/UserNotifications.h>/=' $APPDELEGATE_M`
                if [[ -z $UserNotificationsLine ]]; then
                  echo 需要在${APPDELEGATE_M}添加UserNotifications的头文件\<UserNotifications/UserNotifications.h\>
                fi

                StartSdkWithAppIdLine=`sed -n '/startSdkWithAppId:/=' $APPDELEGATE_M`
                if [[ -z $StartSdkWithAppIdLine ]]; then
                  echo 需要在${APPDELEGATE_M}的didFinishLaunchingWithOptions方法里添加启动个推SDK
                fi

                TransferRegistRemoteNotiLine=`sed -n '/[self registerRemoteNotification];/=' $APPDELEGATE_M`
                if [[ -z $TransferRegistRemoteNotiLine ]]; then
                  echo 需要在${APPDELEGATE_M}的didFinishLaunchingWithOptions方法里添加注册APNs
                fi

                RegisterRemoteNotiLine=`sed -n '/(void)registerRemoteNotification/=' $APPDELEGATE_M`
                if [[ -z $RegisterRemoteNotiLine ]]; then
                  echo 需要在${APPDELEGATE_M}添加registerRemoteNotification方法
                fi

                DidRegistFRNWDeviceTokenLine=`sed -n '/didRegisterForRemoteNotificationsWithDeviceToken/=' $APPDELEGATE_M`
                if [[ -z $DidRegistFRNWDeviceTokenLine ]]; then
                  echo 需要在${APPDELEGATE_M}添加didRegisterForRemoteNotificationsWithDeviceToken方法
                else
                  RegisterDeviceTokenToGTLine=`sed -n '/[GeTuiSdk registerDeviceToken:]/=' $APPDELEGATE_M`
                  if [[ -z $RegisterDeviceTokenToGTLine ]]; then
                    echo 需要在${APPDELEGATE_M}的didRegisterForRemoteNotificationsWithDeviceToken方法里添加向个推服务器注册deviceToken
                  fi
                fi

                DidReceiveRemoteNotificationLine=`sed -n '/didReceiveRemoteNotification/=' $APPDELEGATE_M`
                if [[ -z $DidReceiveRemoteNotificationLine ]]; then
                  echo 需要在${APPDELEGATE_M}添加didReceiveRemoteNotification方法
                else
                  HandleRemoteNotificationLine=`sed -n '/[GeTuiSdk handleRemoteNotification:]/=' $APPDELEGATE_M`
                  if [[ -z $HandleRemoteNotificationLine ]]; then
                    echo 需要在${APPDELEGATE_M}的didReceiveRemoteNotification方法里添加将收到的APNs信息传给个推统计
                  fi
                fi

                DidReceiveNotificationResponseLine=`sed -n '/didReceiveNotificationResponse/=' $APPDELEGATE_M`
                if [[ -z $DidReceiveNotificationResponseLine ]]; then
                  echo 需要在${APPDELEGATE_M}添加didReceiveNotificationResponse方法
                else
                  HandleRemoteNotification10Line=`sed -n '/[GeTuiSdk handleRemoteNotification:]/=' $APPDELEGATE_M`
                  if [[ -z $HandleRemoteNotification10Line ]]; then
                    echo 需要在${APPDELEGATE_M}的didReceiveRemoteNotification方法里添加将收到的APNs信息传给个推统计
                  fi
                fi

                RegisterClientLine=`sed -n '/GeTuiSdkDidRegisterClient/=' $APPDELEGATE_M`
                if [[ -z $RegisterClientLine ]]; then
                  echo 需要在${APPDELEGATE_M}添加GeTuiSdkDidRegisterClient方法
                else
                  ClientIdLine=`sed -n '/[GeTuiSdk RegisterClient]/=' $APPDELEGATE_M`
                  if [[ -z $ClientIdLine ]]; then
                    echo 需要在${APPDELEGATE_M}的GeTuiSdkDidRegisterClient方法里添加个推SDK注册后返回的clientId
                  fi
                fi

                ReceivePayLoadDataLine=`sed -n '/GeTuiSdkDidReceivePayloadData/=' $APPDELEGATE_M`
                if [[ -z $ReceivePayLoadDataLine ]]; then
                  echo 需要在${APPDELEGATE_M}添加GeTuiSdkDidReceivePayloadData方法
                else
                  PayLoadDataLine=`sed -n '/[GeTuiSdk sendFeedbackMessage:]/=' $APPDELEGATE_M`
                  if [[ -z $PayLoadDataLine ]]; then
                    echo 需要在${APPDELEGATE_M}的GeTuiSdkDidReceivePayloadData方法里添加汇报个推自定义事件\(反馈透传消息\)
                  fi
                fi

            fi

            if [ ${file} = $PLIST ]; then
              UIBackgroundModesLine=`sed -n '/UIBackgroundModes/=' $PLIST`
              if [[ -z $UIBackgroundModesLine ]]; then
                echo 需要在${PLIST}添加UIBackgroundModes权限
              fi
            fi

            if [ ${file##*.} = $ENTITLEMENTS ]; then
              ENVIRONMENTLine=`sed -n '/aps-environment/=' $file`
              if [[ -z $ENVIRONMENTLine ]]; then
                echo Push Notifications开关没开
              fi
            fi
          done
          if [[ $count=0 ]]; then
            echo 缺少.entitlements文件
          fi
      fi
    done
}
ergodic
