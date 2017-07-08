//
//  AppDelegate.m
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "AppDelegate.h"
#import "GANAppManager.h"
#import "GANUserManager.h"
#import "GANMessageManager.h"
#import "GANPushNotificationManager.h"

#import "Global.h"
#import <OneSignal/OneSignal.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:GANUICOLOR_THEMECOLOR_MAIN];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UITabBar appearance] setTintColor:GANUICOLOR_THEMECOLOR_TABBAR_SELECTED];
    
    [[GANAppManager sharedInstance] initializeAppConfig];
    [[GANAppManager sharedInstance] initializeManagersAfterLaunch];
    
    [OneSignal initWithLaunchOptions:launchOptions appId:ONESIGNAL_APPID handleNotificationReceived:^(OSNotification *notification) {
        // This will be fired when the app is in focus.
        
        OSNotificationPayload* payload = notification.payload;
        
        if (payload.additionalData) {
            NSDictionary* additionalData = payload.additionalData;
            [[GANPushNotificationManager sharedInstance] didReceiveRemoteNotificationFromOneSignalWithAddtionalData:additionalData shouldHandleUI:YES];
        }
    } handleNotificationAction:^(OSNotificationOpenedResult *result) {
        // This will be fired when the app is open via notification.
        
        OSNotificationPayload* payload = result.notification.payload;
        
        if (payload.additionalData) {
//            NSDictionary* additionalData = payload.additionalData;
        }
    } settings:@{kOSSettingsKeyInFocusDisplayOption: @(OSNotificationDisplayTypeNone), kOSSettingsKeyAutoPrompt : @YES}];
    
#if TARGET_OS_SIMULATOR
#else
    [OneSignal registerForPushNotifications];
    [OneSignal IdsAvailable:^(NSString *userId, NSString *pushToken) {
        [[GANPushNotificationManager sharedInstance] onOneSignalPlayerIdAvailable:userId PushToken:pushToken];
    }];
#endif
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES &&
        [[GANUserManager sharedInstance] isWorker] == YES){
        [[GANMessageManager sharedInstance] requestGetMessageListWithCallback:nil];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
