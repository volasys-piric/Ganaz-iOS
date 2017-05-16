//
//  GANLoginVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANLoginVC.h"

#import "GANUserManager.h"
#import "GANAppManager.h"

#import "GANGenericFunctionManager.h"
#import "GANGlobalVCManager.h"
#import "GANLocalstorageManager.h"

#import "Global.h"
#import <UIView+Shake/UIView+Shake.h>

@interface GANLoginVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewNavBar;
@property (weak, nonatomic) IBOutlet UIView *viewUsernamePanel;
@property (weak, nonatomic) IBOutlet UIView *viewPasswordPanel;

@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end

@implementation GANLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshViews];
    [self checkAutoLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.btnLogin.layer.cornerRadius = 3;
    if ([self.txtUsername respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.txtUsername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Identificación del usuario / User ID" attributes:@{NSForegroundColorAttributeName: GANUICOLOR_THEMECOLOR_PLACEHOLDER}];
        self.txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Contraseña / Password" attributes:@{NSForegroundColorAttributeName: GANUICOLOR_THEMECOLOR_PLACEHOLDER}];
    }
    
    if ([self.navigationController.viewControllers count] > 1){
        self.viewNavBar.hidden = NO;
    }
    else {
        self.viewNavBar.hidden = YES;
    }
}

- (void) checkAutoLogin{
    NSDictionary *dict = [GANLocalstorageManager loadGlobalObjectWithKey:LOCALSTORAGE_USER_LOGIN];
    if (dict == nil || ([dict isKindOfClass: [NSNull class]] == YES)) return;
    
    NSString *szUserName = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"username"]];
    NSString *szPassword = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"password"]];
    if (szUserName.length > 0 && szPassword.length > 0){
        self.txtUsername.text = szUserName;
        self.txtPassword.text = szPassword;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doLogin];
        });
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark -Biz Logic

- (BOOL) checkMandatoryFields{
    NSString *szUsername = self.txtUsername.text;
    if (szUsername.length == 0 || [GANGenericFunctionManager isValidUsername:szUsername] == NO){
        [self shakeInvalidFields:self.viewUsernamePanel];
        return NO;
    }
    if (self.txtPassword.text.length == 0){
        [self shakeInvalidFields:self.viewPasswordPanel];
        return NO;
    }
    return YES;
}

- (void) shakeInvalidFields: (UIView *) viewContainer{
    [viewContainer shake:6 withDelta:8 speed:0.07];
}

- (void) doLogin{
    if ([self checkMandatoryFields] == NO) return;
    
    NSString *szUsername = self.txtUsername.text;
    NSString *szPassword = self.txtPassword.text;
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [[GANUserManager sharedInstance] requestUserLogin:szUsername Password:szPassword Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                GANUserManager *managerUser = [GANUserManager sharedInstance];
                if ([managerUser isCompany] == YES){
                    [self gotoCompanyMain];
                }
                else {
                    [self gotoWorkerMain];
                }
            }];
        }
        else if (status == ERROR_USER_LOGINFAILED_USERNOTFOUND || status == ERROR_USER_LOGINFAILED_PASSWORDWRONG){
            [GANGlobalVCManager showHudErrorWithMessage:@"Login information is not correct." DismissAfter:3 Callback:nil];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Unknown Error." DismissAfter:3 Callback:nil];
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
    [arrNewVCs addObjectsFromArray:arrVCs];
    [arrNewVCs removeLastObject];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    UITabBarController *tbc = [storyboard instantiateInitialViewController];
    if ([arrNewVCs count] > 0){
        UINavigationController *nav = [tbc.viewControllers objectAtIndex:0];
        nav.viewControllers = arrNewVCs;
    }
    else {
        
    }
    [self.navigationController setViewControllers:@[tbc] animated:YES];
    
    [[GANAppManager sharedInstance] initializeManagersAfterLogin];
}

- (void) gotoSignupChooseVC{
    [self performSegueWithIdentifier:@"SEGUE_FROM_LOGIN_TO_SIGNUP_CHOOSE" sender:nil];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnSignupClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoSignupChooseVC];
}

- (IBAction)onBtnLoginClick:(id)sender {
    [self.view endEditing:YES];
    [self doLogin];
}

- (IBAction)onBtnBackClick:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
