//
//  GANWorkerLoginPhoneVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerLoginPhoneVC.h"
#import "GANUserManager.h"
#import "GANWorkerLoginCodeVC.h"
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
    
    [self refreshViews];
    [self refreshPhonePanel];
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
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerUser requestSearchUserByPhoneNumber:phoneNumber Type:GANENUM_USER_TYPE_ANY Callback:^(int status, NSArray *array) {
        if (status == SUCCESS_WITH_NO_ERROR && array != nil && [array count] > 0){
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                /*
                NSDictionary *dictAccount = [array objectAtIndex:0];
                NSString *szUserType = [GANGenericFunctionManager refineNSString: [dictAccount objectForKey:@"type"]];
                GANENUM_USER_TYPE enumUserType = [GANUtils getUserTypeFromString:szUserType];
                if (enumUserType == GANENUM_USER_TYPE_WORKER){
                }
                else {
                }
                */
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
                GANWorkerLoginCodeVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_CODE"];
                vc.szPhoneNumber = phoneNumber;
                vc.isLogin = YES;
                vc.isAutoLogin = NO;
                [self.navigationController pushViewController:vc animated:YES];
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            }];
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
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
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
