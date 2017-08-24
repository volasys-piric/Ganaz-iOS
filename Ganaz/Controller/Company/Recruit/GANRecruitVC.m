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

#import "GANJobManager.h"
#import "GANUserManager.h"
#import "GANCacheManager.h"
#import "GANCompanyManager.h"
#import "GANRecruitManager.h"
#import "GANFadeTransitionDelegate.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"
#import "GANAppManager.h"

@interface GANRecruitVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GANJobPostingSharedPopupVCDelegate, GANMyWorkerNickNameEditPopupVCDelegate, GANWorkerItemTVCDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblJobTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableviewWorkers;

@property (weak, nonatomic) IBOutlet UIView *viewBroadcastPanel;

@property (weak, nonatomic) IBOutlet UITextField *txtMiles;
@property (weak, nonatomic) IBOutlet UIButton *btnShareJob;
@property (weak, nonatomic) IBOutlet UIButton *btnAddWorker;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@property (strong, nonatomic) NSMutableArray *arrWorkerSelected;

@end

@implementation GANRecruitVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableviewWorkers.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableviewWorkers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableviewWorkers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.transController = [[GANFadeTransitionDelegate alloc] init];
    self.arrWorkerSelected = [[NSMutableArray alloc] init];

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
    [self.tableviewWorkers registerNib:[UINib nibWithNibName:@"WorkerItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKERITEM"];
}

- (void) refreshViews{
    self.viewBroadcastPanel.layer.cornerRadius = 3;
    self.btnShareJob.layer.cornerRadius = 3;
    self.btnAddWorker.layer.cornerRadius = 3;
    
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
        fBroadcast = [GANGenericFunctionManager refineFloat:sz DefaultValue:-1];
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
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) gotoAddWorkerVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANCompanyAddWorkerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_ADDWORKER"];
    vc.fromCustomVC = ENUM_COMPANY_ADDWORKERS_FROM_RECRUITJOB;
    vc.szDescription = @"Who would you like to add?";
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
    cell.nIndex = index;
    cell.delegate = self;
    
    cell.btnEdit.layer.cornerRadius = 3.f;
    cell.btnEdit.clipsToBounds = YES;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        GANMyWorkerNickNameEditPopupVC *vc = [[GANMyWorkerNickNameEditPopupVC alloc] initWithNibName:@"GANMyWorkerNickNameEditPopupVC" bundle:nil];
        vc.delegate = self;
        vc.nIndex = index;
        
        vc.view.backgroundColor = [UIColor clearColor];
        [vc setTransitioningDelegate:self.transController];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:nil];
    });
}

#pragma mark - GANWorkerITEMTVCDelegate
- (void) setWorkerNickName:(NSInteger)nIndex {
    [self changeMyWorkerNickName:nIndex];
}

#pragma mark - GANMyWorkerNickNameEditPopupVCDelegate
- (void) setMyWorkerNickName:(NSString*)szNickName index:(NSInteger) nIndex {
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:nIndex];
    myWorker.szNickname = szNickName;
    
    //Add NickName
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerCompany requestUpdateMyWorkerNicknameWithMyWorkerId:myWorker.szId Nickname:szNickName Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Nickname is updated successfully." DismissAfter:-1 Callback:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewWorkers reloadData];
            });
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
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
