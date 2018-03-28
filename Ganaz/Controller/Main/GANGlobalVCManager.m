//
//  GANGlobalVCManager.m
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANGlobalVCManager.h"
#import "GANMainChooseVC.h"
#import "GANWorkerLoginPhoneVC.h"
#import "GANWorkerLoginCodeVC.h"
#import "GANMainLoadingVC.h"

#import "GANUserManager.h"
#import "GANMessageManager.h"
#import "SVProgressHUD.h"
#import "UIView+Shake.h"

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

+ (void) logoutToWorkerLoginVC: (UIViewController *) vcCurrent{
    [vcCurrent dismissViewControllerAnimated:YES completion:nil];
}

+ (void) gotoWorkerLoginVC {
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES) {
        return;
    }
    
    UIViewController *vcTop = [GANGlobalVCManager getTopMostViewController];
    UINavigationController *nav = vcTop.navigationController;

    if ([vcTop isKindOfClass:[GANMainLoadingVC class]] == YES) return;
    if ([vcTop isKindOfClass:[GANWorkerLoginPhoneVC class]] == YES) return;
    if ([vcTop isKindOfClass:[GANWorkerLoginCodeVC class]] == YES) return;
    
    // Should go to Worker > Login VC, populating phone number...
    UIStoryboard *storyboardMain = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *storyboardLogin = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
    UIViewController *vcChoose = [storyboardMain instantiateViewControllerWithIdentifier:@"STORYBOARD_MAIN_CHOOSE"];
    UIViewController *vcLogin = [storyboardLogin instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_PHONE"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [nav setNavigationBarHidden:NO animated:YES];
        [nav setViewControllers:@[vcChoose, vcLogin] animated:YES];
        vcLogin.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
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

#pragma mark - Animations

+ (void) shakeView: (UIView *) view{
    dispatch_async(dispatch_get_main_queue(), ^{
        [view shake:6 withDelta:8 speed:0.07];
    });
}

+ (void) shakeView: (UIView *) view InScrollView: (UIScrollView *) scrollView{
    BOOL isVisible = CGRectIntersectsRect(scrollView.bounds, view.frame);
    if (isVisible == NO){
        CGRect rc = view.frame;
        CGPoint pt = rc.origin;
        pt.x = 0;
        pt.y -= 60;
        pt.y = MAX(0, pt.y);
        float maxOffsetY = scrollView.contentSize.height - scrollView.frame.size.height;
        pt.y = MIN(pt.y, maxOffsetY);
        
        [scrollView setContentOffset:pt animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view shake:6 withDelta:8 speed:0.07];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [view shake:6 withDelta:8 speed:0.07];
        });
    }
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

+ (void)showAlertControllerWithVC: (UIViewController *) vc Title:(NSString *)title Message:(NSString *)message Callback: (void (^)()) callback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (callback) callback();
    }];
    [alertController addAction:actionOk];
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc presentViewController:alertController animated:YES completion:nil];
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma mark - Badge

+ (void) updateMessageBadge{
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
        
        if ([[GANUserManager sharedInstance] isCompanyUser] == YES) {
            int countUnreadGeneralMessages = [managerMessage getUnreadGeneralMessageCount];
            int countUnreadCandidateMessages = [managerMessage getUnreadCandidateMessageCount];
            UIViewController *vc = [GANGlobalVCManager getTopMostViewController];
            UITabBarController *tbc = vc.tabBarController;
            if (tbc != nil && [tbc isKindOfClass:[UITabBarController class]]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (countUnreadGeneralMessages > 0){
                        [[tbc.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d", countUnreadGeneralMessages]];
                    }
                    else {
                        [[tbc.tabBar.items objectAtIndex:2] setBadgeValue:nil];
                    }
                    
                    if (countUnreadCandidateMessages > 0){
                        [[tbc.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d", countUnreadCandidateMessages]];
                    }
                    else {
                        [[tbc.tabBar.items objectAtIndex:1] setBadgeValue:nil];
                    }
                });
            }
        }
        else {
            int countUnreadMessages = [managerMessage getUnreadGeneralMessageCount] + [managerMessage getUnreadCandidateMessageCount];
            UIViewController *vc = [GANGlobalVCManager getTopMostViewController];
            UITabBarController *tbc = vc.tabBarController;
            if (tbc != nil && [tbc isKindOfClass:[UITabBarController class]]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (countUnreadMessages > 0){
                        [[tbc.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d", countUnreadMessages]];
                    }
                    else {
                        [[tbc.tabBar.items objectAtIndex:1] setBadgeValue:nil];
                    }
                });
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

+ (void)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(NSInteger) nIndex
{
    tabBarController.selectedIndex = nIndex;
    /*
    UIView * fromView = tabBarController.selectedViewController.view;
    UIView * toView = [[tabBarController.viewControllers objectAtIndex:nIndex] view];
    
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.3
                       options: UIViewAnimationOptionTransitionNone
                    completion:^(BOOL finished) {
                        tabBarController.selectedIndex = nIndex;
    }];*/
}

@end
