//
//  GANPushNotificationManager.m
//  Ganaz
//
//  Created by Piric Djordje on 3/27/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANPushNotificationManager.h"
#import "AppDelegate.h"
#import "GANUserManager.h"
#import "GANMessageManager.h"
#import "GANUtils.h"
#import "GANGenericFunctionManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"

@implementation GANPushNotificationManager

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initializeManager];
    }
    return self;
}

- (void) initializeManager{
    self.szOneSignalPlayerId = @"";
    self.szOneSignalPushToken = @"";
}

#pragma mark - Registration

- (void) registerForRemoteNotification{
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void) unregisterForRemoteNotification{
//    NSString *deviceUdid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (void) didReceiveRemoteNotification:(NSDictionary *)userInfo{
    GANLOG(@"didReceiveRemoteNotification userInfo=%@", userInfo);
}

- (void) didReceiveRemoteNotificationFromOneSignalWithAddtionalData: (NSDictionary *) additionalData shouldHandleUI: (BOOL) shouldHandleUI{
    GANLOG(@"didReceiveRemoteNotificationFromOneSignalWithAddtionalData userInfo = %@", additionalData);
    
    NSString *type = [GANGenericFunctionManager refineNSString:[additionalData objectForKey:@"type"]];
    GANENUM_PUSHNOTIFICATION_TYPE enumType = [GANUtils getPushNotificationTypeFromString:type];
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO) return;
    
    if ([[GANUserManager sharedInstance] isWorker] == YES){
        if (enumType == GANENUM_PUSHNOTIFICATION_TYPE_MESSAGE){
            // New message is arrived.
            [GANGlobalVCManager showHudInfoWithMessage:@"Nuevo mensaje llegó." DismissAfter:-1 Callback:nil];
        }
        else if (enumType == GANENUM_PUSHNOTIFICATION_TYPE_RECRUIT){
            // Good news! There is a new job for you.
            [GANGlobalVCManager showHudInfoWithMessage:@"Buenas noticias! Nuevo trabajo para ud." DismissAfter:-1 Callback:nil];
        }
    }
    else {
        if (enumType == GANENUM_PUSHNOTIFICATION_TYPE_MESSAGE){
            [GANGlobalVCManager showHudInfoWithMessage:@"New message is arrived." DismissAfter:-1 Callback:nil];
        }
        else if (enumType == GANENUM_PUSHNOTIFICATION_TYPE_APPLICATION){
            [GANGlobalVCManager showHudInfoWithMessage:@"New job inquiry is arrived." DismissAfter:-1 Callback:nil];
        }
        else if (enumType == GANENUM_PUSHNOTIFICATION_TYPE_SUGGEST){
            [GANGlobalVCManager showHudInfoWithMessage:@"New job inquiry is arrived." DismissAfter:-1 Callback:nil];
        }
    }
    [[GANMessageManager sharedInstance] requestGetMessageListWithCallback:nil];
}

- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
}

- (void) didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Failed to register for remote notification: %@", error.localizedDescription);
}

#pragma mark - OneSignal

- (void) onOneSignalPlayerIdAvailable: (NSString *) playerId PushToken: (NSString *) pushToken{
    GANLOG(@"OneSignal IdsAvailable UserId: %@\nPushToken = %@", playerId, pushToken);
    
    if (playerId != nil){
        if ([self.szOneSignalPlayerId isEqualToString:playerId] == NO){
            self.szOneSignalPlayerId = playerId;
            GANUserManager *managerUser = [GANUserManager sharedInstance];
            if ([managerUser isUserLoggedIn] == YES && ([managerUser.modelUser getIndexForPlayerId:self.szOneSignalPlayerId] == -1)){
                [managerUser.modelUser addPlayerIdIfNeeded:self.szOneSignalPlayerId];
                [managerUser requestUpdateOneSignalPlayerIdWithCallback:nil];
            }
        }
    }
    if (pushToken != nil){
        if ([self.szOneSignalPushToken isEqualToString:pushToken] == NO){
            self.szOneSignalPushToken = pushToken;
        }
    }
    
}

@end
