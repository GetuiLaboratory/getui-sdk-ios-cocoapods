//
//  ViewController.h
//  Demo
//
//  Created by CoLcY on 11-12-29.
//  Copyright (c) 2011年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface DemoViewController : UIViewController<UIActionSheetDelegate> {
@public
    IBOutlet UITextView *mResponseView;
    
    IBOutlet UITextField *mAppIDView;
    IBOutlet UITextField *mAppKeyView;
    IBOutlet UITextField *mAppSecretView;


    IBOutlet UILabel *mClientIDView;
    IBOutlet UILabel *mStatusView;
    IBOutlet UILabel *mMsgCount;
    IBOutlet UILabel *pushStatusLabel;
    IBOutlet UIButton *mStartupView;
    
    NSFileHandle *_file;
    
    IBOutlet UIButton *offPushButton;
    BOOL isModeOff_;
}

- (void)logMsg:(NSString *)aMsg;
- (void)updateStatusView:(AppDelegate *)delegate;
- (void)updateMsgCount:(int) count;
- (void)updateModeOffButton:(BOOL)isModeOff;

- (IBAction)onStartupOrStop:(id)sender;
- (IBAction)onClearLog:(id)sender; 
- (IBAction)onTestMore:(id)sender;
- (IBAction)onSetModeButton:(id)sender;

@end
