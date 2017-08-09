//
//  GANJobPostingSharedPopupVC.m
//  Ganaz
//
//  Created by forever on 8/1/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobPostingSharedPopupVC.h"
#import "Global.h"

@interface GANJobPostingSharedPopupVC ()

@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@end

@implementation GANJobPostingSharedPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshFields:(NSString*) strDescription{
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
