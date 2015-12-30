//
//  AppDelegate.h
//  Demo
//
//  Created by CoLcY on 11-12-29.
//  Copyright (c) 2011年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import "GeTuiSdk.h"
#import <UIKit/UIKit.h>

// 现网 - 杭州
#define kGtAppId @"iMahVVxurw6BNr7XSn9EF2"
#define kGtAppKey @"yIPfqwq6OMAPp6dkqgLpG5"
#define kGtAppSecret @"G0aBqAD6t79JfzTB6Z5lo5"

// 现网 - 北京
//#define kGtAppId           @"8u6obu5sdn9PZRUvySvWn"
//#define kGtAppKey          @"TXSCUwGVzw5G3WReJzmNY7"
//#define kGtAppSecret       @"wjVnU5m2hO61Rw0kIF4Gv4"

//#define kGtAppId @"DzZ5576WbA6IxM0ytqcZR"
//#define kGtAppKey @"vtDm307Hbk6HN3MG6tN1a6"
//#define kGtAppSecret @"4xEQwsqTBC9Eu6KmzOA483"

// 测试网-zhaowei
//#define kGtAppId @"ELVBzclM7C9YlKVvpp7a4"
//#define kGtAppKey @"1O5qU7l0cm8SmCi4vftw7"
//#define kGtAppSecret @"wHzJ0IBbOX5WG0uHxemSA5"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate> {
  @private
    UINavigationController *_naviController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (assign, nonatomic) int lastPayloadIndex;

/** 
 获取个推的AppId、AppKey、AppSecret
 Demo演示时代码，正式集成时可以简化该模块
 */
+ (NSString *)getGtAppId;
+ (NSString *)getGtAppKey;
+ (NSString *)getGtAppSecret;

- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret;

@end
