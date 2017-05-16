//
//  GANPushNotificationManager.h
//  Ganaz
//
//  Created by Piric Djordje on 3/27/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANPushNotificationManager : NSObject

@property (strong, nonatomic) NSString *szOneSignalPlayerId;
@property (strong, nonatomic) NSString *szOneSignalPushToken;

+ (instancetype) sharedInstance;
- (void) initializeManager;

#pragma mark - Registration

- (void) registerForRemoteNotification;
- (void) didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void) didReceiveRemoteNotificationFromOneSignalWithAddtionalData: (NSDictionary *) additionalData shouldHandleUI: (BOOL) shouldHandleUI;
- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void) didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

#pragma mark - OneSignal

- (void) onOneSignalPlayerIdAvailable: (NSString *) playerId PushToken: (NSString *) pushToken;

@end
