//
//  GANAppUpdatesPopupVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/4/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANAppUpdatesPopupVC.h"
#import "Global.h"
#import "GANGlobalVCManager.h"
#import "GANAppManager.h"

@interface GANAppUpdatesPopupVC ()

@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdate;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@end

#define GANUICOLOR_APPUPDATESVC_CONTAINERVIEW_BORDER            [UIColor colorWithRed:(210 / 255.0) green:(215 / 255.0) blue:(220 / 255.0) alpha:1]

@implementation GANAppUpdatesPopupVC

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
    self.viewContents.clipsToBounds = YES;
    self.viewContents.layer.cornerRadius = 3;
    self.viewContents.layer.borderWidth = 1;
    self.viewContents.layer.borderColor = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    
    self.btnUpdate.clipsToBounds = YES;
    self.btnUpdate.layer.cornerRadius = 3;
    
    self.btnCancel.clipsToBounds = YES;
    self.btnCancel.layer.cornerRadius = 3;
    self.btnCancel.layer.borderWidth = 1;
    self.btnCancel.layer.borderColor = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
}

- (void) refreshFields{
    GANAppManager *managerApp = [GANAppManager sharedInstance];
    if (managerApp.enumAppUpdateType == GANENUM_APPCONFIG_APPUPDATETYPE_OPTIONAL){
        [self.btnUpdate setTitle:NSLocalizedString(@"Update", @"") forState:UIControlStateNormal];
        [self.btnCancel setTitle:NSLocalizedString(@"Later", @"") forState:UIControlStateNormal];
        self.lblDescription.text = NSLocalizedString(@"A new version of Ganaz is available!\r\rPlease press update.", @"");
    }
    else if (managerApp.enumAppUpdateType == GANENUM_APPCONFIG_APPUPDATETYPE_MANDATORY){
        [self.btnUpdate setTitle:NSLocalizedString(@"Update", @"") forState:UIControlStateNormal];
        [self.btnCancel setTitle:NSLocalizedString(@"Exit", @"") forState:UIControlStateNormal];
        self.lblDescription.text = NSLocalizedString(@"A new version of Ganaz is available!\rPlease press update to continue using Ganaz", @"");
    }
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnWrapperClick:(id)sender {
}

- (IBAction)onBtnUpdateClick:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:GANURL_APPSTORE]]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GANURL_APPSTORE]];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateClick)]){
        [self.delegate didUpdateClick];
    }
}

- (IBAction)onBtnCancelClick:(id)sender {
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelClick)]){
            [self.delegate didCancelClick];
        }
    }];
}

@end
