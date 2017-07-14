//
//  GANMainChooseVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/10/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMainChooseVC.h"

@interface GANMainChooseVC ()

@property (weak, nonatomic) IBOutlet UIView *viewWorker;
@property (weak, nonatomic) IBOutlet UIView *viewCompany;

@end

@implementation GANMainChooseVC

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
    self.viewWorker.clipsToBounds = YES;
    self.viewWorker.layer.cornerRadius = 3;
    self.viewCompany.clipsToBounds = YES;
    self.viewCompany.layer.cornerRadius = 3;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - Biz Logic

- (void) gotoWorkerLoginPhoneVC{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_JOBS"];
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
}

- (void) gotoCompanyLoginPhoneVC{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_LOGIN_PHONE"];
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonWorkerClick:(id)sender {
    [self gotoWorkerLoginPhoneVC];
}

- (IBAction)onButtonCompanyClick:(id)sender {
    [self gotoCompanyLoginPhoneVC];
}

@end
