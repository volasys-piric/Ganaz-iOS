//
//  GANConformMessagePopupVC.m
//  Ganaz
//
//  Created by forever on 9/12/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANConformMessagePopupVC.h"
#import "Global.h"

@interface GANConformMessagePopupVC ()
@property (strong, nonatomic) IBOutlet UIView *viewContents;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnSend;

@end

@implementation GANConformMessagePopupVC

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
    self.btnCancel.layer.borderWidth        = 1;
    self.btnCancel.layer.borderColor        = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    
    self.btnSend.layer.cornerRadius         = 3;
    self.btnSend.clipsToBounds              = YES;
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void) setDescription:(NSInteger) nCount {
    self.lblDescription.text = [NSString stringWithFormat:@"%ld of your workers are not using Ganaz so this message will cost $%.02f\n to send", (long)nCount, nCount * 0.05];
}

- (IBAction)onBtnWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onSend:(id)sender {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didClickSend)]) {
        [self.delegate didClickSend];
    }
    
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onCancel:(id)sender {
    [self.view endEditing:YES];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didClickCancel)]) {
        [self.delegate didClickCancel];
    }
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
