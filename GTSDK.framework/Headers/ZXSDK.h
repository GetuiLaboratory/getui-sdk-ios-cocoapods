//
//  ZXSDK.h
//  ZXSDK
//
//  Created by zx on 2021-03-10.
//  ZXSDK-Version: 2.0.0.7785

#import <Foundation/Foundation.h>

//! Project version number for ZXSDK.
FOUNDATION_EXPORT double ZXSDKVersionNumber;

//! Project version string for ZXSDK.
FOUNDATION_EXPORT const unsigned char ZXSDKVersionString[];
@class ZXSDKResultModel;
typedef void (^ZXSDKCallback)(ZXSDKResultModel *_Nullable model, NSError *_Nullable error);
typedef void (^ZXSDKVerifyCallback)(BOOL success, NSError *_Nullable error);

@interface ZXSDKResultModel : NSObject
@property (nonatomic, copy, nonnull) NSString *zxid;
@property (nonatomic, copy, nonnull) NSString *expireTime;

@property (nonatomic, copy, nullable) NSString *aaid;
@property (nonatomic, copy, nullable) NSString *vaid;
@end

@protocol ZXSDKProtocol <NSObject>

/// 获取UAID
- (void)getUAID:(nonnull void (^)(NSString *_Nullable uaid, NSError *_Nullable error))callback;

/// 获取卓信id
- (void)getZXID:(ZXSDKCallback _Nonnull)callback;

/// 读取卓信ID开关
- (BOOL)enable;

/// 设置卓信ID开关
/// @param enable YES:打开（默认）   NO:关闭
- (void)setEnable:(BOOL)enable;

/// 设置是否提示权限弹窗
/// @param allow  YES:提示（默认）   NO:不提示
- (void)allowPermissionDialog:(BOOL)allow;

/// 读取卓信是否允许弹窗
- (BOOL)isAllowPermissionDialog;

/// sdk版本号
- (NSString * _Nonnull)version;

@end

@interface ZXSDK : NSObject

+ (void)startSdkWithAppId:(NSString * _Nullable)appId callback:(ZXSDKCallback _Nonnull)callback;

/// 获取卓信id
+ (void)getZXID:(ZXSDKCallback _Nonnull)callback;

/// 获取UAID
+ (void)getUAID:(nonnull void (^)(NSString *_Nullable uaid, NSError *_Nullable error))callback;

/// 读取卓信ID开关
+ (BOOL)enable;

/// 设置卓信ID开关
/// @param enable YES:打开（默认）   NO:关闭
+ (void)setEnable:(BOOL)enable;

/// 设置是否提示权限弹窗
/// @param allow  YES:提示（默认）   NO:不提示
+ (void)allowPermissionDialog:(BOOL)allow;

/// 读取卓信是否允许弹窗
+ (BOOL)isAllowPermissionDialog;

/// sdk版本号
+ (NSString * _Nonnull)version;

/// 服务商使用, 普通用户不建议使用
+ (id<ZXSDKProtocol>_Nullable)initWithAppId:(NSString *_Nonnull)appId;
@end
