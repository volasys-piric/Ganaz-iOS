//
//  GANCompanyCodePopupVC.m
//  Ganaz
//
//  Created by Piric Djordje on 5/25/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyCodePopupVC.h"
#import "GANCacheManager.h"
#import "Global.h"
#import "GANGlobalVCManager.h"
#import <UIView+Shake.h>

@interface GANCompanyCodePopupVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UITextField *txtCode;
@property (weak, nonatomic) IBOutlet UIView *viewCode;

@end

@implementation GANCompanyCodePopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.viewContent.clipsToBounds = YES;
    self.viewContent.layer.cornerRadius = 3;
    self.viewCode.clipsToBounds = YES;
    self.viewCode.layer.cornerRadius = 3;
}

- (void) refreshFields{
    if (self.indexCompany == -1){
        self.txtCode.text = @"";
    }
    else {
        GANCompanyDataModel *company = [[GANCacheManager sharedInstance].arrayCompanies objectAtIndex:self.indexCompany];
        self.txtCode.text = company.szCode;
    }
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void) shakeInvalidFields: (UIView *) viewContainer{
    [viewContainer shake:6 withDelta:8 speed:0.07];
}


#pragma mark - Biz Logic

- (BOOL) checkMandatoryFields{
    NSString *code = self.txtCode.text;
    if (code.length == 0){
        [self shakeInvalidFields:self.viewCode];
        return NO;
    }
    return YES;
}

- (void) verifyCode{
    if ([self checkMandatoryFields] == NO) return;
    
    NSString *code = [self.txtCode.text lowercaseString];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANCacheManager sharedInstance] requestGetCompanyDetailsByCompanyCode:code Callback:^(int indexCompany) {
        if (indexCompany == -1){
            [GANGlobalVCManager showHudErrorWithMessage:@"No company found!" DismissAfter:-1 Callback:nil];
        }
        else {
            [GANGlobalVCManager hideHudProgress];
            self.indexCompany = indexCompany;
            if (self.delegate){
                [self.delegate didCompanyCodeVerify:indexCompany];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self closeDialog];
            });
        }
    }];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self onBtnVerifyClick:textField];
    return YES;
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onBtnVerifyClick:(id)sender {
    [self.view endEditing:YES];
    [self verifyCode];
}

- (IBAction)onBtnCancelClick:(id)sender {
    [self.view endEditing:YES];
    if (self.delegate){
        [self.delegate didCompanyCodeVerify:-1];
    }
    [self closeDialog];
}

@end
