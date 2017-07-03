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

@implementation GANAppUpdatesPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.viewContents.clipsToBounds = YES;
    self.viewContents.layer.cornerRadius = 3;
}

- (void) refreshFields{
    GANAppManager *managerApp = [GANAppManager sharedInstance];
    if (managerApp.enumAppUpdateType == GANENUM_APPCONFIG_APPUPDATETYPE_OPTIONAL){
        [self.btnCancel setTitle:@"Later" forState:UIControlStateNormal];
        self.lblDescription.text = [NSString stringWithFormat:@"New version v%@ is available in App Store now!\n\nYou may now download and install to enjoy new exciting features.", managerApp.szLatestVersion];
    }
    else if (managerApp.enumAppUpdateType == GANENUM_APPCONFIG_APPUPDATETYPE_MANDATORY){
        [self.btnCancel setTitle:@"Exit" forState:UIControlStateNormal];
        self.lblDescription.text = [NSString stringWithFormat:@"New version v%@ is available in App Store now!\n\nPlease download and install to continue.", managerApp.szLatestVersion];
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
