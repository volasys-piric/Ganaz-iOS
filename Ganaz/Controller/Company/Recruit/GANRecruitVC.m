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
#import "GANJobPostingSharedPopupVC.h"
#import "GANCompanyAddWorkerVC.h"
#import "GANMyWorkerNickNameEditPopupVC.h"
#import "GANOnboardingWorkerNickNamePopupVC.h"

#import "GANJobManager.h"
#import "GANUserManager.h"
#import "GANCacheManager.h"
#import "GANCompanyManager.h"
#import "GANRecruitManager.h"
#import "GANFadeTransitionDelegate.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"
#import "GANAppManager.h"
#import "UIColor+GANColor.h"

#define NON_SELECTED -1

@interface GANRecruitVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, GANJobPostingSharedPopupVCDelegate, GANOnboardingWorkerNickNamePopupVCDelegate, GANMyWorkerNickNameEditPopupVCDelegate, GANWorkerItemTVCDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblJobTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableviewWorkers;

@property (weak, nonatomic) IBOutlet UIView *viewBroadcastPanel;

@property (weak, nonatomic) IBOutlet UITextField *txtMiles;
@property (weak, nonatomic) IBOutlet UIButton *btnShareJob;
@property (weak, nonatomic) IBOutlet UIButton *btnAddWorker;
@property (weak, nonatomic) IBOutlet UIButton *buttonSelectAll;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@property (strong, nonatomic) NSMutableArray *arrWorkerSelected;
@property (assign, atomic) int indexSelected;
@property (assign, atomic) BOOL isFirstLoad;

@end

@implementation GANRecruitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableviewWorkers.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableviewWorkers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableviewWorkers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.indexSelected = NON_SELECTED;
    
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    self.arrWorkerSelected = [[NSMutableArray alloc] init];
    self.isFirstLoad = YES;
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self buildWorkerList];
    
    if (self.isFirstLoad == NO) {
        [self refreshAllList];
    }
    self.isFirstLoad = NO;
}

- (void) refreshAllList {
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    [managerCompany requestGetMyWorkersListWithCallback:^(int status) {
        [managerCompany requestGetCrewsListWithCallback:^(int status) {
            [self buildWorkerList];
        }];
    }];
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
    [self.tableviewWorkers registerNib:[UINib nibWithNibName:@"WorkerItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKERITEM"];
}

- (void) refreshViews{
    self.viewBroadcastPanel.layer.cornerRadius = 3;
    self.btnShareJob.layer.cornerRadius = 3;
    self.btnAddWorker.layer.cornerRadius = 3;
    self.buttonSelectAll.layer.cornerRadius = 3;
    
    self.btnShareJob.clipsToBounds = YES;
    self.btnAddWorker.clipsToBounds = YES;
    self.buttonSelectAll.clipsToBounds = YES;
    
    self.btnAddWorker.backgroundColor = [UIColor GANThemeGreenColor];
    
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:self.nJobIndex];
    self.lblJobTitle.text = [job getTitleEN];
}

- (void) buildWorkerList{
    [self.arrWorkerSelected removeAllObjects];
    int count = (int) [[GANCompanyManager sharedInstance].arrMyWorkers count];
    
    for (int i = 0; i < count; i++){
        [self.arrWorkerSelected addObject:@(NO)];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableviewWorkers reloadData];
        [self refreshSelectAllButton];
    });
}

- (void) refreshSelectAllButton{
    if ([self.arrWorkerSelected count] == 0) {
        self.buttonSelectAll.hidden = YES;
        return;
    }
    
    self.buttonSelectAll.hidden = NO;
    int count = [self getSelectedCount];
    if (count == (int) [self.arrWorkerSelected count]) {
        // All selected
        [self.buttonSelectAll setTitle:@"Deselect\rworkers" forState:UIControlStateNormal];
        self.buttonSelectAll.backgroundColor = [UIColor GANThemeMainColor];
    }
    else {
        [self.buttonSelectAll setTitle:@"Select all\rworkers" forState:UIControlStateNormal];
        self.buttonSelectAll.backgroundColor = [UIColor GANThemeGreenColor];
    }
}

- (int) getSelectedCount{
    int count = 0;
    for (int i = 0; i < (int) [self.arrWorkerSelected count]; i++) {
        if ([[self.arrWorkerSelected objectAtIndex:i] boolValue] == YES) count++;
    }
    return count;
}

- (void) doSelectAll{
    int count = [self getSelectedCount];
    if (count == (int) [self.arrWorkerSelected count]) {
        // Deselect
        for (int i = 0; i < (int) [self.arrWorkerSelected count]; i++){
            [self.arrWorkerSelected replaceObjectAtIndex:i withObject:@(NO)];
        }
    }
    else {
        // Select all
        for (int i = 0; i < (int) [self.arrWorkerSelected count]; i++){
            [self.arrWorkerSelected replaceObjectAtIndex:i withObject:@(YES)];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableviewWorkers reloadData];
        [self refreshSelectAllButton];
    });
}

#pragma mark - Biz Logic

- (void) doSubmitRecruit{
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    GANRecruitManager *managerRecruit = [GANRecruitManager sharedInstance];
    NSMutableArray *arrReRecruitUserIds = [[NSMutableArray alloc] init];
    
    float fBroadcast = 0;
    NSMutableArray *arrJobIds = [[NSMutableArray alloc] init];
    GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:self.nJobIndex];
    [arrJobIds addObject:job.szId];
    
    for (int i = 0; i < (int) [self.arrWorkerSelected count]; i++){
        BOOL isSelected = [[self.arrWorkerSelected objectAtIndex:i] boolValue];
        if (isSelected == YES){
            GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:i];
            [arrReRecruitUserIds addObject:myWorker.szWorkerUserId];
        }
    }
    
    NSString *sz = self.txtMiles.text;
    if (sz.length > 0){
        fBroadcast = [GANGenericFunctionManager refineFloat:sz DefaultValue:0];
    }
    
    if ([arrReRecruitUserIds count] == 0 && fBroadcast < 0.01){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select workers or set broadcast radius." DismissAfter:-1 Callback:nil];
        return;
    }
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerRecruit requestSubmitRecruitWithJobIds:arrJobIds Broadcast:fBroadcast ReRecruitUserIds:arrReRecruitUserIds PhoneNumbers:nil Callback:^(int status, int count) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgress];
            [self showPopupDialog:count];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
        GANACTIVITY_REPORT(@"Company - Recruit");
    }];
}

-(void) showPopupDialog:(int)nCount {
    
    GANJobPostingSharedPopupVC *vc = [[GANJobPostingSharedPopupVC alloc] initWithNibName:@"GANJobPostingSharedPopupVC" bundle:nil];
    
    vc.delegate = self;
    vc.view.backgroundColor = [UIColor clearColor];
    NSString *strDescription = [NSString stringWithFormat:@"Your job has been\nshared with %d\n workers.", nCount];
    
    [vc refreshFields:strDescription];
    [vc setTransitioningDelegate:self.transController];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}

- (void) gotoAddWorkerVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANCompanyAddWorkerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_ADDWORKER"];
    vc.fromCustomVC = ENUM_COMPANY_ADDWORKERS_FROM_RECRUITJOB;
    vc.szDescription = @"Who would you like to add?";
    vc.szCrewId = @"";
    
    [self.navigationController pushViewController:vc animated:YES];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to add-worker from Recruit");
}

#pragma mark - GANJobPostingSharedPopupDelegate
- (void)didOK {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableView Delegate

- (void) configureWorkerItemCell: (GANWorkerItemTVC *) cell AtIndex: (int) index{
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:index];
    cell.lblWorkerId.text = [myWorker getDisplayName];
    cell.index = index;
    cell.delegate = self;
    
    if(myWorker.modelWorker.enumType == GANENUM_USER_TYPE_WORKER) {
        [cell setButtonColor:YES];
    } else {
        [cell setButtonColor:NO];
    }
    
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL isSelected = [[self.arrWorkerSelected objectAtIndex:index] boolValue];
    [cell setItemSelected:isSelected];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[GANCompanyManager sharedInstance].arrMyWorkers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkerItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKERITEM"];
    [self configureWorkerItemCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    BOOL isSelected = [[self.arrWorkerSelected objectAtIndex:index] boolValue];
    [self.arrWorkerSelected replaceObjectAtIndex:index withObject:@(!isSelected)];
    [self.tableviewWorkers reloadData];
}

- (void) changeMyWorkerNickName: (NSInteger) index{
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:index];
    
    if(myWorker.modelWorker.enumType == GANENUM_USER_TYPE_ONBOARDING_WORKER){
        GANOnboardingWorkerNickNamePopupVC *vc = [[GANOnboardingWorkerNickNamePopupVC alloc] initWithNibName:@"GANOnboardingWorkerNickNamePopupVC" bundle:nil];
        vc.delegate = self;
        
        vc.view.backgroundColor = [UIColor clearColor];
        [vc setTransitioningDelegate:self.transController];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
        [vc setTitle:[myWorker.modelWorker.modelPhone getBeautifiedPhoneNumber]];
        if(![myWorker.szNickname isEqualToString:@""] || myWorker.szNickname != nil)
            vc.textfieldNickname.text = myWorker.szNickname;
    }
    else {
        GANMyWorkerNickNameEditPopupVC *vc = [[GANMyWorkerNickNameEditPopupVC alloc] initWithNibName:@"GANMyWorkerNickNameEditPopupVC" bundle:nil];
        vc.delegate = self;
        
        vc.view.backgroundColor = [UIColor clearColor];
        [vc setTransitioningDelegate:self.transController];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        [vc setTitle:[myWorker.modelWorker.modelPhone getBeautifiedPhoneNumber]];
        if(![myWorker.szNickname isEqualToString:@""] || myWorker.szNickname != nil)
            vc.textfieldNickname.text = myWorker.szNickname;
    }
}

#pragma mark - GANWorkerITEMTVCDelegate

- (void) workerItemTableViewCellDidDotsClick:(GANWorkerItemTVC *)cell {
    self.indexSelected = cell.index;
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:cell.index];
    NSString *szUserName = [myWorker getDisplayName];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:szUserName message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *actionEdit = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeMyWorkerNickName:self.indexSelected];
        });
    }];
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *szMessage = [NSString stringWithFormat:@"Are you sure you want to delete %@ from your workers list?", szUserName];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [GANGlobalVCManager promptWithVC:self Title:nil Message:szMessage ButtonYes:@"Yes" ButtonNo:@"No" CallbackYes:^{
                [self deleteMyWorkerAtIndex:cell.index];
            } CallbackNo:nil];
        });
    }];
    
    [alertController addAction:actionDelete];
    
    if (myWorker.modelWorker.enumType == GANENUM_USER_TYPE_ONBOARDING_WORKER) {
        UIAlertAction *actionResendInvitation = [UIAlertAction actionWithTitle:@"Resend Invitation" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self resendInvite:self.indexSelected];
            });
        }];
        [alertController addAction:actionResendInvitation];
    }
    
    [alertController addAction:actionEdit];
    [alertController addAction:actionCancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void) resendInvite:(NSInteger) nIndex {
    NSString *szCompanyId = [GANUserManager getCompanyDataModel].szId;
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:nIndex];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANCompanyManager sharedInstance] requestSendInvite:myWorker.modelWorker.modelPhone CompanyId:szCompanyId inviteOnly:YES Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"An invitation will be sent shortly via SMS" DismissAfter:-1 Callback:nil];
            
            [self refreshMyWorkerList];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
        self.indexSelected = NON_SELECTED;
    }];
    GANACTIVITY_REPORT(@"Company - Send invite");
}

- (void) deleteMyWorkerAtIndex: (int) index {
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    GANMyWorkerDataModel *myWorker = [managerCompany.arrMyWorkers objectAtIndex:self.indexSelected];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerCompany requestDeleteMyWorker:myWorker.szId Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker has been successfully deleted." DismissAfter:-1 Callback:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableviewWorkers reloadData];
                });
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error" DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) refreshMyWorkerList {
    [[GANCompanyManager sharedInstance] requestGetMyWorkersListWithCallback:^(int status) {
        if(status == SUCCESS_WITH_NO_ERROR) {
            [self buildWorkerList];
        } else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
}

#pragma mark - GANMyWorkerNickNameEditPopupVCDelegate

- (void)nicknameEditPopupDidUpdateWithNickname:(NSString *)nickname {
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:self.indexSelected];
    myWorker.szNickname = nickname;
    
    //Add NickName
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerCompany requestUpdateMyWorkerNicknameWithMyWorkerId:myWorker.szId Nickname:nickname Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker's alias has been updated" DismissAfter:-1 Callback:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewWorkers reloadData];
            });
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
        self.indexSelected = NON_SELECTED;
    }];
}

- (void) onboardingNicknameEditPopupDidUpdateWithNickname:(NSString *)nickname {
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:self.indexSelected];
    myWorker.szNickname = nickname;
    
    //Add NickName
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerCompany requestUpdateMyWorkerNicknameWithMyWorkerId:myWorker.szId Nickname:nickname Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker's alias has been updated" DismissAfter:-1 Callback:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewWorkers reloadData];
            });
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
        self.indexSelected = NON_SELECTED;
    }];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnShareJobClick:(id)sender {
    [self.view endEditing:YES];
    [self doSubmitRecruit];
}

- (IBAction)onBtnAddWorkerClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoAddWorkerVC];
}

- (IBAction)onButtonSelectAllClick:(id)sender {
    [self.view endEditing:YES];
    [self doSelectAll];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATED]) ||
        ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED])){
//        [self buildJobsList];
    }
    else if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED]) ||
        ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED])){
        [self buildWorkerList];
    }
}

@end
