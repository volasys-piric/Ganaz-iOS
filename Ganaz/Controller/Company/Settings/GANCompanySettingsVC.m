//
//  GANCompanySettingsVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/26/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySettingsVC.h"
#import "GANAppManager.h"

@interface GANCompanySettingsVC ()

@property (weak, nonatomic) IBOutlet UIButton *btnSignout;

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
}

- (IBAction)onBtnSignoutClick:(id)sender {
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    [[GANAppManager sharedInstance] initializeManagersAfterLogout];
}

@end
