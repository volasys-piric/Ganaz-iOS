//
//  GANWorkerCompanyDetailsVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/25/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerCompanyDetailsVC.h"
#import "GANJobItemTVC.h"
#import "GANWorkerJobDetailsVC.h"
#import "GANWorkerCompanyReviewVC.h"

#import "GANCacheManager.h"
#import "GANUserCompanyDataModel.h"
#import "GANJobDataModel.h"
#import "GANUserManager.h"

#import "GANGlobalVCManager.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"
#import "GANAppManager.h"

@interface GANWorkerCompanyDetailsVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *viewBadge;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBadge;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnReview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableviewTopSpacing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableviewHeight;

@property (strong, nonatomic) GANCompanyDataModel *company;

@end

#define CONSTANT_TABLEVIEWCELL_HEIGHT               76

@implementation GANWorkerCompanyDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self refreshFields];
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"JobItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_JOBLIST_ITEM"];
}

- (void) refreshFields{
    self.company = [[GANCacheManager sharedInstance].arrayCompanies objectAtIndex:self.indexCompany];
    
    self.lblTitle.text = [self.company getBusinessNameES];
    self.lblDescription.text = [self.company getDescriptionES];
    
    GANENUM_COMPANY_BADGE_TYPE enumType = [self.company getBadgeType];
    if (enumType == GANENUM_COMPANY_BADGE_TYPE_NONE){
        self.viewBadge.hidden = YES;
        self.constraintTableviewTopSpacing.constant = 14;
    }
    else if (enumType == GANENUM_COMPANY_BADGE_TYPE_SILVER){
        self.viewBadge.hidden = NO;
        self.constraintTableviewTopSpacing.constant = 64;
        self.viewBadge.layer.backgroundColor = GANUICOLOR_BADGE_SILVER.CGColor;
        self.lblBadge.text = @"EMPRESA PLATEADA";
    }
    else if (enumType == GANENUM_COMPANY_BADGE_TYPE_GOLD){
        self.viewBadge.hidden = NO;
        self.constraintTableviewTopSpacing.constant = 64;
        self.viewBadge.layer.backgroundColor = GANUICOLOR_BADGE_GOLD.CGColor;
        self.lblBadge.text = @"EMPRESA DORADA";
    }
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [self.company requestJobsList:NO Callback:^(int status) {
        [GANGlobalVCManager hideHudProgress];
        self.constraintTableviewHeight.constant = CONSTANT_TABLEVIEWCELL_HEIGHT * [self.company.arrJobs count];
        [self.tableview reloadData];
    }];
}

- (void) refreshViews{
    self.viewBadge.layer.cornerRadius = 2;
    self.btnReview.layer.cornerRadius = 3;
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void) viewDidLayoutSubviews{
    [self.view layoutIfNeeded];
    [self refreshTableviewHeight];
}

- (void) refreshTableviewHeight{
    self.constraintTableviewHeight.constant = CONSTANT_TABLEVIEWCELL_HEIGHT * [self.company.arrJobs count];
}

- (void) gotoJobDetailsAtIndex: (int) index{
    GANACTIVITY_REPORT(@"Worker - Go to job details from Company details");
    
    NSArray *arrOldVCs = self.navigationController.viewControllers;
    for (int i = 0; i < (int) [arrOldVCs count]; i++){
        UIViewController *vc = [arrOldVCs objectAtIndex:i];
        if ([vc isKindOfClass:[GANWorkerJobDetailsVC class]] == YES){
            // If JobDetailsVC is already in nav stack, we need to go back, refreshing all the fields of JobDetails VC.
            
            GANWorkerJobDetailsVC *vcJobDetails = (GANWorkerJobDetailsVC *)vc;
            vcJobDetails.indexCompany = self.indexCompany;
            vcJobDetails.indexJob = index;
            [vcJobDetails refreshOnChange];
            [self.navigationController popToViewController:vcJobDetails animated:YES];
            
            return;
        }
    }
    // if JobDetailsVC is not in nav stack yet, we initiate VC and push to nav stack
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    GANWorkerJobDetailsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_JOBDETAILS"];
    vc.indexCompany = self.indexCompany;
    vc.indexJob = index;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) gotoReviewVC{
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
        GANWorkerCompanyReviewVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_COMPANYREVIEW"];
        vc.indexCompany = self.indexCompany;
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_PHONE"];
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANJobItemTVC *) cell AtIndex: (int) index{
    GANJobDataModel *job = [self.company.arrJobs objectAtIndex:index];
    
    cell.lblTitle.text = [job getTitleES];
    cell.lblPrice.text = [NSString stringWithFormat:@"$%.02f", job.fPayRate];//[NSString stringWithFormat:@"$%.02f / %@", job.fPayRate, job.szPayUnit];
    // View Details...
    cell.lblUnit.text = @"Ver más";
    cell.lblDate.text = [NSString stringWithFormat:@"%@ - %@", [GANGenericFunctionManager getBeautifiedSpanishDate:job.dateFrom], [GANGenericFunctionManager getBeautifiedSpanishDate:job.dateTo]];
    [cell showPayRate:[job isPayRateSpecified]];
    
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.company == nil) return 0;
    return [self.company.arrJobs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANJobItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_JOBLIST_ITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    [self gotoJobDetailsAtIndex:index];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnReviewClick:(id)sender {
    [self gotoReviewVC];
}

- (IBAction)onBtnLoginClick:(id)sender {
    [self.view endEditing:YES];
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_LOGIN_PHONE"];
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        return;
    }
}

@end
