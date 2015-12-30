//
//  TestFunctionViewController.m
//  Demo
//
//  Created by 赵伟 on 15/8/10.
//
//

#import "AppDelegate.h"
#import "TestViewController.h"

@interface TestViewController ()

@property (retain, nonatomic) IBOutlet UIScrollView *baseScrollView;

@property (retain, nonatomic) IBOutlet UITextField *showMsgTextField;
@property (retain, nonatomic) IBOutlet UITextField *deviceTokenTextField;
@property (retain, nonatomic) IBOutlet UITextField *tagsTextField;
@property (retain, nonatomic) IBOutlet UITextField *aliasTextField;
@property (retain, nonatomic) IBOutlet UITextField *messageTextField;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.baseScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, 900)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    NSLog(@"%@ %@", NSStringFromClass(self.class), @"dealloc");
}

- (IBAction)clickActionButton:(UIButton *)sender {
    switch (sender.tag) {
        case 18: { // 版本
            _showMsgTextField.text = [GeTuiSdk version];
            break;
        }
        case 19: { // clientId
            _showMsgTextField.text = [GeTuiSdk clientId];
            break;
        }
        case 20: { // status
            if ([GeTuiSdk status] == SdkStatusStarted) {
                _showMsgTextField.text = @"启动";
            } else if ([GeTuiSdk status] == SdkStatusStarting) {
                _showMsgTextField.text = @"正在启动";
            } else if ([GeTuiSdk status] == SdkStatusStoped) {
                _showMsgTextField.text = @"停止";
            }
            break;
        }
        case 21: { // 注册DeviceToken
            [GeTuiSdk registerDeviceToken:_deviceTokenTextField.text];

            [self showTos];

            break;
        }
        case 22: { // 设置标签
            NSString *tagName = _tagsTextField.text;
            NSArray *tagNames = [tagName componentsSeparatedByString:@","];
            if (![GeTuiSdk setTags:tagNames]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"设置失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                [self showTos];
            }

            break;
        }
        case 23: { // 绑定别名
            [GeTuiSdk bindAlias:_aliasTextField.text];

            [self showTos];
            break;
        }
        case 24: { // 取消绑定别名
            [GeTuiSdk unbindAlias:_aliasTextField.text];

            [self showTos];
            break;
        }
        case 25: { // 发送消息
            NSString *content = _messageTextField.text;
            NSError *err = nil;
            [GeTuiSdk sendMessage:[content dataUsingEncoding:NSUTF8StringEncoding] error:&err];
            if (err) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:[NSString stringWithFormat:@"send failed:%@", [err localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                [self showTos];
            }

            break;
        }
        case 26: { // 清空通知

            [GeTuiSdk clearAllNotificationForNotificationBar];
            _showMsgTextField.text = @"清空成功";

            break;
        }
        case 27: { // 频繁启动销毁SDK
//            [ExceptionHandler startAutoRunSdk:@0];
            [self showTos];
            break;
        }
        case 28: { // 随即调用SDK方法
//            [ExceptionHandler startAutoRunSdk:@1];
            [self showTos];
            break;
        }
        default:
            break;
    }
}

// 关闭键盘
- (IBAction)didEndOnExit:(UITextField *)sender {
    [sender resignFirstResponder];
}

- (void)showTos {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"点击成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
