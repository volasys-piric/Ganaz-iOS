//
//  GANWorkerSettingsVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/26/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerSettingsVC.h"
#import "GANAppManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"

@interface GANWorkerSettingsVC ()

@property (weak, nonatomic) IBOutlet UIButton *btnSignout;
@property (weak, nonatomic) IBOutlet UIButton *btnChangeLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnToS;

@end

@implementation GANWorkerSettingsVC

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
    
    self.btnChangeLocation.layer.cornerRadius = 3;
    self.btnChangeLocation.layer.borderWidth = 1;
    self.btnChangeLocation.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
    
    self.btnToS.layer.cornerRadius = 3;
    self.btnToS.layer.borderWidth = 1;
    self.btnToS.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
}

- (void) gotoUpdateLocationVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_UPDATELOCATION"];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) gotoToSVC{
    GANACTIVITY_REPORT(@"Worker - Open privacy policy");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_TOS"];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnSignoutClick:(id)sender {
//    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    [GANGlobalVCManager logoutToLoginVC:self.tabBarController];
    [[GANAppManager sharedInstance] initializeManagersAfterLogout];
}

- (IBAction)onBtnChangeLocationClick:(id)sender {
    [self gotoUpdateLocationVC];
}

- (IBAction)onBtnToSClick:(id)sender {
    [self gotoToSVC];
}

@end
