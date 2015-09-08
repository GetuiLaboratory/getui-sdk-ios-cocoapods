//
//  ViewController.m
//  Demo
//
//  Created by CoLcY on 11-12-29.
//  Copyright (c) 2011年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import "DemoViewController.h"
#import "AppDelegate.h"

@implementation DemoViewController

- (void)logMsg:(NSString *)aMsg
{
    CGPoint p = [mResponseView contentOffset];
    
    NSString *response = [NSString stringWithFormat:@"%@\n%@", mResponseView.text, aMsg];
    [mResponseView setText:response];
    
    [mResponseView setContentOffset:p animated:NO];
    [mResponseView scrollRangeToVisible:NSMakeRange([mResponseView.text length], 0)];
    
    [self log:aMsg];
}

- (void)updateStatusView:(AppDelegate *)delegate
{
    
    if (delegate.sdkStatus == SdkStatusStoped) {
        [mStartupView setTitle:@"启动" forState:UIControlStateNormal];
    } else {
        [mStartupView setTitle:@"停止" forState:UIControlStateNormal];
    }
    
    [mStatusView setText:delegate.sdkStatus == SdkStatusStarted ? @"已启动" : delegate.sdkStatus == SdkStatusStarting ? @"正在启动" : @"已停止"];
    [mClientIDView setText:delegate.clientId];
}

- (void)updateModeOffButton:(BOOL)isModeOff {
    if (isModeOff) {
        [pushStatusLabel setText:@"关闭"];
        [offPushButton setTitle:@"开启推送" forState:UIControlStateNormal];
    }else {
        [pushStatusLabel setText:@"开启"];
        [offPushButton setTitle:@"关闭推送" forState:UIControlStateNormal];
    }
    isModeOff_ = isModeOff;
    [[NSUserDefaults standardUserDefaults] setObject:isModeOff_?@"1":@"0" forKey:@"OffPushMode"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self initLogFile];
    [super viewDidLoad];
    
    NSString *offPushMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"OffPushMode"];
    if (offPushMode) {
        BOOL flg = [offPushMode intValue] == 1;
        [self updateModeOffButton:flg];
    }
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [mAppIDView setText:kAppId];
    [mAppKeyView setText:kAppKey];
    [mAppSecretView setText:kAppSecret];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)onStartupOrStop:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (delegate.sdkStatus == SdkStatusStoped) {  
        [delegate startSdkWith:mAppIDView.text appKey:mAppKeyView.text appSecret:mAppSecretView.text];
    } else if(delegate.sdkStatus == SdkStatusStarted) {
        [delegate stopSdk];
    }
}

- (IBAction)onClearLog:(id)sender
{
    CGPoint p = CGPointMake(0, 0);
    
    [mResponseView setText:nil];
    [mResponseView setContentOffset:p animated:NO];
    [mResponseView scrollRangeToVisible:NSMakeRange([mResponseView.text length], 0)];
}

- (IBAction)onTestMore:(id)sender
{
    UIActionSheet *actionsView = [[UIActionSheet alloc] initWithTitle:@"更多测试" delegate:self 
                                                    cancelButtonTitle:@"取消" 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:@"tag/devicetoken/alias", @"get-clientId", nil];
    [actionsView showInView:self.view];
    [actionsView release];
}

- (IBAction)onSetModeButton:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.sdkStatus != SdkStatusStoped) {
        [GeTuiSdk setPushModeForOff:!isModeOff_];
    }else {
        [self logMsg:@"GeTuiSDK未启动"];
    }
}

-(void)updateMsgCount:(int)count {
    NSString* countStr = [NSString stringWithFormat:@"%d", count];
    [mMsgCount setText:countStr];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (buttonIndex) {
        case 0:
            [delegate testSdkFunction];
            break;
//        case 1:
//            [delegate testSendMessage];
//            break;
        case 1:
            [delegate testGetClientId];
            break;
        default:
            break;
    }
}

- (void)dealloc
{    
    [mResponseView release];
    [mAppSecretView release];
    [mAppIDView release];
    [mClientIDView release];
    [mStatusView release];
    [mStartupView release];
    [_file release];
    
    [mAppIDView release];
    [mAppKeyView release];
    [mAppSecretView release];
    [mAppIDView release];
    [mAppKeyView release];
    [mAppSecretView release];
    [mMsgCount release];
    [super dealloc];
}

- (void)initLogFile {
    @autoreleasepool {
        NSString* logFilePath = [self getFileDataPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
            _file = [[NSFileHandle fileHandleForWritingAtPath:logFilePath] retain];
        } else {
            if ([[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil]) {
                _file = [[NSFileHandle fileHandleForWritingAtPath:logFilePath] retain];
            }
        }
    }
}

- (void)log:(NSString *)aLogMsg
{
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

- (NSString*) getFileDataPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString * path = [[[NSMutableString alloc]initWithString:documentsDirectory] autorelease];
    [path appendString:[NSString stringWithFormat:@"/payload_msg_log_%@.txt", [self formateTime:[NSDate date]]]];
    return path;
}


-(NSString*) formateTime:(NSDate*) date {
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* dateTime = [formatter stringFromDate:date];
    [formatter release];
    return dateTime;
}

@end
