//
//  AppDelegate.h
//  Demo
//
//  Created by CoLcY on 11-12-29.
//  Copyright (c) 2011年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import "GeTuiSdk.h"
#import <UIKit/UIKit.h>

// 杭州个推官网
#define kGtAppId @"iMahVVxurw6BNr7XSn9EF2"
#define kGtAppKey @"yIPfqwq6OMAPp6dkqgLpG5"
#define kGtAppSecret @"G0aBqAD6t79JfzTB6Z5lo5"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate> {
  @private
    UINavigationController *_naviController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (assign, nonatomic) int lastPayloadIndex;

@end
