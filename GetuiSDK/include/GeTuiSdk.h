//
//  GeTuiSdk.h
//  GeTuiSdk
//
//  Created by gexin on 15-5-5.
//  Copyright (c) 2015年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SdkStatusStarting, // 正在启动
    SdkStatusStarted,  // 启动
    SdkStatusStoped    // 停止
} SdkStatus;

@protocol GeTuiSdkDelegate;

@interface GeTuiSdk : NSObject

#pragma mark 基本功能

+ (void)startSdkWithAppId:(NSString *)appid appKey:(NSString *)appKey appSecret:(NSString *)appSecret
                 delegate:(id<GeTuiSdkDelegate>)delegate
                    error:(NSError **)error; // 启动SDK

+ (void)enterBackground; // SDK进入后台

+ (void)registerDeviceToken:(NSString *)deviceToken; // 注册DeviceToken

+ (NSData *)retrivePayloadById:(NSString *)payloadId; //根据payloadId取回Payload

#pragma mark 设置关闭推送模式
+ (void)setPushModeForOff:(BOOL)isValue;

#pragma mark 绑定别名功能:后台可以根据别名进行推送
+ (void)bindAlias:(NSString *)alias;
+ (void)unbindAlias:(NSString *)alias;

#pragma mark 设置标签:后台可以根据标签进行推送
+ (BOOL)setTags:(NSArray *)tags;

#pragma mark 发送消息
+ (NSString *)sendMessage:(NSData *)body error:(NSError **)error;

#pragma mark 后台功能
+ (void)runBackgroundEnable:(BOOL)isEnable;
+ (void)resume;

#pragma mark LBS功能
+ (void)lbsLocationEnable:(BOOL)isEnable andUserVerify:(BOOL)isVerify;

#pragma mark 获取SDK 版本号
+ (NSString *)version;

#pragma mark 获取SDK cid
+ (NSString *)clientId;

#pragma mark 设置处理显示的AlertView是否随屏幕旋转
+ (void)setAllowedRotateUiOrientations:(NSArray *)orientations;

@end

#pragma mark SDK Delegate
@protocol GeTuiSdkDelegate <NSObject>

@optional
//SDK启动成功返回cid
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId;
//SDK收到透传消息回调
- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId fromApplication:(NSString *)appId;
//SDK收到sendMessage消息回调
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result;
//SDK遇到错误回调
- (void)GeTuiSdkDidOccurError:(NSError *)error;
//SDK运行状态通知
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus;
//SDK设置关闭推送功能回调
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error;

@end
