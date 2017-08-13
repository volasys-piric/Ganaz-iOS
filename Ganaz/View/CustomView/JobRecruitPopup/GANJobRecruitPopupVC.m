//
//  GANJobRecruitPopupVC.m
//  Ganaz
//
//  Created by forever on 8/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobRecruitPopupVC.h"
#import "Global.h"

@interface GANJobRecruitPopupVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UIButton *btnRecruit;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@end

@implementation GANJobRecruitPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self refreshViews];
}

- (void) refreshViews{
    self.viewContents.clipsToBounds         = YES;
    self.viewContents.layer.cornerRadius    = 3;
    self.viewContents.layer.borderWidth     = 1;
    self.viewContents.layer.borderColor     = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    
    self.btnRecruit.clipsToBounds        = YES;
    self.btnRecruit.layer.cornerRadius   = 3;
    self.btnEdit.clipsToBounds        = YES;
    self.btnEdit.layer.cornerRadius   = 3;
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void) setRecruitButtonTitle:(NSString*)strTitle {
    [self.btnRecruit setTitle:strTitle forState:UIControlStateNormal];
}

- (void) setEditButtonTitle:(NSString*)strTitle {
    [self.btnEdit setTitle:strTitle forState:UIControlStateNormal];
}

- (void) setDescriptionTitle:(NSString*)strDescription {
    self.lblDescription.text = strDescription;
}

- (IBAction)onBtnWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onRecruit:(id)sender {
    [self closeDialog];
    if(self.delegate && [self.delegate respondsToSelector:@selector(didRecruit)]) {
        [self.delegate didRecruit];
    }
}

- (IBAction)onEdit:(id)sender {
    [self closeDialog];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didRecruit)]) {
        [self.delegate didEdit];
    }
}

@end
