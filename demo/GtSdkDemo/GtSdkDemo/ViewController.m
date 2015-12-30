//
//  ViewController.m
//  Demo
//
//  Created by CoLcY on 11-12-29.
//  Copyright (c) 2011年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import "AppDelegate.h"
#import "TestViewController.h"
#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initLogFile];

    mResponseView.editable = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        mResponseView.layoutManager.allowsNonContiguousLayout = NO;
    }
#else
    NSLog(@"ios4");
#endif

    NSString *offPushMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"OffPushMode"];
    if (offPushMode) {
        BOOL flg = [offPushMode intValue] == 1;
        [self updateModeOffButton:flg];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [mAppIDView setText:[AppDelegate getGtAppId]];
    [mAppKeyView setText:[AppDelegate getGtAppKey]];
    [mAppSecretView setText:[AppDelegate getGtAppSecret]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"%@ %@", NSStringFromClass(self.class), @"dealloc");
}

#pragma mark - 页面显示

- (void)updateStatusView:(AppDelegate *)delegate {
    if ([GeTuiSdk status] == SdkStatusStarted) {
        [mStatusView setText:@"已启动"];
        [mStartupView setTitle:@"销毁" forState:UIControlStateNormal];
        [mClientIDView setText:[GeTuiSdk clientId]];
    } else if ([GeTuiSdk status] == SdkStatusStarting) {
        [mStatusView setText:@"正在启动"];
        [mStartupView setTitle:@"正在启动" forState:UIControlStateNormal];
        [mClientIDView setText:@""];
    } else {
        [mStatusView setText:@"已销毁"];
        [mStartupView setTitle:@"启动" forState:UIControlStateNormal];
        [mClientIDView setText:@""];
    }
}

- (void)updateModeOffButton:(BOOL)isModeOff {
    if (isModeOff) {
        [pushStatusLabel setText:@"销毁"];
        [offPushButton setTitle:@"开启推送" forState:UIControlStateNormal];
    } else {
        [pushStatusLabel setText:@"开启"];
        [offPushButton setTitle:@"销毁推送" forState:UIControlStateNormal];
    }
    isModeOff_ = isModeOff;
    [[NSUserDefaults standardUserDefaults] setObject:isModeOff_ ? @"1" : @"0" forKey:@"OffPushMode"];
}

#pragma mark - 页面按钮点击事件

/// 点击销毁推送按钮
- (IBAction)onSetModeButton:(id)sender {
    if ([GeTuiSdk status] == SdkStatusStarted) {
        [GeTuiSdk setPushModeForOff:!isModeOff_];
    } else {
        [self logMsg:@"GeTuiSDK未启动"];
    }
}

/// 点击开始/销毁按钮
- (IBAction)onStartupOrStop:(id)sender {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([GeTuiSdk status] == SdkStatusStoped) {
        [delegate startSdkWith:mAppIDView.text appKey:mAppKeyView.text appSecret:mAppSecretView.text];
    } else if ([GeTuiSdk status] == SdkStatusStarted || [GeTuiSdk status] == SdkStatusStarting) {
        [GeTuiSdk destroy]; // 销毁SDK
    }
}

/// 点击清空日志按钮
- (IBAction)onClearLog:(id)sender {
    [mResponseView setText:nil];
    [mResponseView scrollRangeToVisible:NSMakeRange([mResponseView.text length], 0)];
}

/// 点击更多按钮
- (IBAction)onTestMore:(id)sender {
    UIActionSheet *actionsView = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"更多功能测试", nil];
    [actionsView showInView:self.view];
}

/// 销毁键盘
- (IBAction)didKeyword:(id)sender {
    [self.view endEditing:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {

            UIViewController *funcsView = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:nil];
            [self.navigationController pushViewController:funcsView animated:YES];

            break;
        }
        default:
            break;
    }
}

#pragma mark - 日志

- (void)logMsg:(NSString *)aMsg {
    NSString *response = [NSString stringWithFormat:@"%@\n%@", mResponseView.text, aMsg];
    [mResponseView setText:response];

    [mResponseView scrollRangeToVisible:NSMakeRange([mResponseView.text length], 0)];

    [self log:aMsg]; // 写文件
}

#pragma mark - 本地日志写入事件

- (void)initLogFile {
    @autoreleasepool {
        NSString *logFilePath = [self getFileDataPath];

        if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
            _file = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        } else {
            if ([[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil]) {
                _file = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
            }
        }
    }
}

- (void)log:(NSString *)aLogMsg {
    NSLog(@"%@", aLogMsg);

    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(dispatchQueue, ^(void) {
        if (_file) {
            [_file seekToEndOfFile];
            [_file writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];

            if ([aLogMsg isEqualToString:@"\n"]) {
                [_file writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
            } else {
                NSData *data = [aLogMsg dataUsingEncoding:NSUTF8StringEncoding];
                [_file writeData:data];
            }
        }
    });
}

- (NSString *)getFileDataPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString *path = [[NSMutableString alloc] initWithString:documentsDirectory];
    [path appendString:[NSString stringWithFormat:@"/payload_msg_log_%@.txt", [self formateTime:[NSDate date]]]];
    return path;
}


- (NSString *)formateTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

@end
