//
//  GANCountrySelectorPopupVC.m
//  Ganaz
//
//  Created by Chris Lin on 2/8/18.
//  Copyright © 2018 Ganaz. All rights reserved.
//

#import "GANCountrySelectorPopupVC.h"
#import "Global.h"
#import "GANGlobalVCManager.h"

@interface GANCountrySelectorPopupVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageCheckUs;
@property (weak, nonatomic) IBOutlet UIImageView *imageCheckMx;

@end

@implementation GANCountrySelectorPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshFields {
    if (self.enumCountry == GANENUM_PHONE_COUNTRY_US) {
        [self.imageCheckUs setImage:[UIImage imageNamed:@"icon-checked"]];
        [self.imageCheckMx setImage:[UIImage imageNamed:@"icon-unchecked"]];
    }
    else if (self.enumCountry == GANENUM_PHONE_COUNTRY_MX) {
        [self.imageCheckUs setImage:[UIImage imageNamed:@"icon-unchecked"]];
        [self.imageCheckMx setImage:[UIImage imageNamed:@"icon-checked"]];
    }
}

- (void) closeDialog{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL b){
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
    });
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonWrapperClick:(id)sender {
    [self closeDialog];
}

- (IBAction)onButtonUsClick:(id)sender {
    self.enumCountry = GANENUM_PHONE_COUNTRY_US;
    [self refreshFields];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCountrySelect:)]){
        [self.delegate didCountrySelect:self.enumCountry];
    }
    [self closeDialog];
}

- (IBAction)onButtonMxClick:(id)sender {
    self.enumCountry = GANENUM_PHONE_COUNTRY_MX;
    [self refreshFields];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCountrySelect:)]){
        [self.delegate didCountrySelect:self.enumCountry];
    }
    [self closeDialog];
}

@end
