//
//  GANWorkerLoginPhoneVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerLoginPhoneVC.h"
#import "GANDeeplinkManager.h"
#import "GANUserManager.h"
#import "GANWorkerLoginCodeVC.h"
#import "GANLoginResetPasswordVC.h"
#import "GANGenericFunctionManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"
#import "GANAppManager.h"

@interface GANWorkerLoginPhoneVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPhonePanel;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *buttonContinue;

@property (weak, nonatomic) IBOutlet UILabel *labelNumber0;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber1;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber2;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber3;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber4;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber5;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber6;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber7;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber8;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber9;

@end

@implementation GANWorkerLoginPhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    GANDeeplinkManager *managerDeeplink = [GANDeeplinkManager sharedInstance];
    if (managerDeeplink.enumAction == GANENUM_BRANCHDEEPLINK_ACTION_WORKER_SIGNUPWITHPHONE && [[GANUserManager sharedInstance] isUserLoggedIn] == NO) {
        self.textfieldPhoneNumber.text = managerDeeplink.szPhoneNumber;
    }
    
    [self refreshViews];
    [self refreshPhonePanel];
    [self.textfieldPhoneNumber becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.viewPhonePanel.clipsToBounds = YES;
    self.viewPhonePanel.layer.cornerRadius = 3;
    self.buttonContinue.clipsToBounds = YES;
    self.buttonContinue.layer.cornerRadius = 3;
    self.textfieldPhoneNumber.tintColor = [UIColor clearColor];
}

#pragma mark - Biz Logic

- (void) refreshPhonePanel{
    NSString *szPhoneNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldPhoneNumber.text];
    NSArray *arrLabels = @[self.labelNumber0, self.labelNumber1, self.labelNumber2,
                           self.labelNumber3, self.labelNumber4, self.labelNumber5,
                           self.labelNumber6, self.labelNumber7, self.labelNumber8,
                           self.labelNumber9,
                           ];
    for (int i = 0; i < (int) [arrLabels count]; i++){
        UILabel *label = [arrLabels objectAtIndex:i];
        if (szPhoneNumber.length <= i){
            label.text = @"";
        }
        else {
            label.text = [szPhoneNumber substringWithRange:NSMakeRange(i, 1)];
        }
    }
}

- (BOOL) checkMandatoryFields{
    NSString *phoneNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldPhoneNumber.text];
    if (phoneNumber.length != 10){
        [GANGlobalVCManager shakeView:self.viewPhonePanel];
        return NO;
    }
    return YES;
}

- (void) doLogin{
    if ([self checkMandatoryFields] == NO){
        return;
    }
    NSString *phoneNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldPhoneNumber.text];
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    
    // Check if user exists
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [managerUser requestSearchUserByPhoneNumber:phoneNumber Type:GANENUM_USER_TYPE_ANY Callback:^(int status, NSArray *array) {
        if (status == SUCCESS_WITH_NO_ERROR && array != nil && [array count] > 0){
            GANUserBaseDataModel *user = [array objectAtIndex:0];
            if (user.enumAuthType == GANENUM_USER_AUTHTYPE_EMAIL && user.enumType != GANENUM_USER_TYPE_ONBOARDING_WORKER){
                // Old user, migration needed
                [GANGlobalVCManager hideHudProgressWithCallback:^{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
                    GANLoginResetPasswordVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_LOGIN_RESETPASSWORD"];
                    vc.szUsername = user.szUserName;
                    [self.navigationController pushViewController:vc animated:YES];
                    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                }];
                GANACTIVITY_REPORT(@"Worker - Login phone number recognized (v1.2)");
            }
            else {
                [GANGlobalVCManager hideHudProgressWithCallback:^{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
                    GANWorkerLoginCodeVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_CODE"];
                    vc.szPhoneNumber = phoneNumber;
                    vc.isAutoLogin = NO;
                    if(user.enumType == GANENUM_USER_TYPE_ONBOARDING_WORKER) {
                        vc.isOnboardingWorker = YES;
                        vc.isLogin = NO;
                        vc.szId = user.szId;
                    } else {
                        vc.isOnboardingWorker = NO;
                        vc.isLogin = YES;
                    }
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                }];
                GANACTIVITY_REPORT(@"Worker - Login phone number recognized");
            }
        }
        else if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
                GANWorkerLoginCodeVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_CODE"];
                vc.szPhoneNumber = phoneNumber;
                vc.isLogin = NO;
                vc.isAutoLogin = NO;
                [self.navigationController pushViewController:vc animated:YES];
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            }];
            GANACTIVITY_REPORT(@"Worker - Login phone number not recognized. Go to signup");
        }
        else {
            // Sorry, we've encountered an issue.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:-1 Callback:nil];
        }
    }];
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonContinueClick:(id)sender {
    [self.view endEditing:YES];
    [self doLogin];
}

- (IBAction)onButtonBackClick:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onTextfieldPhoneChanged:(id)sender {
    NSString *szPhoneNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldPhoneNumber.text];
    if (szPhoneNumber.length > 10){
        szPhoneNumber = [szPhoneNumber substringToIndex:10];
    }
    self.textfieldPhoneNumber.text = szPhoneNumber;
    [self refreshPhonePanel];
}

@end
