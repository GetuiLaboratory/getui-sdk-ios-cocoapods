//
//  ViewController.h
//  StartApp
//
//  Created by CoLcY on 12-1-4.
//  Copyright (c) 2012年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
@public
    IBOutlet UITextView *mMsgView;
}

- (void)logMsg:(NSString *)aMsg;

@end
