//
//  GANRetainMyWorkersVC.m
//  Ganaz
//
//  Created by forever on 8/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANRetainMyWorkersVC.h"
#import "GANCompanyAddWorkerVC.h"
#import "GANGlobalVCManager.h"
#import "GANUserManager.h"
#import "GANCompanyManager.h"
#import "GANCommunicateWithMyWorkersOnboardingVC.h"

@interface GANRetainMyWorkersVC ()
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;

@end

@implementation GANRetainMyWorkersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshView];
}

- (void) refreshView {
    self.btnSendMessage.layer.cornerRadius = 3.f;
    self.btnSendMessage.clipsToBounds = YES;
}

- (IBAction)onSendMessage:(id)sender {
    
     if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
         UIStoryboard *storboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
         GANCommunicateWithMyWorkersOnboardingVC *vc = [storboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_COMMUNICATEWITHMYWORKERS_ONBOARDING"];
         [self.navigationController pushViewController:vc animated:YES];
         self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
         
         return;
     }
    
    if([GANCompanyManager sharedInstance].arrMyWorkers.count == 0) {
        
        [GANGlobalVCManager tabBarController:self.tabBarController shouldSelectViewController:2];
        UINavigationController *navVC = [self.tabBarController.viewControllers objectAtIndex:2];
        
        for(int i = 0; i < navVC.viewControllers.count; i ++) {
            UIViewController *viewController = [navVC.viewControllers objectAtIndex:i];
            if([viewController isKindOfClass:[GANCompanyAddWorkerVC class]] == YES) {
                [navVC popToViewController:viewController animated:YES];
                return;
            }
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
        GANCompanyAddWorkerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_ADDWORKER"];
        vc.fromCustomVC = ENUM_COMPANY_ADDWORKERS_FROM_RETAINMYWORKERS;
        vc.szDescription = @"Who do you want to message?";
        
        [navVC pushViewController:vc animated:YES];
        
        [navVC.viewControllers firstObject].navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController popViewControllerAnimated:NO];
        
    } else {
        [GANGlobalVCManager tabBarController:self.tabBarController shouldSelectViewController:2];
        [self.navigationController popViewControllerAnimated:NO];
    }
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
