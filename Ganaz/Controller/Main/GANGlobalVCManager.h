//
//  GANGlobalVCManager.h
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GANGlobalVCManager : NSObject

+ (instancetype) sharedInstance;
- (void) initializeManager;

+ (UIViewController *)getTopMostViewController;
+ (void) showAlertWithMessage: (NSString *) szMessage;
+ (void) showAlertWithTitle: (NSString *) szTitle Message: (NSString *) szMessage;
+ (void) promptWithVC: (UIViewController *) vc Title: (NSString *) title Message: (NSString *) message ButtonYes: (NSString *) buttonYes ButtonNo: (NSString *) buttonNo CallbackYes: (void (^)()) callbackYes CallbackNo: (void (^)()) callbackNo;

#pragma mark - Redirect to certain VC

- (void) gotoLoginVC;
+ (void) logoutToLoginVC: (UIViewController *) vcCurrent;

#pragma mark - Badge

+ (void) updateMessageBadge;

#pragma mark - ProgressHUD

+ (void) showHudProgress;
+ (void) showHudProgressWithMessage: (NSString *) message;
+ (void) showHudInfoWithMessage: (NSString *) message DismissAfter: (int) delay Callback: (void (^)()) callback;
+ (void) showHudSuccessWithMessage: (NSString *) message DismissAfter: (int) delay Callback: (void (^)()) callback;
+ (void) showHudErrorWithMessage: (NSString *) message DismissAfter: (int) delay Callback: (void (^)()) callback;
+ (void) hideHudProgress;
+ (void) hideHudProgressWithCallback: (void (^)()) callback;

@end
