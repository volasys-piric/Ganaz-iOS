//
//  GANGlobalVCManager.m
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANGlobalVCManager.h"
#import "GANLoginVC.h"
#import "GANUserManager.h"
#import "GANMessageManager.h"
#import <SVProgressHUD.h>

#define SVPROGRESSHUD_DISMISSAFTER_DEFAULT                      3

@implementation GANGlobalVCManager

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
}

#pragma mark - Redirect to certain VC

- (void) gotoLoginVC{
    UIViewController *vcCurrent = [GANGlobalVCManager getTopMostViewController];
    UINavigationController *nav = vcCurrent.navigationController;
    NSArray *arrOldVCs = nav.viewControllers;
    NSMutableArray *arrNewVCs = [[NSMutableArray alloc] init];
    BOOL found = NO;

    if ([vcCurrent isKindOfClass:[GANLoginVC class]] == YES) return;
    
    for (int i = 0; i < (int) [arrOldVCs count]; i++){
        UIViewController *vc = [arrOldVCs objectAtIndex:i];
        [arrNewVCs addObject:vc];
        if ([vc isKindOfClass:[GANLoginVC class]] == YES){
            found = YES;
            break;
        }
    }
    
    if (found == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_LOGIN"];
        arrNewVCs = [[NSMutableArray alloc] initWithObjects:vc, nil];
    }
    
    [arrNewVCs addObject:vcCurrent];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        nav.viewControllers = arrNewVCs;
        [nav popViewControllerAnimated:YES];
    });
}

+ (void) logoutToLoginVC: (UIViewController *) vcCurrent{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vcLogin = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_LOGIN"];
    vcCurrent.navigationController.viewControllers = @[vcLogin, vcCurrent];
    dispatch_async(dispatch_get_main_queue(), ^{
        [vcCurrent.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - Utils

+ (UIViewController *)findBestViewControllerFromViewController:(UIViewController *)vc {
    if (vc.presentedViewController &&
        [vc.presentedViewController isKindOfClass:[UIAlertController class]] == NO) {
        return [GANGlobalVCManager findBestViewControllerFromViewController:vc.presentedViewController];
    }
    else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *)vc;
        if (svc.viewControllers.count > 0) {
            return [GANGlobalVCManager findBestViewControllerFromViewController:svc.viewControllers.lastObject];
        }
        else {
            return vc;
        }
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *)vc;
        if (svc.viewControllers.count > 0) {
            return [GANGlobalVCManager findBestViewControllerFromViewController:svc.topViewController];
        }
        else {
            return vc;
        }
    }
    else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *)vc;
        if (svc.viewControllers.count > 0) {
            return [GANGlobalVCManager findBestViewControllerFromViewController:svc.selectedViewController];
        }
        else {
            return vc;
        }
    }
    
    // Unknown view controller type
    return vc;
}

+ (UIViewController *)getTopMostViewController {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [GANGlobalVCManager findBestViewControllerFromViewController:viewController];
}

#pragma mark -UI

+ (void) showAlertWithMessage: (NSString *) szMessage{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:szMessage message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void) showAlertWithTitle: (NSString *) szTitle Message: (NSString *) szMessage{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:szTitle message:szMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void) promptWithVC: (UIViewController *) vc Title: (NSString *) title Message: (NSString *) message ButtonYes: (NSString *) buttonYes ButtonNo: (NSString *) buttonNo CallbackYes: (void (^)()) callbackYes CallbackNo: (void (^)()) callbackNo{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionDelete = [UIAlertAction
                                   actionWithTitle:buttonYes
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action)
                                   {
                                       if (callbackYes) callbackYes();
                                   }];
    [alertController addAction:actionDelete];
    
    if (buttonNo != nil){
        UIAlertAction *actionCancel = [UIAlertAction
                                       actionWithTitle:buttonNo
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           if (callbackNo) callbackNo();
                                       }];
        
        [alertController addAction:actionCancel];
    }
    [vc presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Badge

+ (void) updateMessageBadge{
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        int indexTab = 1;
        if ([[GANUserManager sharedInstance] isCompanyUser] == YES) indexTab = 2;
        
        int count = [[GANMessageManager sharedInstance] getUnreadMessageCount];
        UIViewController *vc = [GANGlobalVCManager getTopMostViewController];
        UITabBarController *tbc = vc.tabBarController;
        if (tbc != nil && [tbc isKindOfClass:[UITabBarController class]]){
            if (count > 0){
                [[tbc.tabBar.items objectAtIndex:indexTab] setBadgeValue:[NSString stringWithFormat:@"%d", count]];
            }
            else {
                [[tbc.tabBar.items objectAtIndex:indexTab] setBadgeValue:nil];
            }
        }
    }
}

#pragma mark - ProgressHUD

+ (void) showHudProgress{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD show];
    });
}

+ (void) showHudProgressWithMessage: (NSString *) message{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:message];
    });
}

+ (void) showHudInfoWithMessage: (NSString *) message DismissAfter: (int) delay Callback: (void (^)()) callback{
    if (delay == -1) delay = SVPROGRESSHUD_DISMISSAFTER_DEFAULT;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showInfoWithStatus:message];
        [SVProgressHUD dismissWithDelay:delay completion:callback];
    });
}

+ (void) showHudSuccessWithMessage: (NSString *) message DismissAfter: (int) delay Callback: (void (^)()) callback{
    if (delay == -1) delay = SVPROGRESSHUD_DISMISSAFTER_DEFAULT;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showSuccessWithStatus:message];
        [SVProgressHUD dismissWithDelay:delay completion:callback];
    });
}

+ (void) showHudErrorWithMessage: (NSString *) message DismissAfter: (int) delay Callback: (void (^)()) callback{
    if (delay == -1) delay = SVPROGRESSHUD_DISMISSAFTER_DEFAULT;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showErrorWithStatus:message];
        [SVProgressHUD dismissWithDelay:delay completion:callback];
    });
}

+ (void) hideHudProgress{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD dismiss];
    });
}

+ (void) hideHudProgressWithCallback: (void (^)()) callback{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD dismissWithCompletion:callback];
    });
}

@end
