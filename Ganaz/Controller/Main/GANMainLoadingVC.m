//
//  GANMainLoadingVC.m
//  Ganaz
//
//  Created by Piric Djordje on 3/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMainLoadingVC.h"
#import "GANLocationManager.h"
#import "GANUserManager.h"
#import "GANWorkerLoginCodeVC.h"
#import "Global.h"
#import "GANAppManager.h"
#import "GANAppUpdatesPopupVC.h"
#import "GANFadeTransitionDelegate.h"

@interface GANMainLoadingVC () <GANAppUpdatesPopupDelegate>

@property (assign, atomic) BOOL didMainViewShow;
@property (assign, atomic) int nRetry;
@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@end

@implementation GANMainLoadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.nRetry = 0;
    self.didMainViewShow = NO;
    
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    
    GANAppManager *managerApp = [GANAppManager sharedInstance];
    [managerApp requestGetAppInfoFromGatewayWithCallbackCallback:^(int status) {
        if (managerApp.enumAppUpdateType == GANENUM_APPCONFIG_APPUPDATETYPE_NONE){
            [self gotoWorkerView];
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showDlgForAppUpdates];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void) showDlgForAppUpdates{
    GANAppUpdatesPopupVC *vc = [[GANAppUpdatesPopupVC alloc] initWithNibName:@"AppUpdatesPopup" bundle:nil];
    
    vc.delegate = self;
    vc.view.backgroundColor = [UIColor clearColor];
    [vc refreshFields];
    
    [vc setTransitioningDelegate:self.transController];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) gotoWorkerView{
    if (self.didMainViewShow == YES) return;
    if ([GANLocationManager sharedInstance].isLocationSet == NO){
        self.nRetry++;
        if (self.nRetry < 10){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self gotoWorkerView];
            });
            return;
        }
    }
    
    self.didMainViewShow = YES;
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    
    if ([managerUser loadFromLocalstorage] == YES && managerUser.modelUserMinInfo.enumAuthType == GANENUM_USER_AUTHTYPE_PHONE){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboardMain = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIStoryboard *storyboardLogin = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
            UIViewController *vcChoose = [storyboardMain instantiateViewControllerWithIdentifier:@"STORYBOARD_MAIN_CHOOSE"];
            UIViewController *vcLogin = [storyboardLogin instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_PHONE"];
            GANWorkerLoginCodeVC *vcCode = [storyboardLogin instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_CODE"];
            vcCode.szPhoneNumber = managerUser.modelUserMinInfo.modelPhone.szLocalNumber;
            vcCode.isLogin = YES;
            vcCode.isAutoLogin = YES;
            
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [self.navigationController setViewControllers:@[vcChoose, vcLogin, vcCode] animated:YES];
            vcLogin.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_MAIN_CHOOSE"];
            [self.navigationController setViewControllers:@[vc] animated:YES];
        });
    }
}

#pragma mark - AppUpdatesPopup Delegate

- (void)didCancelClick{
    if ([GANAppManager sharedInstance].enumAppUpdateType == GANENUM_APPCONFIG_APPUPDATETYPE_OPTIONAL){
        [self gotoWorkerView];
    }
    else if ([GANAppManager sharedInstance].enumAppUpdateType == GANENUM_APPCONFIG_APPUPDATETYPE_MANDATORY){
        // Crash
        exit(0);
    }
}

@end
