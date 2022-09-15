//
//  ZXSDK.h
//  ZXSDK
//
//  Created by zx on 2021-03-10.
//  ZXSDK-Version: 3.0.0.10551

#import <Foundation/Foundation.h>

//! Project version number for ZXSDK.
FOUNDATION_EXPORT double ZXSDKVersionNumber;

//! Project version string for ZXSDK.
FOUNDATION_EXPORT const unsigned char ZXSDKVersionString[];

#define ZXSDKStoreDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))

#define ZXSDKStoreMod(name, value) \
class ZXSDK; char * k##name##_mod ZXSDKStoreDATA(ZXSDKMods) = ""#value"";

@class ZXSDKResultModel;
typedef void (^ZXSDKCallback)(ZXSDKResultModel *_Nullable model, NSError *_Nullable error);
typedef void (^ZXSDKUAIDCallback)(NSString *_Nullable uaid, NSError *_Nullable error);
typedef void (^ZXSDKAidInfoCallback)(NSDictionary *_Nullable res, NSError *_Nullable error);
typedef void (^ZXSDKVerifyCallback)(BOOL success, NSError *_Nullable error);

@interface ZXSDKResultModel : NSObject
@property (nonatomic, copy, nonnull) NSString *zxid;
@property (nonatomic, copy, nonnull) NSString *expireTime;
@property (nonatomic, copy, nullable) NSArray *tags;

@property (nonatomic, copy, nullable) NSString *aaid;
@property (nonatomic, copy, nullable) NSString *vaid;
@end

@protocol ZXSDKProtocol <NSObject>

/// 获取UAID
/// @param accessKeyId 通过管理后台申请分配的密钥标识
/// @param signature 信息签名字符串，参考签名方式。
/// @param signatureMethod 信息签名方法，目前固定为 HMAC-SHA256 。
/// @param signatureNonce 64 字节以内的随机串，用于防止重放攻击，每次请求 必须提供不同的值。
/// @param timestamp UTC时间戳，从UTC1970年1月1日0时0分0秒起至现在 的总秒数。如 1632634877
- (void)getUAIDWithAccessKeyId:(NSString *_Nonnull)accessKeyId
                     signature:(NSString *_Nonnull)signature
               signatureMethod:(NSString *_Nonnull)signatureMethod
                signatureNonce:(NSString *_Nonnull)signatureNonce
                     timestamp:(NSString *_Nonnull)timestamp
                      callback:(ZXSDKUAIDCallback _Nonnull)callback;

/// 获取卓信id
- (void)getZXID:(ZXSDKCallback _Nonnull)callback;

/// 获取设备对应Tag
- (void)getTag:(ZXSDKAidInfoCallback _Nonnull)callback;

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

+ (void)startZXSDK;

/// 获取卓信id
+ (void)getZXID:(ZXSDKCallback _Nonnull)callback;

/// 获取UAID
/// @param accessKeyId 通过管理后台申请分配的密钥标识
/// @param signature 信息签名字符串，参考签名方式。
/// @param signatureMethod 信息签名方法，目前固定为 HMAC-SHA256 。
/// @param signatureNonce 64 字节以内的随机串，用于防止重放攻击，每次请求 必须提供不同的值。
/// @param timestamp UTC时间戳，从UTC1970年1月1日0时0分0秒起至现在 的总秒数。如 1632634877
+ (void)getUAIDWithAccessKeyId:(NSString *_Nonnull)accessKeyId
                     signature:(NSString *_Nonnull)signature
               signatureMethod:(NSString *_Nonnull)signatureMethod
                signatureNonce:(NSString *_Nonnull)signatureNonce
                     timestamp:(NSString *_Nonnull)timestamp
                      callback:(ZXSDKUAIDCallback _Nonnull)callback;

/// 获取设备对应Tag
+ (void)getTag:(ZXSDKAidInfoCallback _Nonnull)callback;

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

/// 服务商使用, 普通开发不建议使用
+ (id<ZXSDKProtocol>_Nullable)initWithAppId:(NSString *_Nonnull)appId;
@end
