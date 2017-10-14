//
//  GANMessageWithChargeConfirmationPopupVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/6/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMessageWithChargeConfirmationPopupVC.h"
#import "UIColor+GANColor.h"
#import "Global.h"

@interface GANMessageWithChargeConfirmationPopupVC ()

@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;
@property (weak, nonatomic) IBOutlet UIButton *buttonSend;

@end

@implementation GANMessageWithChargeConfirmationPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews {
    self.viewContents.clipsToBounds = YES;
    self.viewContents.layer.cornerRadius = 3;
    self.viewContents.layer.borderWidth = 1;
    self.viewContents.layer.borderColor = [UIColor GANThemeMainColor].CGColor;
    
    self.buttonCancel.layer.cornerRadius = 3;
    self.buttonCancel.clipsToBounds = YES;
    self.buttonCancel.layer.borderWidth = 1;
    self.buttonCancel.layer.borderColor = [UIColor GANThemeMainColor].CGColor;
    
    self.buttonSend.layer.cornerRadius = 3;
    self.buttonSend.clipsToBounds = YES;
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void) setDescriptionWithCount: (NSInteger) count{
    self.labelDescription.text = [NSString stringWithFormat:@"%d of your workers are not using Ganaz so this message will cost $%.02f to send", (int) count, count * 0.05];
}

- (IBAction)onButtonnWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onButtonSendClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageWithChargeConfirmationPopupDidSendClick:)] == YES){
        [self.delegate messageWithChargeConfirmationPopupDidSendClick:self];
    }

    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onButtonCancelClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageWithChargeConfirmationPopupDidCancelClick:)] == YES){
        [self.delegate messageWithChargeConfirmationPopupDidCancelClick:self];
    }

    [self.view endEditing:YES];
    [self closeDialog];
}

@end
