//
//  GANWorkerJobApplyCompletedVC.m
//  Ganaz
//
//  Created by Piric Djordje on 7/16/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerJobApplyCompletedVC.h"
#import "GANWorkerJobsListVC.h"
#import "GANCacheManager.h"
#import "Global.h"
#import "GANAppManager.h"

@interface GANWorkerJobApplyCompletedVC ()

@property (weak, nonatomic) IBOutlet UILabel *labelMessage;

@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonSearchJobs;
@property (weak, nonatomic) IBOutlet UIButton *buttonShare;

@property (strong, nonatomic) GANJobDataModel *job;

@end

@implementation GANWorkerJobApplyCompletedVC

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
    self.buttonBack.clipsToBounds = YES;
    self.buttonBack.layer.cornerRadius = 3;
    self.buttonSearchJobs.clipsToBounds = YES;
    self.buttonSearchJobs.layer.cornerRadius = 3;
    self.buttonShare.clipsToBounds = YES;
    self.buttonShare.layer.cornerRadius = 3;
    self.buttonShare.layer.borderWidth = 1;
    self.buttonShare.layer.borderColor = GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR.CGColor;
    
    if (self.isSuggestFriend == YES){
        self.labelMessage.text = @"Bien hecho! Hemos avisado la empresa del interés de su amigo.";
    }
    else {
        self.labelMessage.text = @"Bien hecho! Hemos avisado la empresa de su interés";
    }
}

#pragma mark - Biz Logic

- (void) doShare{
    NSString *szPay = @"";
    GANJobDataModel *job = [[GANCacheManager sharedInstance] getJobByJobId:self.szJobId];
    GANCompanyDataModel *company = [[GANCacheManager sharedInstance] getCompanyByJobId:self.szJobId];
    
    if (job == nil || company == nil) return;
    
    NSString *message = [NSString stringWithFormat:@"Pensé que te interesaría este trabajo: %@, %@%@. Hay más información y más trabajo en la aplicación Ganaz", [company getBusinessNameES], [job getTitleES], szPay];
    
    
    NSURL *url = [NSURL URLWithString:GANURL_APPSTORE];
    NSArray *objShare = @[message, url];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objShare applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
    
    GANACTIVITY_REPORT(@"Worker - Share job via social network");
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onButtonSearchJobsClick:(id)sender {
    NSArray *arrVCs = self.navigationController.viewControllers;
    for (int i = 0; i < (int) [arrVCs count]; i++){
        UIViewController *vc = [arrVCs objectAtIndex:i];
        if ([vc isKindOfClass:[GANWorkerJobsListVC class]] == YES){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToViewController:vc animated:YES];
            });
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_JOBS"];
        self.navigationController.viewControllers = @[vc, self];
        [self.navigationController popViewControllerAnimated:YES];
        GANACTIVITY_REPORT(@"Worker - Go to suggest-friend view from job apply view");
    });
}

- (IBAction)onButtonShareClick:(id)sender {
    [self doShare];
}

@end
