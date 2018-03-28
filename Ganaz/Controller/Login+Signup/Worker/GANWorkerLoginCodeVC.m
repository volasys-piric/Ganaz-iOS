//
//  GANWorkerLoginCodeVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerLoginCodeVC.h"
#import "GANMainChooseVC.h"
#import "GANWorkerLoginPhoneVC.h"
#import "GANWorkerJobApplyVC.h"

#import "GANUserManager.h"
#import "GANCacheManager.h"
#import "GANAppManager.h"
#import "GANPushNotificationManager.h"

#import "Global.h"
#import "GANGlobalVCManager.h"
#import "GANGenericFunctionManager.h"

@interface GANWorkerLoginCodeVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewCodePanel;
@property (weak, nonatomic) IBOutlet UIView *viewCode0;
@property (weak, nonatomic) IBOutlet UIView *viewCode1;
@property (weak, nonatomic) IBOutlet UIView *viewCode2;
@property (weak, nonatomic) IBOutlet UIView *viewCode3;

@property (weak, nonatomic) IBOutlet UILabel *labelCode0;
@property (weak, nonatomic) IBOutlet UILabel *labelCode1;
@property (weak, nonatomic) IBOutlet UILabel *labelCode2;
@property (weak, nonatomic) IBOutlet UILabel *labelCode3;

@property (weak, nonatomic) IBOutlet UITextField *textfieldCode;
@property (weak, nonatomic) IBOutlet UIButton *buttonContinue;
@property (weak, nonatomic) IBOutlet UILabel *labelToS;

@end

@implementation GANWorkerLoginCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self refreshViews];
    [self refreshCodePanel];
    [self checkAutoLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.viewCode0.clipsToBounds = YES;
    self.viewCode0.layer.cornerRadius = 3;
    self.viewCode1.clipsToBounds = YES;
    self.viewCode1.layer.cornerRadius = 3;
    self.viewCode2.clipsToBounds = YES;
    self.viewCode2.layer.cornerRadius = 3;
    self.viewCode3.clipsToBounds = YES;
    self.viewCode3.layer.cornerRadius = 3;
    self.buttonContinue.clipsToBounds = YES;
    self.buttonContinue.layer.cornerRadius = 3;
    self.textfieldCode.tintColor = [UIColor clearColor];
    
    if (self.isLogin == YES){
        self.labelToS.text = @"";
    }
}

- (void) checkAutoLogin{
    if (self.isAutoLogin == YES){
        GANUserManager *managerUser = [GANUserManager sharedInstance];
        self.phone = managerUser.modelUserMinInfo.modelPhone;
        self.textfieldCode.text = managerUser.modelUserMinInfo.szPassword;
        [self refreshCodePanel];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doLogin];
        });
    }
    else {
        [self.textfieldCode becomeFirstResponder];
    }
}

#pragma mark - Biz Logic

- (void) refreshCodePanel{
    NSString *szCode = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldCode.text];
    NSArray *arrLabels = @[self.labelCode0, self.labelCode1, self.labelCode2,
                           self.labelCode3,
                           ];
    for (int i = 0; i < (int) [arrLabels count]; i++){
        UILabel *label = [arrLabels objectAtIndex:i];
        if (szCode.length <= i){
            label.text = @"";
        }
        else {
            label.text = [szCode substringWithRange:NSMakeRange(i, 1)];
        }
    }
}

- (BOOL) checkMandatoryFields{
    NSString *szCode = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldCode.text];
    if (szCode.length < 4){
        [GANGlobalVCManager shakeView:self.viewCodePanel];
        return NO;
    }
    return YES;
}

- (void) doLogin{
    if ([self checkMandatoryFields] == NO) return;
    
    NSString *szPassword = self.textfieldCode.text;
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    
    [managerUser requestUserLoginWithPhoneNumber:[self.phone getNormalizedPhoneNumber] Password:szPassword Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                GANUserManager *managerUser = [GANUserManager sharedInstance];
                if ([managerUser isCompanyUser] == YES){
                    [self gotoCompanyMain];
                }
                else {
                    [self gotoWorkerMain];
                }
                GANACTIVITY_REPORT(@"User logged in");
            }];
        }
        else if (status == ERROR_USER_LOGINFAILED_USERNOTFOUND || status == ERROR_USER_LOGINFAILED_PASSWORDWRONG){
            // Login information is not correct.
            [GANGlobalVCManager showHudErrorWithMessage:@"O el número de teléfono o su contraseña es incorrecto" DismissAfter:-1 Callback:nil];
        }
        else {
            // Sorry, we've encountered an issue.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) doOnboardingSignup {
    if ([self checkMandatoryFields] == NO){
        return;
    }
    NSString *szPassword = self.textfieldCode.text;
    
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    [managerUser initializeManagerWithType:GANENUM_USER_TYPE_WORKER];
    
    GANUserWorkerDataModel *modelWorker = [GANUserManager getUserWorkerDataModel];
    modelWorker.enumAuthType = GANENUM_USER_AUTHTYPE_PHONE;
    modelWorker.szUserName = [self.phone getNormalizedPhoneNumber];
    modelWorker.modelPhone = self.phone;
    modelWorker.szPassword = szPassword;
    modelWorker.szId = self.szId;
    
    [modelWorker addPlayerIdIfNeeded:[GANPushNotificationManager sharedInstance].szOneSignalPlayerId];
    
#warning Following attributes should be [optional] in API
    
    modelWorker.szFirstName = @"worker_fname";
    modelWorker.szLastName = @"worker_lname";
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [[GANUserManager sharedInstance] requestOnboardingUserSignupWithCallback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                [self gotoWorkerMain];
            }];
            GANACTIVITY_REPORT(@"Onboarding User signed up");
        }
        else if (status == ERROR_USER_SIGNUPFAILED_USERNAMECONFLICT){
            // User name is already registered.
            [GANGlobalVCManager showHudErrorWithMessage:@"User name is already registered." DismissAfter:-1 Callback:nil];
        }
        else if (status == ERROR_USER_SIGNUPFAILED_EMAILCONFLICT){
            // Same email address is already registered.
            [GANGlobalVCManager showHudErrorWithMessage:@"Same email address is already registered." DismissAfter:-1 Callback:nil];
        }
        else {
            // Sorry, we've encountered an issue.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:3 Callback:nil];
        }
    }];
}

- (void) doSignup{
    if ([self checkMandatoryFields] == NO){
        return;
    }
    NSString *szPassword = self.textfieldCode.text;
    
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    [managerUser initializeManagerWithType:GANENUM_USER_TYPE_WORKER];
    
    GANUserWorkerDataModel *modelWorker = [GANUserManager getUserWorkerDataModel];
    modelWorker.enumAuthType = GANENUM_USER_AUTHTYPE_PHONE;
    modelWorker.szUserName = [self.phone getNormalizedPhoneNumber];
    modelWorker.modelPhone = self.phone;
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
            GANACTIVITY_REPORT(@"User signed up");
        }
        else if (status == ERROR_USER_SIGNUPFAILED_USERNAMECONFLICT){
            // User name is already registered.
            [GANGlobalVCManager showHudErrorWithMessage:@"User name is already registered." DismissAfter:-1 Callback:nil];
        }
        else if (status == ERROR_USER_SIGNUPFAILED_EMAILCONFLICT){
            // Same email address is already registered.
            [GANGlobalVCManager showHudErrorWithMessage:@"Same email address is already registered." DismissAfter:-1 Callback:nil];
        }
        else {
            // Sorry, we've encountered an issue.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:3 Callback:nil];
        }
    }];

}

- (void) gotoCompanyMain{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    UINavigationController *nav = self.navigationController;
    [self presentViewController:vc animated:YES completion:^{
        [self.navigationController setViewControllers:@[[nav.viewControllers objectAtIndex:0]]];
    }];
    
    [[GANAppManager sharedInstance] initializeManagersAfterLogin];
}

- (void) gotoWorkerMain{
    NSMutableArray *arrNewVCs = [[NSMutableArray alloc] init];
    NSArray *arrVCs = self.navigationController.viewControllers;
    
    // ChooseVC, LoginPhoneVC, LoginCodeVC
    for (int i = 0; i < (int)([arrVCs count]); i++){
        UIViewController *vc = [arrVCs objectAtIndex:i];
        if (([vc isKindOfClass:[GANMainChooseVC class]] == NO) &&
            ([vc isKindOfClass:[GANWorkerLoginPhoneVC class]] == NO) &&
            ([vc isKindOfClass:[GANWorkerLoginCodeVC class]] == NO)){
            [arrNewVCs addObject:vc];
        }
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];

    UITabBarController *tbc = [storyboard instantiateInitialViewController];
    if ([arrNewVCs count] > 0){
        UINavigationController *nav = [tbc.viewControllers objectAtIndex:0];
        nav.viewControllers = arrNewVCs;
    }
    else {
        
    }
    
    [self.navigationController presentViewController:tbc animated:YES completion:^{
       [self.navigationController setViewControllers:@[[self.navigationController.viewControllers objectAtIndex:0]]];
        
        GANCacheManager *managerCache = [GANCacheManager sharedInstance];
        if ([managerCache.modelOnboardingAction isOnboardingActionForWorker] == YES) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [managerCache.modelOnboardingAction postNotificationToContinueOnboardingAction];
            });
        }
        
    }];
    [[GANAppManager sharedInstance] initializeManagersAfterLogin];
}

- (void) gotoToS{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_LOGIN_TOS"];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonContinueClick:(id)sender {
    [self.view endEditing:YES];
    if (self.isLogin == YES){
        [self doLogin];
    } else if (self.isOnboardingWorker == YES) {
        [self doOnboardingSignup];
    }
    else {
        [self doSignup];
    }
}

- (IBAction)onButtonBackClick:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onButtonToSClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoToS];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onTextfieldCodeChanged:(id)sender {
    NSString *szCode = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldCode.text];
    if (szCode.length > 4){
        szCode = [szCode substringToIndex:4];
    }
    self.textfieldCode.text = szCode;
    [self refreshCodePanel];
}

@end
