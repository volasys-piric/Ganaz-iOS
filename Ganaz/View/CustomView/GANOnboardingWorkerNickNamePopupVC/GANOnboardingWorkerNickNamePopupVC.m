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
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIView *viewTextField;

@end

@implementation GANOnboardingWorkerNickNamePopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.txtNickName.delegate = self;
    
    [self refreshViews];
}

- (void) refreshViews{
    self.viewContents.clipsToBounds         = YES;
    self.viewContents.layer.cornerRadius    = 3;
    self.viewContents.layer.borderWidth     = 1;
    self.viewContents.layer.borderColor     = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    self.viewTextField.layer.cornerRadius = 3;
    
    self.btnDone.clipsToBounds        = YES;
    self.btnDone.layer.cornerRadius   = 3;
    self.btnCancel.clipsToBounds      = YES;
    self.btnCancel.layer.cornerRadius = 3;
    self.btnCancel.layer.borderColor  = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    self.btnCancel.layer.borderWidth  = 1;
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void) setTitle:(NSString*) phoneNumber {
    self.lblTitle.text = [NSString stringWithFormat:@"Edit worker\n%@", phoneNumber];
}

- (IBAction)onBtnWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onSetMyWorkNickName:(id)sender {
    
    NSString *szNickName = [GANGenericFunctionManager refineNSString:self.txtNickName.text];
    
    [self.view endEditing:YES];
    [self closeDialog];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(setOnboardingWorkerNickName:index:)]) {
        [self.delegate setOnboardingWorkerNickName:szNickName index:self.nIndex];
    }
}

- (IBAction)onCancel:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
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
