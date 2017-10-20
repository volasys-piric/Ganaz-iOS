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

@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;
@property (weak, nonatomic) IBOutlet UIButton *buttonInviteWorker;
@property (weak, nonatomic) IBOutlet UIButton *buttonCommunicateText;

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
    
    self.buttonCancel.layer.cornerRadius       = 3;
    self.buttonCancel.clipsToBounds            = YES;
    
    self.buttonInviteWorker.layer.cornerRadius = 3;
    self.buttonInviteWorker.clipsToBounds      = YES;
    
    self.buttonCommunicateText.layer.cornerRadius = 3;
    self.buttonCommunicateText.clipsToBounds      = YES;
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

- (IBAction)onButtonInviteClick:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(companyInviteWorkerPopupDidInviteWorker:)]) {
        [self.delegate companyInviteWorkerPopupDidInviteWorker:self];
    }
    
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onButtonCommunicateClick:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(companyInviteWorkerPopupDidCommunicateWithWorker:)]) {
        [self.delegate companyInviteWorkerPopupDidCommunicateWithWorker:self];
    }
    
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onButtonCancel:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(companyInviteWorkerPopupDidCancel:)]) {
        [self.delegate companyInviteWorkerPopupDidCancel:self];
    }
    
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
