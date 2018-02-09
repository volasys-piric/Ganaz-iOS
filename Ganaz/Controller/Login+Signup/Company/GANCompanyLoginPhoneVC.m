//
//  GANCompanyLoginPhoneVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/11/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyLoginPhoneVC.h"
#import "GANCompanyLoginCodeVC.h"
#import "GANLoginResetPasswordVC.h"
#import "GANCompanySignupVC.h"
#import "GANCountrySelectorPopupVC.h"

#import "GANGenericFunctionManager.h"
#import "GANGlobalVCManager.h"
#import "GANUserManager.h"
#import "GANAppManager.h"
#import "Global.h"
#import "GANFadeTransitionDelegate.h"

@interface GANCompanyLoginPhoneVC () <UITextFieldDelegate, GANCountrySelectorPopupDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPhonePanel;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *buttonContinue;
@property (weak, nonatomic) IBOutlet UIImageView *imageCountry;

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

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;
@property (assign, atomic) GANENUM_PHONE_COUNTRY enumCountry;

@end

@implementation GANCompanyLoginPhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.enumCountry = GANENUM_PHONE_COUNTRY_US;
    [self refreshViews];
    [self refreshPhonePanel];
    [self.textfieldPhoneNumber becomeFirstResponder];
    
    self.transController = [[GANFadeTransitionDelegate alloc] init];
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
    
    [self refreshCountryFlag];
}

- (void) refreshCountryFlag{
    if (self.enumCountry == GANENUM_PHONE_COUNTRY_US) {
        [self.imageCountry setImage:[UIImage imageNamed:@"flag-us"]];
    }
    else if (self.enumCountry == GANENUM_PHONE_COUNTRY_MX) {
        [self.imageCountry setImage:[UIImage imageNamed:@"flag-mx"]];
    }
}

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

#pragma mark - Biz Logic

- (void) showDlgForCountry{
    GANCountrySelectorPopupVC *vc = [[GANCountrySelectorPopupVC alloc] initWithNibName:@"CountrySelectorPopupVC" bundle:nil];
    
    vc.enumCountry = self.enumCountry;
    vc.delegate = self;
    vc.view.backgroundColor = [UIColor clearColor];
    [vc refreshFields];
    
    [vc setTransitioningDelegate:self.transController];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
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
    GANPhoneDataModel *phone = [[GANPhoneDataModel alloc] initWithCountry:self.enumCountry LocalNumber:phoneNumber];
    
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    
    // Check if user exists
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerUser requestSearchUserByPhone:phone Type:GANENUM_USER_TYPE_ANY Callback:^(int status, NSArray *array) {
        if (status == SUCCESS_WITH_NO_ERROR && array != nil && [array count] > 0){
            GANUserBaseDataModel *user = [array objectAtIndex:0];
            if (user.enumAuthType == GANENUM_USER_AUTHTYPE_EMAIL){
                // Old user, migration needed
                [GANGlobalVCManager hideHudProgressWithCallback:^{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
                    GANLoginResetPasswordVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_LOGIN_RESETPASSWORD"];
                    vc.szUsername = user.szUserName;
                    [self.navigationController pushViewController:vc animated:YES];
                    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                }];
                GANACTIVITY_REPORT(@"Company - Login phone number recognized (v1.2)");
            }
            else {
                [GANGlobalVCManager hideHudProgressWithCallback:^{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
                    GANCompanyLoginCodeVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_LOGIN_CODE"];
                    vc.phone = phone;
                    vc.fromCustomVC = self.fromCustomVC;
                    [self.navigationController pushViewController:vc animated:YES];
                    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                }];
                GANACTIVITY_REPORT(@"Company - Login phone number recognized");
            }
        }
        else if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                [self gotoSignupVC];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) gotoSignupVC{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray *arrVCs = self.navigationController.viewControllers;
        for (int i = 0; i < (int)([arrVCs count]); i++){
            UIViewController *vc = [arrVCs objectAtIndex:i];
            if ([vc isKindOfClass:[GANCompanySignupVC class]] == YES){
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
        
        NSString *phoneNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldPhoneNumber.text];
        GANPhoneDataModel *phone = [[GANPhoneDataModel alloc] initWithCountry:self.enumCountry LocalNumber:phoneNumber];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        GANCompanySignupVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SIGNUP"];
        vc.phone = phone;
        vc.fromCustomVC = self.fromCustomVC;
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
    GANACTIVITY_REPORT(@"Company - Login phone number not recognized. Go to signup");
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonContinueClick:(id)sender {
    [self.view endEditing:YES];
    [self doLogin];
}

- (IBAction)onButtonCountryClick:(id)sender {
    [self showDlgForCountry];
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

#pragma mark - GANCountrySelectorPopup Delegate

- (void) didCountrySelect:(GANENUM_PHONE_COUNTRY)country {
    self.enumCountry = country;
    [self refreshCountryFlag];
}

@end
