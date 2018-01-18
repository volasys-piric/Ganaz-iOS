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
#import "GANDeeplinkManager.h"
#import "GANGlobalVCManager.h"

#import "Global.h"
#import <OneSignal/OneSignal.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Branch/Branch.h>

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
    
    [Fabric with:@[[Crashlytics class]]];

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
    
    // Branch.io For Deferred Deep Link
    
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error && params) {
            // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
            // params will be empty if no data found
            // ... insert custom logic here ...
            
            GANLOG(@"Branch.io Initialization Params: %@", params);
            
            GANDeeplinkManager *managerDeeplink = [GANDeeplinkManager sharedInstance];
            [managerDeeplink analyzeBranchDeeplink:params];
            
            if (managerDeeplink.enumAction == GANENUM_BRANCHDEEPLINK_ACTION_WORKER_SIGNUPWITHPHONE && [[GANUserManager sharedInstance] isUserLoggedIn] == NO) {
                // Open Worker > Phone VC
                [GANGlobalVCManager gotoWorkerLoginVC];
            }
        }
    }];
    
    return YES;
}

#pragma mark - Branch.io

// Respond to URI scheme links
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // pass the url to the handle deep link call
    [[Branch getInstance] application:application
                              openURL:url
                    sourceApplication:sourceApplication
                           annotation:annotation];
    
    // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
    return YES;
}

// Respond to Universal Links
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    return handledByBranch;
}

#pragma mark - Application Activity

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
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
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
