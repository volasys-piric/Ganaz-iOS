//
//  GANSignupCompanyVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANSignupCompanyVC.h"

#import "GANUserManager.h"
#import "GANCompanyManager.h"
#import "GANMembershipPlanManager.h"

#import "GANAppManager.h"

#import "GANUIPhoneTextField.h"
#import "GANGenericFunctionManager.h"
#import "GANGlobalVCManager.h"

#import "GANLoginVC.h"
#import "GANSignupChooseVC.h"
#import "GANSignupWorkerVC.h"
#import "GANPushNotificationManager.h"

#import "Global.h"
#import <UIView+Shake/UIView+Shake.h>

@interface GANSignupCompanyVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewCompanyName;
@property (weak, nonatomic) IBOutlet UIView *viewDescription;
@property (weak, nonatomic) IBOutlet UIView *viewStreet1;
@property (weak, nonatomic) IBOutlet UIView *viewStreet2;
@property (weak, nonatomic) IBOutlet UIView *viewCity;
@property (weak, nonatomic) IBOutlet UIView *viewState;
@property (weak, nonatomic) IBOutlet UIView *viewFirstName;
@property (weak, nonatomic) IBOutlet UIView *viewLastName;
@property (weak, nonatomic) IBOutlet UIView *viewEmail;
@property (weak, nonatomic) IBOutlet UIView *viewPhone;
@property (weak, nonatomic) IBOutlet UIView *viewPassword;
@property (weak, nonatomic) IBOutlet UIView *viewConfirmPassword;
@property (weak, nonatomic) IBOutlet UIView *viewCompanyId;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnAutoTranslate;

@property (weak, nonatomic) IBOutlet UITextField *txtCompanyName;
@property (weak, nonatomic) IBOutlet UITextView *textviewDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtStreet1;
@property (weak, nonatomic) IBOutlet UITextField *txtStreet2;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtState;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet GANUIPhoneTextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtCompanyId;

@property (assign, atomic) BOOL isAutoTranslate;

@end

@implementation GANSignupCompanyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isAutoTranslate = NO;
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
    self.viewCompanyName.layer.cornerRadius = 3;
    self.viewDescription.layer.cornerRadius = 3;
    self.viewStreet1.layer.cornerRadius = 3;
    self.viewStreet2.layer.cornerRadius = 3;
    self.viewCity.layer.cornerRadius = 3;
    self.viewState.layer.cornerRadius = 3;
    self.viewFirstName.layer.cornerRadius = 3;
    self.viewLastName.layer.cornerRadius = 3;
    self.viewEmail.layer.cornerRadius = 3;
    self.viewPhone.layer.cornerRadius = 3;
    self.viewPassword.layer.cornerRadius = 3;
    self.viewConfirmPassword.layer.cornerRadius = 3;
    self.viewCompanyId.layer.cornerRadius = 3;
    
    self.btnSignup.layer.cornerRadius = 3;
    self.btnLogin.layer.cornerRadius = 3;
    self.btnLogin.layer.borderWidth = 1;
    self.btnLogin.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
    
    [self refreshAutoTranslateView];
}

- (void) refreshAutoTranslateView{
    if (self.isAutoTranslate == YES){
        [self.btnAutoTranslate setImage:[UIImage imageNamed:@"icon-checked"] forState:UIControlStateNormal];
    }
    else {
        [self.btnAutoTranslate setImage:[UIImage imageNamed:@"icon-unchecked"] forState:UIControlStateNormal];
    }
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
    NSString *szCompanyName = self.txtCompanyName.text;
    NSString *szDescription = self.textviewDescription.text;
    NSString *szStreet1 = self.txtStreet1.text;
    NSString *szCity = self.txtCity.text;
    NSString *szState = self.txtState.text;
    NSString *szFirstName = self.txtFirstName.text;
    NSString *szLastName = self.txtLastName.text;
    NSString *szEmail = self.txtEmail.text;
    NSString *szPhone = self.txtPhone.text;
    NSString *szCompanyId = self.txtCompanyId.text;
    NSString *szPassword = self.txtPassword.text;
    NSString *szConfirmPassword = self.txtConfirmPassword.text;
    
    if (szCompanyName.length == 0){
        [self shakeInvalidFields:self.viewCompanyName];
        return NO;
    }
    if (szDescription.length == 0){
        [self shakeInvalidFields:self.viewDescription];
        return NO;
    }
    if (szStreet1.length == 0){
        [self shakeInvalidFields:self.viewStreet1];
        return NO;
    }
    if (szCity.length == 0){
        [self shakeInvalidFields:self.viewCity];
        return NO;
    }
    if (szState.length == 0){
        [self shakeInvalidFields:self.viewState];
        return NO;
    }
    if (szFirstName.length == 0){
        [self shakeInvalidFields:self.viewFirstName];
        return NO;
    }
    if (szLastName.length == 0){
        [self shakeInvalidFields:self.viewLastName];
        return NO;
    }
    if (szEmail.length == 0){
        [self shakeInvalidFields:self.viewEmail];
        return NO;
    }
    if (szPhone.length == 0){
        [self shakeInvalidFields:self.viewPhone];
        return NO;
    }
    if (szCompanyId.length == 0 || [GANGenericFunctionManager isValidUsername:szCompanyId] == NO){
        [self shakeInvalidFields:self.viewCompanyId];
        return NO;
    }
    if (szPassword.length == 0) {
        [self shakeInvalidFields:self.viewPassword];
        return NO;
    }
    if (szConfirmPassword.length == 0 || [szConfirmPassword isEqualToString:szPassword] == NO) {
        [self shakeInvalidFields:self.viewConfirmPassword];
        return NO;
    }
    return YES;
}

- (void) prepareSignup{
    if ([self checkMandatoryFields] == NO) return;
    NSString *szBusinessName = self.txtCompanyName.text;
    NSString *szDescription = self.textviewDescription.text;
    __block NSString *szBusinessNameTranslated = szBusinessName;
    __block NSString *szDescriptionTranslated = szDescription;
    BOOL shouldTranslate = self.isAutoTranslate;
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    __weak typeof(self) wSelf = self;
    
    [GANUtils requestTranslate:szDescription Translate:shouldTranslate Callback:^(int status, NSString *translatedText) {
        if (status == SUCCESS_WITH_NO_ERROR) szDescriptionTranslated = translatedText;
        [GANUtils requestTranslate:szBusinessName Translate:shouldTranslate Callback:^(int status, NSString *translatedText) {
            __strong typeof(self) sSelf = wSelf;
            if (status == SUCCESS_WITH_NO_ERROR) szBusinessNameTranslated = translatedText;
            [sSelf doSignupWithTranslatedBusinessName:szBusinessNameTranslated DescriptionTranslated:szDescriptionTranslated];
        }];
        
    }];
}

- (void) doSignupWithTranslatedBusinessName: (NSString *) businessNameTranslated DescriptionTranslated: (NSString *) descriptionTranslated{
    if ([self checkMandatoryFields] == NO){
        return;
    }
    
    NSString *szFirstName = self.txtFirstName.text;
    NSString *szLastName = self.txtLastName.text;
    NSString *szEmail = self.txtEmail.text;
    NSString *szPhone = self.txtPhone.text;
    NSString *szCompanyId = self.txtCompanyId.text;
    NSString *szPassword = self.txtPassword.text;
    
    [self doCreateCompany:businessNameTranslated DescriptionTranslated:descriptionTranslated Callback:^(int status, GANCompanyDataModel *companyNew) {
        if (status == SUCCESS_WITH_NO_ERROR){
            GANUserManager *managerUser = [GANUserManager sharedInstance];
            [managerUser initializeManagerWithType:GANENUM_USER_TYPE_COMPANY_ADMIN];
            
            GANUserCompanyDataModel *modelCompanyUser = [GANUserManager getUserCompanyDataModel];
            modelCompanyUser.modelCompany = companyNew;
            modelCompanyUser.szCompanyId = companyNew.szId;
            
            modelCompanyUser.szFirstName = szFirstName;
            modelCompanyUser.szLastName = szLastName;
            modelCompanyUser.szEmail = szEmail;
            modelCompanyUser.modelPhone.szLocalNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:szPhone];
            modelCompanyUser.szUserName = szCompanyId;
            modelCompanyUser.szPassword = szPassword;
            modelCompanyUser.szPlayerId = [GANPushNotificationManager sharedInstance].szOneSignalPlayerId;
            
            [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
            [[GANUserManager sharedInstance] requestUserSignupWithCallback:^(int status) {
                if (status == SUCCESS_WITH_NO_ERROR){
                    [GANGlobalVCManager hideHudProgressWithCallback:^{
                        [self gotoCompanyMain];
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
    }];
}

- (void) doCreateCompany: (NSString *) nameTranslated DescriptionTranslated: (NSString *) descriptionTranslated Callback: (void (^) (int status, GANCompanyDataModel *companyNew)) callback{
    
    NSString *szCompanyName = self.txtCompanyName.text;
    NSString *szDescription = self.textviewDescription.text;
    NSString *szStreet1 = self.txtStreet1.text;
    NSString *szStreet2 = self.txtStreet2.text;
    NSString *szCity = self.txtCity.text;
    NSString *szState = self.txtState.text;
    
    GANCompanyDataModel *company = [[GANCompanyDataModel alloc] init];
    GANMembershipPlanDataModel *plan = [[GANMembershipPlanManager sharedInstance] getPlanByType:GANENUM_MEMBERSHIPPLAN_TYPE_FREE];
    
    company.modelName.szTextEN = szCompanyName;
    company.modelName.szTextES = nameTranslated;
    company.modelDescription.szTextEN = szDescription;
    company.modelDescription.szTextES = descriptionTranslated;
    company.isAutoTranslate = self.isAutoTranslate;
    company.szCode = [GANCompanyManager generateCompanyCodeFromName:szCompanyName];
    company.modelAddress.szAddress1 = szStreet1;
    company.modelAddress.szAddress2 = szStreet2;
    company.modelAddress.szCity = szCity;
    company.modelAddress.szState = szState;
    
    company.modelPlan.type = plan.type;
    company.modelPlan.szTitle = plan.szTitle;
    company.modelPlan.fFee = plan.fFee;
    company.modelPlan.nJobs = plan.nJobs;
    company.modelPlan.nRecruits = plan.nRecruits;
    company.modelPlan.nMessages = plan.nMessages;
    company.modelPlan.dateStart = [NSDate date];
    company.modelPlan.dateEnd = [NSDate date];
    company.modelPlan.isAutoRenewal = NO;
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    [managerCompany requestCreateCompany:company Callback:^(int status, GANCompanyDataModel *companyNew) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                if (callback){
                    callback(status, companyNew);
                }
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Unknown Error." DismissAfter:3 Callback:^{
                if (callback){
                    callback(status, nil);
                }
            }];
        }
    }];
}

- (void) gotoCompanyMain{
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    UINavigationController *nav = self.navigationController;
    [self presentViewController:vc animated:YES completion:^{
        [self.navigationController setViewControllers:@[[nav.viewControllers objectAtIndex:0]]];
    }];
    */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    UITabBarController *tbc = [storyboard instantiateInitialViewController];
    [self.navigationController setViewControllers:@[tbc] animated:YES];
    
    [[GANAppManager sharedInstance] initializeManagersAfterLogin];
}

- (void) gotoLogin{
    [[GANGlobalVCManager sharedInstance] gotoLoginVC];
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

- (IBAction)onBtnSignupClick:(id)sender {
    [self.view endEditing:YES];
    [self prepareSignup];
}

- (IBAction)onBtnLoginClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoLogin];
}

- (IBAction)onBtnTranslateClick:(id)sender {
    [self.view endEditing:YES];
    self.isAutoTranslate = !self.isAutoTranslate;
    [self refreshAutoTranslateView];
}

@end
