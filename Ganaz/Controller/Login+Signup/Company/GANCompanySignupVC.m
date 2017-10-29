//
//  GANCompanySignupVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/11/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySignupVC.h"
#import "GANCompanyManager.h"
#import "GANCacheManager.h"
#import "GANMembershipPlanManager.h"

#import "GANAppManager.h"

#import "GANUIPhoneTextField.h"
#import "GANGenericFunctionManager.h"
#import "GANGlobalVCManager.h"

#import "GANPushNotificationManager.h"
#import "GANFadeTransitionDelegate.h"

#import <UIView+Shake/UIView+Shake.h>

#import "GANJobsDetailsVC.h"
#import "GANComposeMessageOnboardingVC.h"
#import "GANCompanyLoginPhoneVC.h"
#import "GANCompanyCodePopupVC.h"
#import "GANMainChooseVC.h"
#import "GANCompanyLoginCodeVC.h"
#import "GANCompanyLoginPhoneVC.h"
#import "GANJobHomeVC.h"

@interface GANCompanySignupVC () <UITextFieldDelegate, GANCompanyCodePopupDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewCompanyName;
@property (weak, nonatomic) IBOutlet UIView *viewDescription;
@property (weak, nonatomic) IBOutlet UIView *viewZipcode;
@property (weak, nonatomic) IBOutlet UIView *viewFirstName;
@property (weak, nonatomic) IBOutlet UIView *viewLastName;
@property (weak, nonatomic) IBOutlet UIView *viewEmail;
@property (weak, nonatomic) IBOutlet UIView *viewPhone;
@property (weak, nonatomic) IBOutlet UIView *viewCodePanel;
@property (weak, nonatomic) IBOutlet UIView *viewCode0;
@property (weak, nonatomic) IBOutlet UIView *viewCode1;
@property (weak, nonatomic) IBOutlet UIView *viewCode2;
@property (weak, nonatomic) IBOutlet UIView *viewCode3;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnAutoTranslate;
@property (weak, nonatomic) IBOutlet UIButton *btnCompanyCode;

@property (weak, nonatomic) IBOutlet UITextField *txtCompanyName;
@property (weak, nonatomic) IBOutlet UITextView *textviewDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtZipcode;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet GANUIPhoneTextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtCode;

@property (weak, nonatomic) IBOutlet UILabel *labelCode0;
@property (weak, nonatomic) IBOutlet UILabel *labelCode1;
@property (weak, nonatomic) IBOutlet UILabel *labelCode2;
@property (weak, nonatomic) IBOutlet UILabel *labelCode3;

@property (assign, atomic) BOOL isAutoTranslate;
@property (assign, atomic) int indexCompany;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@end

@implementation GANCompanySignupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isAutoTranslate = NO;
    self.indexCompany = -1;
    
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    
    [self refreshViews];
    [self refreshCodePanel];
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
    self.viewZipcode.layer.cornerRadius = 3;
    self.viewFirstName.layer.cornerRadius = 3;
    self.viewLastName.layer.cornerRadius = 3;
    self.viewEmail.layer.cornerRadius = 3;
    self.viewPhone.layer.cornerRadius = 3;
    
    self.btnSignup.layer.cornerRadius = 3;
    self.btnLogin.layer.cornerRadius = 3;
    self.btnCompanyCode.layer.cornerRadius = 3;
    self.btnCompanyCode.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.btnCompanyCode.titleLabel.textAlignment    = NSTextAlignmentCenter;
    self.btnCompanyCode.titleLabel.numberOfLines = 2;
    self.btnLogin.layer.borderWidth = 1;
    self.btnLogin.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
    
    self.viewCode0.clipsToBounds = YES;
    self.viewCode0.layer.cornerRadius = 3;
    self.viewCode1.clipsToBounds = YES;
    self.viewCode1.layer.cornerRadius = 3;
    self.viewCode2.clipsToBounds = YES;
    self.viewCode2.layer.cornerRadius = 3;
    self.viewCode3.clipsToBounds = YES;
    self.viewCode3.layer.cornerRadius = 3;
    
    self.txtCode.tintColor = [UIColor clearColor];
    
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
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void) refreshCompanyFields{
    if (self.indexCompany == -1){
        self.txtCompanyName.text = @"";
        self.textviewDescription.text = @"";
        self.txtZipcode.text = @"";
        self.isAutoTranslate = NO;
        
        [self refreshAutoTranslateView];
        [self.textviewDescription setEditable:YES];
    }
    else {
        GANCompanyDataModel *company = [[GANCacheManager sharedInstance].arrayCompanies objectAtIndex:self.indexCompany];
        self.txtCompanyName.text = [company getBusinessNameEN];
        self.textviewDescription.text = [company getDescriptionEN];
        self.txtZipcode.text = company.modelAddress.szZipcode;
        
        self.isAutoTranslate = company.isAutoTranslate;
        [self refreshAutoTranslateView];
        [self.textviewDescription setEditable:NO];
    }
}

- (BOOL) isCompanyFieldEditable{
    return (self.indexCompany == -1);
}

- (void) refreshCodePanel{
    NSString *szCode = [GANGenericFunctionManager stripNonnumericsFromNSString:self.txtCode.text];
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

#pragma mark - Biz Logic

- (void) showDlgForCompanyCodeVerify{
    GANCompanyCodePopupVC *vc = [[GANCompanyCodePopupVC alloc] initWithNibName:@"CompanyCodePopup" bundle:nil];
    
    vc.delegate = self;
    vc.indexCompany = self.indexCompany;
    vc.view.backgroundColor = [UIColor clearColor];
    [vc refreshFields];
    
    [vc setTransitioningDelegate:self.transController];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}

- (BOOL) checkMandatoryFields{
    NSString *szCompanyName = self.txtCompanyName.text;
    NSString *szDescription = self.textviewDescription.text;
    NSString *szFirstName = self.txtFirstName.text;
    NSString *szLastName = self.txtLastName.text;
    NSString *szEmail = self.txtEmail.text;
    NSString *szPhone = self.txtPhone.text;
    NSString *szPassword = self.txtCode.text;
    
    if (szCompanyName.length == 0){
        [self shakeInvalidFields:self.viewCompanyName];
        return NO;
    }
    if (szDescription.length == 0){
        [self shakeInvalidFields:self.viewDescription];
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
    if (szPassword.length == 0) {
        [self shakeInvalidFields:self.viewCodePanel];
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
    
    [GANUtils requestTranslate:szDescription Translate:shouldTranslate FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES Callback:^(int status, NSString *translatedText) {
        if (status == SUCCESS_WITH_NO_ERROR) szDescriptionTranslated = translatedText;
        [GANUtils requestTranslate:szBusinessName Translate:NO /*shouldTranslate*/ FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES Callback:^(int status, NSString *translatedText) {
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
    
    if (self.indexCompany == -1){
        [self doCreateCompany:businessNameTranslated DescriptionTranslated:descriptionTranslated Callback:^(int status, GANCompanyDataModel *companyNew) {
            if (status == SUCCESS_WITH_NO_ERROR){
                [self doCreateCompanyUserWithCompany:companyNew UserType:GANENUM_USER_TYPE_COMPANY_ADMIN];
            }
        }];
    }
    else {
        GANCompanyDataModel *company = [[GANCacheManager sharedInstance].arrayCompanies objectAtIndex:self.indexCompany];
        [self doCreateCompanyUserWithCompany:company UserType:GANENUM_USER_TYPE_COMPANY_REGULAR];
    }
}

- (void) doCreateCompany: (NSString *) nameTranslated DescriptionTranslated: (NSString *) descriptionTranslated Callback: (void (^) (int status, GANCompanyDataModel *companyNew)) callback{
    
    NSString *szCompanyName = self.txtCompanyName.text;
    NSString *szDescription = self.textviewDescription.text;
    NSString *szZipcode = self.txtZipcode.text;
    GANCompanyDataModel *company = [[GANCompanyDataModel alloc] init];
    GANMembershipPlanDataModel *plan = [[GANMembershipPlanManager sharedInstance] getPlanByType:GANENUM_MEMBERSHIPPLAN_TYPE_FREE];
    
    company.modelName.szTextEN = szCompanyName;
    company.modelName.szTextES = nameTranslated;
    company.modelDescription.szTextEN = szDescription;
    company.modelDescription.szTextES = descriptionTranslated;
    company.isAutoTranslate = self.isAutoTranslate;
    company.szCode = [GANCompanyManager generateCompanyCodeFromName:szCompanyName];
    
    company.modelAddress.szZipcode = szZipcode;
    
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
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:3 Callback:^{
                if (callback){
                    callback(status, nil);
                }
            }];
        }
    }];
}

- (void) doCreateCompanyUserWithCompany: (GANCompanyDataModel *) company UserType: (GANENUM_USER_TYPE) type{
    NSString *szFirstName = self.txtFirstName.text;
    NSString *szLastName = self.txtLastName.text;
    NSString *szEmail = self.txtEmail.text;
    NSString *szPhone = [GANGenericFunctionManager stripNonnumericsFromNSString:self.txtPhone.text];
    NSString *szCompanyUserId = szPhone;
    NSString *szPassword = self.txtCode.text;
    
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    [managerUser initializeManagerWithType:type];
    
    GANUserCompanyDataModel *modelCompanyUser = [GANUserManager getUserCompanyDataModel];
    modelCompanyUser.enumAuthType = GANENUM_USER_AUTHTYPE_PHONE;
    modelCompanyUser.modelCompany = company;
    modelCompanyUser.szCompanyId = company.szId;
    
    modelCompanyUser.szFirstName = szFirstName;
    modelCompanyUser.szLastName = szLastName;
    modelCompanyUser.szEmail = szEmail;
    modelCompanyUser.modelPhone.szLocalNumber = szPhone;
    modelCompanyUser.szUserName = szCompanyUserId;
    modelCompanyUser.szPassword = szPassword;
    [modelCompanyUser addPlayerIdIfNeeded:[GANPushNotificationManager sharedInstance].szOneSignalPlayerId];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANUserManager sharedInstance] requestUserSignupWithCallback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                [self gotoCompanyHome];
            }];
            GANACTIVITY_REPORT(@"User signed up");
        }
        else if (status == ERROR_USER_SIGNUPFAILED_PHONENUMBERCONFLICT){
            [GANGlobalVCManager showHudErrorWithMessage:@"Phone number already in use. Please choose a different one." DismissAfter:3 Callback:nil];
        }
        else if (status == ERROR_USER_SIGNUPFAILED_USERNAMECONFLICT){
            [GANGlobalVCManager showHudErrorWithMessage:@"User name is already registered" DismissAfter:3 Callback:nil];
        }
        else if (status == ERROR_USER_SIGNUPFAILED_EMAILCONFLICT){
            [GANGlobalVCManager showHudErrorWithMessage:@"Email address is already registered" DismissAfter:3 Callback:nil];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:3 Callback:nil];
        }
    }];
}

- (void) gotoCompanyHome{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    
    NSMutableArray *arrNewVCs = [[NSMutableArray alloc] init];
    NSArray *arrVCs = self.navigationController.viewControllers;
    
    for (int i = 0; i < (int)([arrVCs count]); i++){
        UIViewController *vc = [arrVCs objectAtIndex:i];
        if (([vc isKindOfClass:[GANMainChooseVC class]] == NO) &&
            ([vc isKindOfClass:[GANCompanyLoginPhoneVC class]] == NO) &&
            ([vc isKindOfClass:[GANCompanyLoginCodeVC class]] == NO) &&
            ([vc isKindOfClass:[GANCompanySignupVC class]] == NO)){
            [arrNewVCs addObject:vc];
        }
    }
    
    if(self.fromCustomVC == ENUM_DEFAULT_SIGNUP) {
        UIViewController *vc = [storyboard instantiateInitialViewController];
        UINavigationController *nav = self.navigationController;
        [self presentViewController:vc animated:YES completion:^{
            [self.navigationController setViewControllers:@[[nav.viewControllers objectAtIndex:0]]];
        }];
    } else {
        if(self.fromCustomVC == ENUM_JOBPOST_SIGNUP) {
            
            for (int i = 0; i < (int)([arrNewVCs count]); i++){
                UIViewController *vc = [arrNewVCs objectAtIndex:i];
                if ([vc isKindOfClass:[GANJobsDetailsVC class]] == YES){
                    ((GANJobsDetailsVC *)vc).bPostedNewJob = YES;
                }
            }
            UITabBarController *tbc = [storyboard instantiateInitialViewController];
            if ([arrNewVCs count] > 0){
                UINavigationController *nav = [tbc.viewControllers objectAtIndex:0];
                nav.viewControllers = arrNewVCs;
            }
            
            [self.navigationController presentViewController:tbc animated:YES completion:^{
                [self.navigationController setViewControllers:@[[self.navigationController.viewControllers objectAtIndex:0]]];
            }];
            
        } else if((self.fromCustomVC == ENUM_COMMUNICATE_SIGNUP) || (self.fromCustomVC == ENUM_RETAIN_SIGNUP)) {
            
            for (int i = 0; i < (int)([arrNewVCs count]); i++){
                UIViewController *vc = [arrNewVCs objectAtIndex:i];
                if ([vc isKindOfClass:[GANJobHomeVC class]] == YES){
                    [arrNewVCs removeObjectAtIndex:i];
                }
            }
            
            UIViewController *vcMessage = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGES_LIST"];
            [arrNewVCs insertObject:vcMessage atIndex:0];
            
            for (int i = 0; i < (int)([arrNewVCs count]); i++){
                UIViewController *vc = [arrNewVCs objectAtIndex:i];
                if ([vc isKindOfClass:[GANComposeMessageOnboardingVC class]] == YES){
                    ((GANComposeMessageOnboardingVC *)vc).isFromSignup = ENUM_COMMUNICATE_SIGNUP;
                }
            }
            
            UITabBarController *tbc = [storyboard instantiateInitialViewController];
            [tbc setSelectedIndex:2];
            if ([arrNewVCs count] > 0){
                UINavigationController *nav = [tbc.viewControllers objectAtIndex:2];
                nav.viewControllers = arrNewVCs;
            }
            
            [self.navigationController presentViewController:tbc animated:YES completion:^{
                [self.navigationController setViewControllers:@[[self.navigationController.viewControllers objectAtIndex:0]]];
            }];
        }
    }

    [[GANAppManager sharedInstance] initializeManagersAfterLogin];
}

- (void) gotoLogin{
    
    NSArray *arrVCs = self.navigationController.viewControllers;
    
    for (int i = 0; i < (int)([arrVCs count]); i++){
        UIViewController *vc = [arrVCs objectAtIndex:i];
        if ([vc isKindOfClass:[GANCompanyLoginPhoneVC class]] == YES){
            GANCompanyLoginPhoneVC *viewController = (GANCompanyLoginPhoneVC*)vc;
            viewController.fromCustomVC = self.fromCustomVC;
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
    GANCompanyLoginPhoneVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_LOGIN_PHONE"];
    vc.fromCustomVC = self.fromCustomVC;
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) gotoToS{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_LOGIN_TOS"];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.txtCompanyName ||
        textField == self.txtZipcode
        ){
        return [self isCompanyFieldEditable];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onTextfieldCodeChanged:(id)sender {
    NSString *szCode = [GANGenericFunctionManager stripNonnumericsFromNSString:self.txtCode.text];
    if (szCode.length > 4){
        szCode = [szCode substringToIndex:4];
    }
    self.txtCode.text = szCode;
    [self refreshCodePanel];
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
    if ([self isCompanyFieldEditable] == YES){
        self.isAutoTranslate = !self.isAutoTranslate;
        [self refreshAutoTranslateView];
    }
}

- (IBAction)onBtnCompanyCodeClick:(id)sender {
    [self.view endEditing:YES];
    [self showDlgForCompanyCodeVerify];
}

- (IBAction)onBtnToSClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoToS];
}

#pragma mark - GANCompanyCodePopupDelegate

- (void)didCompanyCodeVerify:(int)indexCompany{
    self.indexCompany = indexCompany;
    [self refreshCompanyFields];
}

@end
