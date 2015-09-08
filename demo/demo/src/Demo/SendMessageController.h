//
//  SendMessageController.h
//  SdkTester
//
//  Created by huang.haiyang on 13-4-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendMessageController : UIViewController

@property(nonatomic, assign) IBOutlet UITextField *contentView;

- (IBAction)send:(id)sender;

@end
