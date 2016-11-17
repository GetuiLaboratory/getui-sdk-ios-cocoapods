//
//  NotificationService.m
//  NotificationService
//
//  Created by gexin on 16/10/10.
//  Copyright © 2016年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import "NotificationService.h"
#import "GeTuiExtSdk.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    [GeTuiExtSdk handelNotificationServiceRequest:request withComplete:^{
        
        // Modify the notification content here...
        self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
        self.contentHandler(self.bestAttemptContent);
    }];

}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
