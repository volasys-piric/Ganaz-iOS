//
//  GANJobPostSuccessPopupVC.m
//  Ganaz
//
//  Created by forever on 7/31/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobPostSuccessPopupVC.h"
#import "Global.h"

@interface GANJobPostSuccessPopupVC ()

@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@end

@implementation GANJobPostSuccessPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshFields:(NSInteger) nCount{
    NSString *strDescription = [NSString stringWithFormat:@"Well done!\nYour job has been\nposted and broadcast\nto %ld workers", (long)nCount];
    self.lblDescription.text = NSLocalizedString(strDescription, @"");
}

- (void) refreshViews{
    self.viewContents.clipsToBounds         = YES;
    self.viewContents.layer.cornerRadius    = 3;
    self.viewContents.layer.borderWidth     = 1;
    self.viewContents.layer.borderColor     = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    
    self.btnOk.clipsToBounds        = YES;
    self.btnOk.layer.cornerRadius   = 3;
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (IBAction)onBtnWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onOk:(id)sender {
    [self.view endEditing:YES];
    [self closeDialog];
    [self.delegate didOK];
}

@end
