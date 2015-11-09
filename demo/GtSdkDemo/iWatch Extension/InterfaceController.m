//
//  InterfaceController.m
//  iWatch Extension
//
//  Created by 赵伟 on 15/10/29.
//  Copyright © 2015年 赵伟. All rights reserved.
//

#import "InterfaceController.h"
@import WatchConnectivity;

@interface InterfaceController()

@property (strong, nonatomic) IBOutlet WKInterfaceSwitch *statusSwitch;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}
- (IBAction)changeSwitch:(BOOL)value {
    if (value) {
        // Sends a non-nil result to the parent iOS application.
        [[WCSession defaultSession] sendMessage:@{@"SdkOn" : @"YES"} replyHandler:^(NSDictionary<NSString *,id> * __nonnull replyMessage) {
            NSLog(@"Reply Info: %@", replyMessage);
            [_statusSwitch setOn:YES];
        } errorHandler:^(NSError * __nonnull error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            [_statusSwitch setOn:NO];
        }];
    }else {
        // Sends a non-nil result to the parent iOS application.
        [[WCSession defaultSession] sendMessage:@{@"SdkOn" : @"NO"} replyHandler:^(NSDictionary<NSString *,id> * __nonnull replyMessage) {
            NSLog(@"Reply Info: %@", replyMessage);
            [_statusSwitch setOn:NO];
        } errorHandler:^(NSError * __nonnull error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            [_statusSwitch setOn:YES];
        }];
    }
}

@end



