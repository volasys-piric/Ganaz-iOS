//
//  GANOnboardingWorkerNickNamePopupVC.m
//  Ganaz
//
//  Created by forever on 9/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANOnboardingWorkerNickNamePopupVC.h"
#import "Global.h"
#import "GANGenericFunctionManager.h"

@interface GANOnboardingWorkerNickNamePopupVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonDone;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;
@property (weak, nonatomic) IBOutlet UIView *viewTextField;

@end

@implementation GANOnboardingWorkerNickNamePopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.textfieldNickname.delegate = self;
    
    [self refreshViews];
}

- (void) refreshViews{
    self.viewContents.clipsToBounds         = YES;
    self.viewContents.layer.cornerRadius    = 3;
    self.viewContents.layer.borderWidth     = 1;
    self.viewContents.layer.borderColor     = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    self.viewTextField.layer.cornerRadius = 3;
    
    self.buttonDone.clipsToBounds        = YES;
    self.buttonDone.layer.cornerRadius   = 3;
    self.buttonCancel.clipsToBounds      = YES;
    self.buttonCancel.layer.cornerRadius = 3;
    self.buttonCancel.layer.borderColor  = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    self.buttonCancel.layer.borderWidth  = 1;
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void) setTitle:(NSString*) phoneNumber {
    self.labelTitle.text = [NSString stringWithFormat:@"Edit worker\n%@", phoneNumber];
}

- (IBAction)onButtonWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onButtonDoneClick:(id)sender {
    NSString *szNickName = [GANGenericFunctionManager refineNSString:self.textfieldNickname.text];
    
    [self.view endEditing:YES];
    [self closeDialog];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onboardingNicknameEditPopupDidUpdateWithNickname:)]) {
        [self.delegate onboardingNicknameEditPopupDidUpdateWithNickname:szNickName];
    }
}

- (IBAction)onButtonCancelClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];

    if(self.delegate && [self.delegate respondsToSelector:@selector(onboardingNicknameEditPopupDidCancel)]) {
        [self.delegate onboardingNicknameEditPopupDidCancel];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
