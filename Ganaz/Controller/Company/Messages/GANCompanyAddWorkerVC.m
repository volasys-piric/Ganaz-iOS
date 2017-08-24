//
//  GANCompanyAddWorkerVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyAddWorkerVC.h"
#import "GANCompanyAddWorkerItemTVC.h"
#import "GANJobRecruitPopupVC.h"

#import "GANUserWorkerDataModel.h"
#import "GANCompanyManager.h"
#import "GANUserManager.h"
#import "GANFadeTransitionDelegate.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"
#import "GANGlobalVCManager.h"
#import <UIView+Shake.h>
#import "GANAppManager.h"
#import "GANPhonebookContactsManager.h"

typedef enum _ENUM_FOUNDSTATUS{
    GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NONE,
    GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_FOUND,
    GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND
} GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS;

@interface GANCompanyAddWorkerVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GANCompanyAddWorkerItemTVCDelegate, GANJobRecruitPopupVCDelegate>
{
    NSInteger nSelectedIndex;
}

@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UIView *viewPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSuggested;

@property (strong, nonatomic) NSMutableArray *arrWorkersFound;
@property (strong, nonatomic) NSMutableArray *arrInvitedWorkers;

@property (assign, atomic) GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS enumStatus;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@end

@implementation GANCompanyAddWorkerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.viewPhone.layer.cornerRadius = 3;
    self.btnAdd.layer.cornerRadius = 3;
    self.btnAdd.clipsToBounds = YES;
    self.btnInvite.layer.cornerRadius = 3;
    self.btnInvite.clipsToBounds = YES;
    
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    
    self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NONE;
    self.arrWorkersFound = [[NSMutableArray alloc] init];
    self.arrInvitedWorkers = [[NSMutableArray alloc] init];
    
    self.lblDescription.text = self.szDescription;
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
    [self askPermissionForPhoneBook];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"GANCompanyAddWorkerItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_COMPANY_ADDWORKERITEM"];
}

- (void) refreshViews{
    if (self.enumStatus == GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NONE){
        self.tableview.hidden = NO;
        self.lblSuggested.hidden = NO;
        self.lblTitle.text = @"Enter phone number";
        self.lblNote.text = @"If you have a large number of workers to add, you can send Ganaz a list of those workers at info@ganazapp.com and we’ll happily add them for you.";
        self.btnInvite.hidden = YES;
        self.btnAdd.hidden = NO;
    }
    else if (self.enumStatus == GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_FOUND){
        self.tableview.hidden = NO;
        self.lblTitle.text = @"Worker(s) found";
        self.lblNote.text = @"";
        self.lblSuggested.hidden = NO;
        self.btnInvite.hidden = YES;
        self.btnAdd.hidden = NO;
    }
    else if (self.enumStatus == GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND){
        self.tableview.hidden = YES;
        self.lblTitle.text = @"Worker not found";
        self.lblNote.text = @"Note: any worker you invite to Ganaz will receive recruiting messages exclusively from you for 12 months unless they otherwise opt-out";
        self.lblSuggested.hidden = YES;
        self.btnInvite.hidden = NO;
        self.btnAdd.hidden = NO;
    }
}

#pragma mark - Biz Logic

- (void) askPermissionForPhoneBook{
    [[GANPhonebookContactsManager sharedInstance] requestPermissionForAddressBookWithCallback:^(BOOL granted) {
        if (granted){
            [[GANPhonebookContactsManager sharedInstance] buildContactsList];
            [self buildFilteredArray];
        }
        else {
            [GANGlobalVCManager showAlertControllerWithVC:self Title:@"Permission Not Granted" Message:@"You will need to allow the access to contacts manually later." Callback:nil];
        }
    }];
}

- (void) buildFilteredArray{
    
    [self.arrInvitedWorkers removeAllObjects];
    [self.arrWorkersFound removeAllObjects];
    
    GANPhonebookContactsManager *managerPhonebook = [GANPhonebookContactsManager sharedInstance];
    if (managerPhonebook.isContactsListBuilt == NO){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
        });
        return;
    }
    
    NSString *keyword = [self.txtPhone.text lowercaseString];
    keyword = [keyword stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    if (keyword.length == 0){
        [self.arrWorkersFound addObjectsFromArray:managerPhonebook.arrContacts];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
        });
        return;
    }
    
    for (int i = 0; i < (int) [managerPhonebook.arrContacts count]; i++){
        GANPhonebookContactDataModel *contact = [managerPhonebook.arrContacts objectAtIndex:i];
        NSString *sz = [NSString stringWithFormat:@"%@ %@ %@ %@", [contact getFullName], contact.modelPhone.szLocalNumber, [contact.modelPhone getBeautifiedPhoneNumber], contact.szEmail];
        sz = [sz lowercaseString];
        if ([sz rangeOfString:keyword].location != NSNotFound){
            [self.arrWorkersFound addObject:contact];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}

- (void) shakeInvalidFields: (UIView *) viewContainer{
    [viewContainer shake:6 withDelta:8 speed:0.07];
}

- (void) searchWorkers:(BOOL) fromSeachField {
    
    if([self isInvitedUser:self.txtPhone.text])
    {
        [GANGlobalVCManager showHudErrorWithMessage:@"User is already added." DismissAfter:-1 Callback:nil];
        return;
    }
    
    NSString *szPhoneNumber = self.txtPhone.text;
    NSString *szWorkerName = self.txtPhone.text;
    
    if(fromSeachField == NO) {
        GANPhonebookContactDataModel *worker = [self.arrWorkersFound objectAtIndex:nSelectedIndex];
        szPhoneNumber = worker.modelPhone.szLocalNumber;
        szWorkerName = [worker getFullName];
    } else {
        if ([szPhoneNumber isEqualToString:@""]){
            [self shakeInvalidFields:self.viewPhone];
            return;
        }
        
        szPhoneNumber = [GANGenericFunctionManager getValidPhoneNumber:szPhoneNumber];
        if([szPhoneNumber isEqualToString:@""]) {
            [GANGlobalVCManager showHudErrorWithMessage:@"Please input valid phone number." DismissAfter:-1 Callback:nil];
            return;
        }
    }
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANCompanyManager sharedInstance] requestSearchNewWorkersByPhoneNumber:szPhoneNumber Callback:^(int status, NSArray *arrWorkers) {
        if (status == SUCCESS_WITH_NO_ERROR && arrWorkers != nil){
            int count = (int) [arrWorkers count];
            if (count == 0){
                self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND;
                if(fromSeachField) {
                    [self refreshViews];
                    [GANGlobalVCManager showHudInfoWithMessage:@"No new worker found!" DismissAfter:-1 Callback:nil];
                } else {
                    [self showPopupDialog:szWorkerName];
                }
            } else {
                 if(fromSeachField) {
                     [self buildSearchResultWithArray:arrWorkers];
                     self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_FOUND;
                     [self refreshViews];
                     [GANGlobalVCManager showHudSuccessWithMessage:[NSString stringWithFormat:@"%d worker(s) found!", (int) [arrWorkers count]] DismissAfter:-1 Callback:nil];
                 } else {
                     for(int i = 0; i < arrWorkers.count; i ++) {
                         GANUserWorkerDataModel *model = [arrWorkers objectAtIndex:i];
                         if([model.modelPhone.szLocalNumber isEqualToString:szPhoneNumber]) {
                             [self doAddMyWorkers:model];
                             break;
                         }
                     }
                 }
            }
        }
        else if (status == ERROR_NOT_FOUND){
            self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND;
            if(fromSeachField) {
                [self refreshViews];
                [GANGlobalVCManager showHudInfoWithMessage:@"No worker found!" DismissAfter:-1 Callback:nil];
            } else {
                [self showPopupDialog:szWorkerName];
            }
            
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) buildSearchResultWithArray: (NSArray *) arr{
    [self.arrWorkersFound removeAllObjects];
    [self.arrWorkersFound addObjectsFromArray:arr];
    
    [self.tableview reloadData];
}

- (void) doAddMyWorkers:(GANUserWorkerDataModel *)worker {
    NSMutableArray *arrUserIds = [[NSMutableArray alloc] init];
    
    [arrUserIds addObject:worker.szId];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANCompanyManager sharedInstance] requestAddMyWorkerWithUserIds:arrUserIds Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [self.arrInvitedWorkers addObject:worker.modelPhone.szLocalNumber];
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker is added successfully." DismissAfter:-3 Callback:^{
                [self.tableview reloadData];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Company - Add worker");
}

- (void) InviteMyWorker
{
    NSString *szCompanyId = [GANUserManager getCompanyDataModel].szId;
    GANPhoneDataModel *phone = [[GANPhoneDataModel alloc] init];
    if(nSelectedIndex < 0) {
        phone.szLocalNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:self.txtPhone.text];
    } else {
        GANPhonebookContactDataModel *worker = [self.arrWorkersFound objectAtIndex:nSelectedIndex];
        phone.szLocalNumber = worker.modelPhone.szLocalNumber;
    }
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANCompanyManager sharedInstance] requestSendInvite:phone CompanyId:szCompanyId Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [self.arrInvitedWorkers addObject:phone.szLocalNumber];
            [GANGlobalVCManager showHudSuccessWithMessage:@"Invitation SMS will be sent shortly." DismissAfter:-1 Callback:nil];
            [self.tableview reloadData];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Company - Send invite");
}

- (IBAction)onBtnSearchClick:(id)sender {
    [self.view endEditing:YES];
    [self searchWorkers: YES];
}

- (IBAction)onBtnContinueClick:(id)sender {
    [self.view endEditing:YES];
    
    if(self.fromCustomVC == ENUM_COMPANY_ADDWORKERS_FROM_HOME) {
        [GANGlobalVCManager tabBarController:self.tabBarController shouldSelectViewController:2];
        [self.navigationController popToRootViewControllerAnimated:NO];
    } else if(self.fromCustomVC == ENUM_COMPANY_ADDWORKERS_FROM_MESSAGE) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if(self.fromCustomVC == ENUM_COMPANY_ADDWORKERS_FROM_RECRUITJOB) {
        [GANGlobalVCManager tabBarController:self.tabBarController shouldSelectViewController:2];
        [self.navigationController popViewControllerAnimated:NO];
    } else if(self.fromCustomVC == ENUM_COMPANY_ADDWORKERS_FROM_RETAINMYWORKERS) {
        [GANGlobalVCManager tabBarController:self.tabBarController shouldSelectViewController:2];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (IBAction)onBtnInviteClick:(id)sender {
    [self.view endEditing:YES];

    nSelectedIndex = -1;
    [self showPopupDialog: self.txtPhone.text];
}

- (BOOL) isInvitedUser:(NSString*)szPhoneNumber {
    for(int i = 0; i < self.arrInvitedWorkers.count; i ++) {
        NSString *szUserPhone = [self.arrInvitedWorkers objectAtIndex:i];
        if([szUserPhone isEqualToString:szPhoneNumber])
            return YES;
    }
    return NO;
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANCompanyAddWorkerItemTVC *) cell AtIndex: (int) index{
    GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:index];
    cell.lblName.text = [worker getFullName];
    cell.lblPhoneNumber.text = [worker.modelPhone getBeautifiedPhoneNumber];
    cell.containerView.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nIndex = index;
    cell.delegate = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrWorkersFound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANCompanyAddWorkerItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_COMPANY_ADDWORKERITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - GANCompanySuggestWorkersItemTVCDelegate
- (void)onAddWorker:(NSInteger)nIndex {
    
    if(self.enumStatus == GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_FOUND) {
        GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:nIndex];
        [self doAddMyWorkers:worker];
    } else {
        nSelectedIndex = nIndex;
        [self searchWorkers:NO];
    }
}

#pragma mark - GANJobRecruitPopupVCDelegate
- (void) showPopupDialog:(NSString*) szWorkerName {
    
    GANJobRecruitPopupVC *vc = [[GANJobRecruitPopupVC alloc] initWithNibName:@"GANJobRecruitPopupVC" bundle:nil];
    
    vc.delegate = self;
    vc.view.backgroundColor = [UIColor clearColor];
    
    [vc setRecruitButtonTitle:@"Invite them to Ganaz"];
    [vc setEditButtonTitle:@"Go back"];
    
    NSString *strDescription = [NSString stringWithFormat:@"%@ is not\n using Ganaz yet", szWorkerName];
    [vc setDescriptionTitle:strDescription];
    
    [vc setTransitioningDelegate:self.transController];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) didRecruit {
    
    [self InviteMyWorker];
}

- (void) didEdit {
    [GANGlobalVCManager hideHudProgress];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onSeachTextFieldChanged:(id)sender {
    [self buildFilteredArray];
}
@end
