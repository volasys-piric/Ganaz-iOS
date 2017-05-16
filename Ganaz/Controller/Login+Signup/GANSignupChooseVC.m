//
//  GANSignupChooseVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANSignupChooseVC.h"

@interface GANSignupChooseVC ()

@end

@implementation GANSignupChooseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBtnCompanyClick:(id)sender {
    [self performSegueWithIdentifier:@"SEGUE_FROM_SIGNUP_CHOOSE_TO_COMPANY" sender:nil];
}

- (IBAction)onBtnWorkerClick:(id)sender {
    [self performSegueWithIdentifier:@"SEGUE_FROM_SIGNUP_CHOOSE_TO_WORKER" sender:nil];
}

@end
