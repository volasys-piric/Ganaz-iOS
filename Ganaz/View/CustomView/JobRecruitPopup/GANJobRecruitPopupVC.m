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

@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UIButton *buttonRecruit;
@property (weak, nonatomic) IBOutlet UIButton *buttonEdit;
@property (weak, nonatomic) IBOutlet UIButton *buttonCandidates;

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
    
    self.buttonRecruit.clipsToBounds        = YES;
    self.buttonRecruit.layer.cornerRadius   = 3;
    self.buttonEdit.clipsToBounds                 = YES;
    self.buttonEdit.layer.cornerRadius            = 3;
    self.buttonCandidates.clipsToBounds        = YES;
    self.buttonCandidates.layer.cornerRadius   = 3;
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (IBAction)onButtonWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onButtonRecruitClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
    if(self.delegate && [self.delegate respondsToSelector:@selector(didRecruitClick)]) {
        [self.delegate didRecruitClick];
    }
}

- (IBAction)onButtonEditJobClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didEditJobClick)]) {
        [self.delegate didEditJobClick];
    }
}

- (IBAction)onButtonViewCandidatesClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didViewCandidatesClick)]) {
        [self.delegate didViewCandidatesClick];
    }
}

@end
