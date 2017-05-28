//
//  GANRecruitVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANRecruitVC.h"
#import "GANJobItemTVC.h"
#import "GANWorkerItemTVC.h"
#import "GANGlobalVCManager.h"

#import "GANJobManager.h"
#import "GANUserManager.h"
#import "GANCacheManager.h"
#import "GANCompanyManager.h"
#import "GANRecruitManager.h"

#import "GANGenericFunctionManager.h"
#import "Global.h"

@interface GANRecruitVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableviewJobs;
@property (weak, nonatomic) IBOutlet UITableView *tableviewWorkers;

@property (weak, nonatomic) IBOutlet UIView *viewPopupWrapper;
@property (weak, nonatomic) IBOutlet UIView *viewBroadcastPanel;
@property (weak, nonatomic) IBOutlet UIView *viewPopupPanel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewPopup;

@property (weak, nonatomic) IBOutlet UITextField *txtMiles;

@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPopupPanelTopSpacing;

@property (assign, atomic) BOOL isPopupShowing;
@property (assign, atomic) int nPopupStep;

@property (strong, nonatomic) NSMutableArray *arrJobSelected;
@property (strong, nonatomic) NSMutableArray *arrWorkerSelected;

@end

@implementation GANRecruitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableviewJobs.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableviewJobs.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableviewJobs.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableviewWorkers.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableviewWorkers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableviewWorkers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.isPopupShowing = NO;
    self.nPopupStep = 0;
    self.arrJobSelected = [[NSMutableArray alloc] init];
    self.arrWorkerSelected = [[NSMutableArray alloc] init];

    [self buildJobsList];
    [self buildWorkerList];
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) registerTableViewCellFromNib{
    [self.tableviewJobs registerNib:[UINib nibWithNibName:@"JobItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_JOBLIST_ITEM"];
    [self.tableviewWorkers registerNib:[UINib nibWithNibName:@"WorkerItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKERITEM"];
}

- (void) refreshViews{
    self.viewBroadcastPanel.layer.cornerRadius = 3;
    self.btnSubmit.layer.cornerRadius = 3;
    self.btnContinue.layer.cornerRadius = 3;
}

- (void) refreshPopupView{
    self.viewPopupWrapper.hidden = !self.isPopupShowing;
}

- (void) buildJobsList{
    [self.arrJobSelected removeAllObjects];
    int count = (int) [[GANJobManager sharedInstance].arrMyJobs count];
    for (int i = 0; i < count; i++){
        [self.arrJobSelected addObject:@(NO)];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableviewJobs reloadData];
    });
}

- (void) buildWorkerList{
    [self.arrWorkerSelected removeAllObjects];
    int count = (int) [[GANCompanyManager sharedInstance].arrMyWorkers count];
    
    for (int i = 0; i < count; i++){
        [self.arrWorkerSelected addObject:@(NO)];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableviewWorkers reloadData];
    });
}

#pragma mark - UI Stuff

- (void) animateToShowPopup{
    if (self.isPopupShowing == YES) return;
    self.isPopupShowing = YES;
    self.nPopupStep = 0;
    [self.scrollviewPopup setContentOffset:CGPointMake(0, 0)];
    [self.btnSubmit setTitle:@"Continue" forState:UIControlStateNormal];
    
    // Animate to show
    int height = (int) self.viewPopupPanel.frame.size.height;
    
    self.viewPopupWrapper.hidden = NO;
    self.viewPopupWrapper.alpha = 0;
    self.constraintPopupPanelTopSpacing.constant = -height;
    [self.viewPopupWrapper layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.constraintPopupPanelTopSpacing.constant = 0;
        self.viewPopupWrapper.alpha = 1;
        [self.viewPopupWrapper layoutIfNeeded];
    }];
}

- (void) animateToHidePopup{
    if (self.isPopupShowing == NO) return;
    
    self.isPopupShowing = NO;
    int height = (int) self.viewPopupPanel.frame.size.height;

    self.constraintPopupPanelTopSpacing.constant = 0;
    self.viewPopupWrapper.alpha = 1;
    [self.viewPopupWrapper layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.constraintPopupPanelTopSpacing.constant = -height;
        self.viewPopupWrapper.alpha = 0;
        [self.viewPopupWrapper layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished == YES){
            self.viewPopupWrapper.hidden = YES;
        }
    }];
}

- (void) animateScrollViewPopupToStep: (int) step{
    if (self.nPopupStep == step) return;
    self.nPopupStep = step;
    
    float width = self.scrollviewPopup.frame.size.width;
    [self.scrollviewPopup setContentOffset:CGPointMake(width * step, 0) animated:YES];
}

#pragma mark - Biz Logic

- (BOOL) isJobSelected{
    for (int i = 0; i < (int) [self.arrJobSelected count]; i++){
        BOOL selected = [[self.arrJobSelected objectAtIndex:i] boolValue];
        if (selected == YES) return YES;
    }
    return NO;
}

- (void) doSubmitRecruit{
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    GANRecruitManager *managerRecruit = [GANRecruitManager sharedInstance];
    NSMutableArray *arrJobIds = [[NSMutableArray alloc] init];
    NSMutableArray *arrReRecruitUserIds = [[NSMutableArray alloc] init];
    float fBroadcast = 0;
    
    for (int i = 0; i < (int) [self.arrJobSelected count]; i++){
        BOOL isSelected = [[self.arrJobSelected objectAtIndex:i] boolValue];
        if (isSelected == YES){
            GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:i];
            [arrJobIds addObject:job.szId];
        }
    }
    
    for (int i = 0; i < (int) [self.arrWorkerSelected count]; i++){
        BOOL isSelected = [[self.arrWorkerSelected objectAtIndex:i] boolValue];
        if (isSelected == YES){
            GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:i];
            [arrReRecruitUserIds addObject:myWorker.szWorkerUserId];
        }
    }
    
    NSString *sz = self.txtMiles.text;
    if (sz.length > 0){
        fBroadcast = [GANGenericFunctionManager refineFloat:sz DefaultValue:-1];
    }
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerRecruit requestSubmitRecruitWithJobIds:arrJobIds Broadcast:fBroadcast ReRecruitUserIds:arrReRecruitUserIds Callback:^(int status, int count) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:[NSString stringWithFormat:@"Worker(s) are recruited."] DismissAfter:-1 Callback:nil];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error." DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) gotoAddWorkerVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_ADDWORKER"];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UITableView Delegate

- (void) configureJobItemCell: (GANJobItemTVC *) cell AtIndex: (int) index{
    GANJobDataModel *job = [[GANJobManager sharedInstance].arrMyJobs objectAtIndex:index];
    cell.lblTitle.text = [job getTitleEN];
    cell.lblPrice.text = [NSString stringWithFormat:@"$%.02f", job.fPayRate];
    cell.lblUnit.text = (job.enumPayUnit == GANENUM_PAY_UNIT_HOUR) ? @"per hour" : @"per lb";
    cell.lblDate.text = [NSString stringWithFormat:@"%@ - %@", [GANGenericFunctionManager getBeautifiedDate:job.dateFrom], [GANGenericFunctionManager getBeautifiedDate:job.dateTo]];
    [cell showPayRate:[job isPayRateSpecified]];
    
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL isSelected = [[self.arrJobSelected objectAtIndex:index] boolValue];
    [cell setItemSelected:isSelected];
}

- (void) configureWorkerItemCell: (GANWorkerItemTVC *) cell AtIndex: (int) index{
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:index];
    cell.lblWorkerId.text = myWorker.modelWorker.szUserName;
    
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL isSelected = [[self.arrWorkerSelected objectAtIndex:index] boolValue];
    [cell setItemSelected:isSelected];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableviewJobs){
        return [[GANJobManager sharedInstance].arrMyJobs count];
    }
    return [[GANCompanyManager sharedInstance].arrMyWorkers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableviewJobs){
        GANJobItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_JOBLIST_ITEM"];
        [self configureJobItemCell:cell AtIndex:(int) indexPath.row];
        return cell;
    }
    else if (tableView == self.tableviewWorkers){
        GANWorkerItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKERITEM"];
        [self configureWorkerItemCell:cell AtIndex:(int) indexPath.row];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableviewJobs){
        return 76;
    }
    else if (tableView == self.tableviewWorkers){
        return 50;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    if (tableView == self.tableviewJobs){
        BOOL isSelected = [[self.arrJobSelected objectAtIndex:index] boolValue];
        [self.arrJobSelected replaceObjectAtIndex:index withObject:@(!isSelected)];
        [self.tableviewJobs reloadData];
    }
    else if (tableView == self.tableviewWorkers){
        BOOL isSelected = [[self.arrWorkerSelected objectAtIndex:index] boolValue];
        [self.arrWorkerSelected replaceObjectAtIndex:index withObject:@(!isSelected)];
        [self.tableviewWorkers reloadData];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnContinueClick:(id)sender {
    if ([self isJobSelected] == NO){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select jobs!" DismissAfter:-1 Callback:nil];
        return;
    }
    [self animateToShowPopup];
}

- (IBAction)onBtnAddWorkerClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoAddWorkerVC];
}

- (IBAction)onBtnSubmitClick:(id)sender {
    [self.view endEditing:YES];
    if (self.nPopupStep == 0){
        [self animateScrollViewPopupToStep:1];
        [self.btnSubmit setTitle:@"Submit" forState:UIControlStateNormal];
    }
    else {
        [self animateToHidePopup];
        [self doSubmitRecruit];
    }
}

- (IBAction)onBtnPopupWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self animateToHidePopup];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATED]) ||
        ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED])){
        [self buildJobsList];
    }
    else if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED]) ||
        ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED])){
        [self buildWorkerList];
    }
}

@end
