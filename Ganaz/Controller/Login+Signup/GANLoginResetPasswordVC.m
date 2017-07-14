//
//  GANLoginResetPasswordVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/14/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANLoginResetPasswordVC.h"
#import "GANUserManager.h"
#import "GANPushNotificationManager.h"
#import "GANMainChooseVC.h"
#import "GANCompanyLoginPhoneVC.h"
#import "GANWorkerLoginPhoneVC.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"
#import "GANGlobalVCManager.h"
#import "GANAppManager.h"

@interface GANLoginResetPasswordVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewOldPasswordPanel;
@property (weak, nonatomic) IBOutlet UIView *viewNewPasswordPanel;
@property (weak, nonatomic) IBOutlet UIView *viewOldPassword;
@property (weak, nonatomic) IBOutlet UIView *viewNewPassword;

@property (weak, nonatomic) IBOutlet UIView *viewNewCode0;
@property (weak, nonatomic) IBOutlet UIView *viewNewCode1;
@property (weak, nonatomic) IBOutlet UIView *viewNewCode2;
@property (weak, nonatomic) IBOutlet UIView *viewNewCode3;

@property (weak, nonatomic) IBOutlet UITextField *textfieldOldPassword;
@property (weak, nonatomic) IBOutlet UITextField *textfieldNewCode;

@property (weak, nonatomic) IBOutlet UILabel *labelCode0;
@property (weak, nonatomic) IBOutlet UILabel *labelCode1;
@property (weak, nonatomic) IBOutlet UILabel *labelCode2;
@property (weak, nonatomic) IBOutlet UILabel *labelCode3;

@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonUpdate;

@end

@implementation GANLoginResetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshViews];
    [self refreshNewCodePanel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.viewOldPassword.layer.cornerRadius = 3;
    self.viewOldPassword.clipsToBounds = YES;
    self.buttonLogin.layer.cornerRadius = 3;
    self.buttonLogin.clipsToBounds = YES;
    self.buttonUpdate.layer.cornerRadius = 3;
    self.buttonUpdate.clipsToBounds = YES;
    
    self.viewNewCode0.clipsToBounds = YES;
    self.viewNewCode0.layer.cornerRadius = 3;
    self.viewNewCode1.clipsToBounds = YES;
    self.viewNewCode1.layer.cornerRadius = 3;
    self.viewNewCode2.clipsToBounds = YES;
    self.viewNewCode2.layer.cornerRadius = 3;
    self.viewNewCode3.clipsToBounds = YES;
    self.viewNewCode3.layer.cornerRadius = 3;
    self.textfieldNewCode.tintColor = [UIColor clearColor];
}

- (void) showUpdatePanel{
    dispatch_async(dispatch_get_main_queue(), ^{
        int x = (int) self.viewOldPasswordPanel.frame.size.width;
        CGPoint pt = CGPointMake(x, 0);
        [self.scrollView setContentOffset:pt animated:YES];
    });
}

#pragma mark - Biz Logic

- (void) refreshNewCodePanel{
    NSString *szCode = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldNewCode.text];
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

- (BOOL) checkMandatoryFieldsForLogin{
    NSString *szOldPassword = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldOldPassword.text];
    if (szOldPassword.length == 0){
        [GANGlobalVCManager shakeView:self.viewOldPassword];
        return NO;
    }
    return YES;
}

- (BOOL) checkMandatoryFieldsForUpdate{
    NSString *szNewCode = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldNewCode.text];
    if (szNewCode.length < 4){
        [GANGlobalVCManager shakeView:self.viewNewPassword];
        return NO;
    }
    return YES;
}

- (void) doLogin{
    if ([self checkMandatoryFieldsForLogin] == NO) return;
    
    NSString *szPassword = self.textfieldOldPassword.text;
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [managerUser requestUserLoginWithUsername:self.szUsername Password:szPassword Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                [self showUpdatePanel];
                GANACTIVITY_REPORT(@"User logged in");
            }];
        }
        else if (status == ERROR_USER_LOGINFAILED_USERNOTFOUND || status == ERROR_USER_LOGINFAILED_PASSWORDWRONG){
            [GANGlobalVCManager showHudErrorWithMessage:@"Login information is not correct." DismissAfter:-1 Callback:nil];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Unknown Error." DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) doUpdatePassword{
    if ([self checkMandatoryFieldsForUpdate] == NO) return;
    
    NSString *szPassword = self.textfieldNewCode.text;
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [managerUser requestUpdatePassword:szPassword WithCallback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                GANUserManager *managerUser = [GANUserManager sharedInstance];
                if ([managerUser isCompanyUser] == YES){
                    [self gotoCompanyMain];
                }
                else {
                    [self gotoWorkerMain];
                }
                GANACTIVITY_REPORT(@"User updated password");
            }];
        }
        else if (status == ERROR_USER_LOGINFAILED_USERNOTFOUND || status == ERROR_USER_LOGINFAILED_PASSWORDWRONG){
            [GANGlobalVCManager showHudErrorWithMessage:@"Login information is not correct." DismissAfter:-1 Callback:nil];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Unknown Error." DismissAfter:-1 Callback:nil];
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
            ([vc isKindOfClass:[GANCompanyLoginPhoneVC class]] == NO) &&
            ([vc isKindOfClass:[GANWorkerLoginPhoneVC class]] == NO) &&
            ([vc isKindOfClass:[GANLoginResetPasswordVC class]] == NO)){
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
    }];
    
    [[GANAppManager sharedInstance] initializeManagersAfterLogin];
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonLoginClick:(id)sender {
    [self.view endEditing:YES];
    [self doLogin];
}

- (IBAction)onButtonUpdateClick:(id)sender {
    [self.view endEditing:YES];
    [self doUpdatePassword];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == self.textfieldOldPassword){
        [self doLogin];
    }
    else if (textField == self.textfieldNewCode){
        [self doUpdatePassword];
    }
    return YES;
}

- (IBAction)onTextfieldNewCodeChanged:(id)sender {
    NSString *szCode = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldNewCode.text];
    if (szCode.length > 4){
        szCode = [szCode substringToIndex:4];
    }
    self.textfieldNewCode.text = szCode;
    [self refreshNewCodePanel];
}

@end
