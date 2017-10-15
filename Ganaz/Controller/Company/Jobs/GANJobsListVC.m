//
//  GANJobsListVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/21/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobsListVC.h"
#import "GANJobItemTVC.h"
#import "GANJobsDetailsVC.h"
#import "GANJobRecruitPopupVC.h"
#import "GANRecruitVC.h"

#import "GANCompanyDataModel.h"
#import "GANFadeTransitionDelegate.h"
#import "GANUserManager.h"
#import "GANJobManager.h"
#import "GANJobDataModel.h"

#import "GANGenericFunctionManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"
#import "GANAppManager.h"

@interface GANJobsListVC () <UITableViewDelegate, UITableViewDataSource, GANJobRecruitPopupVCDelegate>
{
    int nSelectedIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *viewBadge;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBadge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableviewTopSpacing;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@end

@implementation GANJobsListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    [self registerTableViewCellFromNib];
    [self refreshViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"JobItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_JOBLIST_ITEM"];
}

- (void) refreshViews{
    GANCompanyDataModel *company = [GANUserManager getCompanyDataModel];
    
    self.viewBadge.layer.cornerRadius = 2;
    self.lblTitle.text = [company getBusinessNameEN];
    
    GANENUM_COMPANY_BADGE_TYPE enumType = [company getBadgeType];
    if (enumType == GANENUM_COMPANY_BADGE_TYPE_NONE){
        self.viewBadge.hidden = YES;
        self.constraintTableviewTopSpacing.constant = 14;
    }
    else if (enumType == GANENUM_COMPANY_BADGE_TYPE_SILVER){
        self.viewBadge.hidden = NO;
        self.constraintTableviewTopSpacing.constant = 64;
        self.viewBadge.layer.backgroundColor = GANUICOLOR_BADGE_SILVER.CGColor;
        self.lblBadge.text = @"SILVER EMPLOYER";
    }
    else if (enumType == GANENUM_COMPANY_BADGE_TYPE_GOLD){
        self.viewBadge.hidden = NO;
        self.constraintTableviewTopSpacing.constant = 64;
        self.viewBadge.layer.backgroundColor = GANUICOLOR_BADGE_GOLD.CGColor;
        self.lblBadge.text = @"GOLD EMPLOYER";
    }
}

- (void) showPopupDialog {
    GANJobRecruitPopupVC *vc = [[GANJobRecruitPopupVC alloc] initWithNibName:@"GANJobRecruitPopupVC" bundle:nil];
    
    vc.delegate = self;
    vc.view.backgroundColor = [UIColor clearColor];
    [vc setTransitioningDelegate:self.transController];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) gotoDetailsVCAtIndex: (int) index{
    [[GANJobManager sharedInstance] initializeOnboardingJobAtIndex:index];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANJobsDetailsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_JOBS_DETAILS"];
    vc.indexJob = index;
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to job details from job list");
}

- (void) deleteJobAtIndex: (int) index{
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANJobManager sharedInstance] requestDeleteJobAtIndex:index Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Job has been deleted successfully" DismissAfter:3 Callback:^{
                [self.tableview reloadData];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:3 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Company - Delete job from job list");
}

- (void) promptForDeleteAtIndex: (int) index{
    dispatch_async(dispatch_get_main_queue(), ^{
        [GANGlobalVCManager promptWithVC:self Title:@"Confirmation" Message:@"Are you sure you want to delete this?" ButtonYes:@"Yes" ButtonNo:@"No" CallbackYes:^{
            [self deleteJobAtIndex:index];
        } CallbackNo:nil];
        [self.tableview setEditing:NO animated:YES];
    });
}

#pragma mark - GANJobRecruitPopupVCDelegate

- (void) didRecruit {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
        GANRecruitVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_RECRUIT"];
        vc.nJobIndex = nSelectedIndex;
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
}

- (void) didEdit {
    [self gotoDetailsVCAtIndex:nSelectedIndex];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANJobItemTVC *) cell AtIndex: (int) index{
    GANJobDataModel *job = [[GANJobManager sharedInstance].arrMyJobs objectAtIndex:index];
    cell.lblTitle.text = [job getTitleEN];
    cell.lblPrice.text = [NSString stringWithFormat:@"$%.02f", job.fPayRate];
    cell.lblUnit.text = job.szPayUnit;
    cell.lblDate.text = [NSString stringWithFormat:@"%@ - %@", [GANGenericFunctionManager getBeautifiedDate:job.dateFrom], [GANGenericFunctionManager getBeautifiedDate:job.dateTo]];
    
    [cell showPayRate:[job isPayRateSpecified]];
    
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[GANJobManager sharedInstance].arrMyJobs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANJobItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_JOBLIST_ITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 76;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [self promptForDeleteAtIndex:(int) indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    nSelectedIndex = (int) indexPath.row;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showPopupDialog];
    });
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnAddClick:(id)sender {
    [self gotoDetailsVCAtIndex:-1];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATED]) ||
        ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED])){
        [self.tableview reloadData];
    }
}

@end
