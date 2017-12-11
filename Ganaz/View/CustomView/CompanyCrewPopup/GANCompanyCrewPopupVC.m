//
//  GANCompanyCrewPopupVC.m
//  Ganaz
//
//  Created by Chris Lin on 11/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyCrewPopupVC.h"
#import "GANCompanyManager.h"

#import "Global.h"
#import "GANGlobalVCManager.h"
#import "UIView+Shake.h"

@interface GANCompanyCrewPopupVC ()

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIView *viewName;
@property (weak, nonatomic) IBOutlet UITextField *textfieldName;
@property (weak, nonatomic) IBOutlet UIButton *buttonCreate;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;

@end

@implementation GANCompanyCrewPopupVC

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
    self.viewContent.layer.cornerRadius = 6;
    self.viewContent.layer.borderWidth = 1;
    self.viewContent.layer.borderColor = GANUICOLOR_THEMECOLOR_MAIN.CGColor;

    self.viewName.clipsToBounds = YES;
    self.viewName.layer.cornerRadius = 3;
    
    self.buttonCancel.clipsToBounds = YES;
    self.buttonCancel.layer.cornerRadius = 3;
    self.buttonCancel.layer.borderColor  = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    self.buttonCancel.layer.borderWidth  = 1;

    self.buttonCreate.clipsToBounds = YES;
    self.buttonCreate.layer.cornerRadius = 3;
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
    NSString *name = self.textfieldName.text;
    if (name.length == 0){
        [self shakeInvalidFields:self.viewName];
        return NO;
    }
    
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    for (GANCrewDataModel *crew in managerCompany.arrayCrews) {
        if ([crew.szTitle caseInsensitiveCompare:name] == NSOrderedSame) {
            [GANGlobalVCManager showHudErrorWithMessage:@"You have a group with same name already." DismissAfter:-1 Callback:nil];
            [self shakeInvalidFields:self.viewName];
            return NO;
        }
    }
    
    return YES;
}

- (void) doCreateCrew {
    if ([self checkMandatoryFields] == NO) return;
    
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    NSString *name = self.textfieldName.text;
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [managerCompany requestAddCrewWithTitle:name Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"New group is created successfully." DismissAfter:-1 Callback:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(companyCrewPopupDidCrewCreate:)]){
                    [self.delegate companyCrewPopupDidCrewCreate:(int) [managerCompany.arrayCrews count] - 1];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self closeDialog];
                });
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
    }];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self onButtonCreateClick:textField];
    return YES;
}

#pragma mark - UIButton Delegate

- (IBAction)onButtonWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onButtonCreateClick:(id)sender {
    [self.view endEditing:YES];
    [self doCreateCrew];
}

- (IBAction)onButtonCancelClick:(id)sender {
    [self.view endEditing:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(companyCrewPopupCanceled)]){
        [self.delegate companyCrewPopupCanceled];
    }
    [self closeDialog];
}

@end
