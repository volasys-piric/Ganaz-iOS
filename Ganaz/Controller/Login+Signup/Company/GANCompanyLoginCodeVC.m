//
//  GANCompanyLoginCodeVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/11/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyLoginCodeVC.h"
#import "GANUserManager.h"
#import "GANMainChooseVC.h"
#import "GANCompanyLoginPhoneVC.h"
#import "GANJobHomeVC.h"
#import "GANJobsDetailsVC.h"
#import "GANCompanySignupVC.h"
#import "GANComposeMessageOnboardingVC.h"

#import "GANGenericFunctionManager.h"
#import "GANGlobalVCManager.h"
#import "GANAppManager.h"
#import "Global.h"

@interface GANCompanyLoginCodeVC () <UITextFieldDelegate>

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

@end

@implementation GANCompanyLoginCodeVC

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
    if ([self checkMandatoryFields] == NO){
        return;
    }
    
    NSString *szCode = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldCode.text];
    GANUserManager *managerUser = [GANUserManager sharedInstance];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerUser requestUserLoginWithPhoneNumber:[self.phone getNormalizedPhoneNumber] Password:szCode Callback:^(int status) {
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
            [GANGlobalVCManager showHudErrorWithMessage:@"Login information incorrect. Please try again." DismissAfter:-1 Callback:nil];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) gotoCompanyMain{
    
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

- (void) gotoWorkerMain{
    NSMutableArray *arrNewVCs = [[NSMutableArray alloc] init];
    NSArray *arrVCs = self.navigationController.viewControllers;
    // ChooseVC, LoginPhoneVC, LoginCodeVC
    for (int i = 0; i < (int)([arrVCs count]); i++){
        UIViewController *vc = [arrVCs objectAtIndex:i];
        if (([vc isKindOfClass:[GANMainChooseVC class]] == NO) &&
            ([vc isKindOfClass:[GANCompanyLoginPhoneVC class]] == NO) &&
            ([vc isKindOfClass:[GANCompanyLoginCodeVC class]] == NO)){
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

- (IBAction)onTextfieldCodeChanged:(id)sender {
    NSString *szCode = [GANGenericFunctionManager stripNonnumericsFromNSString:self.textfieldCode.text];
    if (szCode.length > 4){
        szCode = [szCode substringToIndex:4];
    }
    self.textfieldCode.text = szCode;
    [self refreshCodePanel];
}

@end
