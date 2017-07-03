//
//  GANBenefitInfoPopupVC.m
//  Ganaz
//
//  Created by Piric Djordje on 6/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANBenefitInfoPopupVC.h"
#import "Global.h"
#import "GANGlobalVCManager.h"
#import "GANDataManager.h"

@interface GANBenefitInfoPopupVC ()

@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@end

@implementation GANBenefitInfoPopupVC

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
}

- (void) refreshFields{
    GANBenefitDataModel *benefit = [[GANDataManager sharedInstance].arrBenefits objectAtIndex:self.indexBenefit];
    [self.imgIcon setImage:[UIImage imageNamed:benefit.szIcon]];
    self.lblTitle.text = [benefit getTitleES];
    self.lblDescription.text = [benefit getDescriptionES];
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
    [self.view endEditing:YES];
    [self closeDialog];
}

@end
