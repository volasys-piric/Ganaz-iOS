//
//  GANCompanySettingsVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/26/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySettingsVC.h"
#import "GANAppManager.h"
#import <Crashlytics/Crashlytics.h>
#import "Global.h"
#import "GANGlobalVCManager.h"

@interface GANCompanySettingsVC ()

@property (weak, nonatomic) IBOutlet UIButton *btnSignout;
@property (weak, nonatomic) IBOutlet UIButton *btnManageRoles;
@property (weak, nonatomic) IBOutlet UIButton *btnToS;

@end

@implementation GANCompanySettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) refreshViews{
    self.btnSignout.layer.cornerRadius = 3;
    self.btnSignout.layer.borderWidth = 1;
    self.btnSignout.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
    
    self.btnManageRoles.layer.cornerRadius = 3;
    self.btnManageRoles.layer.borderWidth = 1;
    self.btnManageRoles.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
    
    self.btnToS.layer.cornerRadius = 3;
    self.btnToS.layer.borderWidth = 1;
    self.btnToS.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
}

- (void) gotoManageRolesVC{
    GANACTIVITY_REPORT(@"Company - Manage Roles");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MANAGEROLE"];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) gotoToSVC{
    GANACTIVITY_REPORT(@"Company - Open privacy policy");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_TOS"];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnSignoutClick:(id)sender {
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    [[GANAppManager sharedInstance] initializeManagersAfterLogout];
}

- (IBAction)onBtnToSClick:(id)sender {
    [self gotoToSVC];
}

- (IBAction)onBtnManageRolesClick:(id)sender {
    [self gotoManageRolesVC];
}

- (IBAction)onButtonCrashClick:(id)sender {
    [GANGlobalVCManager promptWithVC:self Title:@"Warning!" Message:@"Are you sure you want to crash the app?" ButtonYes:@"Yes" ButtonNo:@"No" CallbackYes:^{
        [[Crashlytics sharedInstance] crash];
    } CallbackNo:nil];
}

@end
