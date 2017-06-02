//
//  GANSignupWorkerVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANSignupWorkerVC.h"

#import "GANUserManager.h"
#import "GANAppManager.h"

#import "GANUIPhoneTextField.h"
#import "GANGenericFunctionManager.h"
#import "GANGlobalVCManager.h"

#import "GANLoginVC.h"
#import "GANSignupChooseVC.h"
#import "GANSignupCompanyVC.h"
#import "GANPushNotificationManager.h"

#import "Global.h"
#import <UIView+Shake/UIView+Shake.h>

@interface GANSignupWorkerVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewWorkerIdPanel;
@property (weak, nonatomic) IBOutlet UIView *viewPhonePanel;
@property (weak, nonatomic) IBOutlet UIView *viewPasswordPanel;
@property (weak, nonatomic) IBOutlet UIView *viewConfirmPasswordPanel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *txtWorkerId;
@property (weak, nonatomic) IBOutlet GANUIPhoneTextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;

@end

@implementation GANSignupWorkerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) refreshViews{
    self.viewWorkerIdPanel.layer.cornerRadius = 3;
    self.viewPhonePanel.layer.cornerRadius = 3;
    self.viewPasswordPanel.layer.cornerRadius = 3;
    self.viewConfirmPasswordPanel.layer.cornerRadius = 3;
    self.btnSignup.layer.cornerRadius = 3;
    self.btnLogin.layer.cornerRadius = 3;
    self.btnLogin.layer.borderWidth = 1;
    self.btnLogin.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
}

- (void) shakeInvalidFields: (UIView *) viewContainer{
    CGRect rc = viewContainer.frame;
    CGPoint pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    float maxOffsetY = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
    pt.y = MIN(pt.y, maxOffsetY);
    
    [self.scrollView setContentOffset:pt animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [viewContainer shake:6 withDelta:8 speed:0.07];
    });
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - Biz Logic

- (BOOL) checkMandatoryFields{
    NSString *szWorkerId = self.txtWorkerId.text;
    NSString *szPhone = self.txtPhone.text;
    NSString *szPassword = self.txtPassword.text;
    NSString *szConfirmPassword = self.txtConfirmPassword.text;
    
    if (szWorkerId.length == 0 || [GANGenericFunctionManager isValidUsername:szWorkerId] == NO){
        [self shakeInvalidFields:self.viewWorkerIdPanel];
        return NO;
    }
    if (szPhone.length == 0){
        [self shakeInvalidFields:self.viewPhonePanel];
        return NO;
    }
    if (szPassword.length == 0) {
        [self shakeInvalidFields:self.viewPasswordPanel];
        return NO;
    }
    if (szConfirmPassword.length == 0 || [szConfirmPassword isEqualToString:szPassword] == NO) {
        [self shakeInvalidFields:self.viewConfirmPasswordPanel];
        return NO;
    }
    return YES;
}

- (void) doSignup{
    if ([self checkMandatoryFields] == NO){
        return;
    }
    NSString *szWorkerId = self.txtWorkerId.text;
    NSString *szPhone = self.txtPhone.text;
    NSString *szPassword = self.txtPassword.text;
    
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    [managerUser initializeManagerWithType:GANENUM_USER_TYPE_WORKER];
    
    GANUserWorkerDataModel *modelWorker = [GANUserManager getUserWorkerDataModel];
    modelWorker.szUserName = szWorkerId;
    modelWorker.modelPhone.szLocalNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:szPhone];
    modelWorker.szPassword = szPassword;
    [modelWorker addPlayerIdIfNeeded:[GANPushNotificationManager sharedInstance].szOneSignalPlayerId];
    
#warning Following attributes should be [optional] in API
    
    modelWorker.szFirstName = @"worker_fname";
    modelWorker.szLastName = @"worker_lname";
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [[GANUserManager sharedInstance] requestUserSignupWithCallback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                [self gotoWorkerMain];
            }];
        }
        else if (status == ERROR_USER_SIGNUPFAILED_USERNAMECONFLICT){
            [GANGlobalVCManager showHudErrorWithMessage:@"User name is already registered." DismissAfter:3 Callback:nil];
        }
        else if (status == ERROR_USER_SIGNUPFAILED_EMAILCONFLICT){
            [GANGlobalVCManager showHudErrorWithMessage:@"Same email address is already registered." DismissAfter:3 Callback:nil];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Unknown Error." DismissAfter:3 Callback:nil];
        }
    }];
}

- (void) gotoWorkerMain{
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    UINavigationController *nav = self.navigationController;
    [self presentViewController:vc animated:YES completion:^{
        [self.navigationController setViewControllers:@[[nav.viewControllers objectAtIndex:0]]];
    }];
    */
    
    NSMutableArray *arrNewVCs = [[NSMutableArray alloc] init];
    NSArray *arrVCs = self.navigationController.viewControllers;
    for (int i = 0; i < (int) [arrVCs count]; i++){
        UIViewController *vc = [arrVCs objectAtIndex:i];
        if ([vc isKindOfClass:[GANLoginVC class]] == YES) continue;
        if ([vc isKindOfClass:[GANSignupChooseVC class]] == YES) continue;
        if ([vc isKindOfClass:[GANSignupWorkerVC class]] == YES) continue;
        if ([vc isKindOfClass:[GANSignupCompanyVC class]] == YES) continue;
        [arrNewVCs addObject:vc];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    UITabBarController *tbc = [storyboard instantiateInitialViewController];
    UINavigationController *nav = [tbc.viewControllers objectAtIndex:0];
    if ([arrNewVCs count] > 0){
        nav.viewControllers = arrNewVCs;
    }
    [self.navigationController setViewControllers:@[tbc] animated:YES];

    [[GANAppManager sharedInstance] initializeManagersAfterLogin];
}

- (void) gotoLogin{
    [[GANGlobalVCManager sharedInstance] gotoLoginVC];
}

- (void) gotoToS{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_LOGIN_TOS"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnBackClick:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBtnLoginClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoLogin];
}

- (IBAction)onBtnSignupClick:(id)sender {
    [self.view endEditing:YES];
    [self doSignup];
}

- (IBAction)onBtnToSClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoToS];
}

@end
