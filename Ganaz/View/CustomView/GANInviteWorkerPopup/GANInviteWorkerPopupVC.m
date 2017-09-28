//
//  GANInviteWorkerPopupVC.m
//  Ganaz
//
//  Created by forever on 9/17/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANInviteWorkerPopupVC.h"
#import "Global.h"

@interface GANInviteWorkerPopupVC ()

@property (strong, nonatomic) IBOutlet UIView *viewContents;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnInviteWorker;
@property (strong, nonatomic) IBOutlet UIButton *btnCommunicateText;

@end

@implementation GANInviteWorkerPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refreshViews];
}

- (void) refreshViews {
    self.viewContents.clipsToBounds         = YES;
    self.viewContents.layer.cornerRadius    = 3;
    self.viewContents.layer.borderWidth     = 1;
    self.viewContents.layer.borderColor     = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    
    self.btnCancel.layer.cornerRadius       = 3;
    self.btnCancel.clipsToBounds            = YES;
    
    self.btnInviteWorker.layer.cornerRadius = 3;
    self.btnInviteWorker.clipsToBounds      = YES;
    
    self.btnCommunicateText.layer.cornerRadius = 3;
    self.btnCommunicateText.clipsToBounds      = YES;
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void) setDescription:(NSString *) szName {
    self.lblDescription.text = [NSString stringWithFormat:@"%@ is not using Ganaz yet", szName];
}

- (IBAction)onBtnWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onInviteWorkerstoGanaz:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(InviteWorkertoGanaz)]) {
        [self.delegate InviteWorkertoGanaz];
    }
    
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onCommunicateWithWorkers:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(CommunicateWithWorkers)]) {
        [self.delegate CommunicateWithWorkers];
    }
    
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onGoback:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
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
