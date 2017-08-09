//
//  GANJobHomeVC.m
//  Ganaz
//
//  Created by forever on 7/31/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobHomeVC.h"
#import "GANJobsDetailsVC.h"
#import "GANCompanySignupVC.h"
#import "GANRetainMyWorkersVC.h"
#import "GANCompanyAddWorkerVC.h"
#import "GANSharePostingWithContactsVC.h"

#import "GANJobManager.h"
#import "GANUserManager.h"
#import "GANCompanyManager.h"


@interface GANJobHomeVC ()

@property (weak, nonatomic) IBOutlet UIButton *btnGetWorkers;
@property (weak, nonatomic) IBOutlet UIButton *btnCommunicateWithMyWorkers;
@property (weak, nonatomic) IBOutlet UIButton *btnRetainMyWorkers;

@end

@implementation GANJobHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btnGetWorkers.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.btnGetWorkers.titleLabel.numberOfLines = 1;
    self.btnGetWorkers.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnGetWorkers.layer.cornerRadius       = 3.f;
    self.btnGetWorkers.clipsToBounds            = YES;
    
    self.btnCommunicateWithMyWorkers.titleLabel.lineBreakMode   = NSLineBreakByWordWrapping;
    self.btnCommunicateWithMyWorkers.titleLabel.numberOfLines   = 2;
    self.btnCommunicateWithMyWorkers.titleLabel.textAlignment   = NSTextAlignmentCenter;
    self.btnCommunicateWithMyWorkers.clipsToBounds              = YES;
    self.btnCommunicateWithMyWorkers.layer.cornerRadius         = 3.f;
    
    self.btnRetainMyWorkers.titleLabel.lineBreakMode    = NSLineBreakByWordWrapping;
    self.btnRetainMyWorkers.titleLabel.numberOfLines    = 2;
    self.btnRetainMyWorkers.titleLabel.textAlignment    = NSTextAlignmentCenter;
    self.btnRetainMyWorkers.clipsToBounds               = YES;
    self.btnRetainMyWorkers.layer.cornerRadius          = 3.f;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if(self.fromSignup == COMMUNICATE_SIGNUP) {
        [self gotoMessage];
    } else if(self.fromSignup == RETAIN_SIGNUP) {
        [self gotoRetain];
    }
}

- (void) gotoMessage {
    self.fromSignup = DEFAULT_SIGNUP;
    [self.tabBarController setSelectedIndex:2];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANSharePostingWithContactsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_JOBS_SHAREWITHWORKERS"];
    vc.fromVC = ENUM_COMPANY_SHAREPOSTINGWITHCONTACT_FROM_HOME;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) gotoRetain {
    self.fromSignup = DEFAULT_SIGNUP;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANRetainMyWorkersVC *viewcontroller = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_JOBS_RETAINMYWORKERS"];
    [self.navigationController pushViewController:viewcontroller animated:NO];
}

- (IBAction)onGetWorkers:(id)sender {
    [[GANJobManager sharedInstance] initializeOnboardingJobAtIndex:-1];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANJobsDetailsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_JOBS_DETAILS"];
    vc.indexJob = -1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onCommunicationWithMyWorkers:(id)sender {
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        GANCompanySignupVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SIGNUP"];
        vc.fromCustomVC = COMMUNICATE_SIGNUP;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if([GANCompanyManager sharedInstance].arrMyWorkers.count == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
        GANCompanyAddWorkerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_ADDWORKER"];
        vc.fromCustomVC = ENUM_COMPANY_ADDWORKERS_FROM_HOME;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self.tabBarController setSelectedIndex:2];
    }
}

- (IBAction)onRetainMyWorkers:(id)sender {
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        GANCompanySignupVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SIGNUP"];
        vc.fromCustomVC = RETAIN_SIGNUP;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    self.fromSignup = DEFAULT_SIGNUP;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANRetainMyWorkersVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_JOBS_RETAINMYWORKERS"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoProfile:(id)sender {
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_LOGIN_PHONE"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
