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

#import "GANUIPhoneTextField.h"

#import "GANUserWorkerDataModel.h"
#import "GANCompanyManager.h"
#import "GANUserManager.h"

#import "GANUtils.h"
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
}GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS;

@interface GANCompanyAddWorkerVC () <UITableViewDelegate, UITableViewDataSource, GANCompanyAddWorkerItemTVCDelegate, GANJobRecruitPopupVCDelegate>
{
    NSInteger nSelectedIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UIView *viewPhone;
@property (weak, nonatomic) IBOutlet GANUIPhoneTextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSuggested;

@property (strong, nonatomic) NSMutableArray *arrWorkersFound;
@property (strong, nonatomic) NSMutableArray *arrWorkerAdded;

@property (assign, atomic) GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS enumStatus;

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
    
    self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NONE;
    self.arrWorkersFound = [[NSMutableArray alloc] init];
    self.arrWorkerAdded = [[NSMutableArray alloc] init];
    
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
            [GANGlobalVCManager showAlertControllerWithVC:self Title:@"Contacts Disabled" Message:@"You will need to allow the access to contacts manually to add family members." Callback:nil];
        }
    }];
}

- (void) buildFilteredArray{
    
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

- (void) searchWorkers{
    NSString *szPhoneNumber = self.txtPhone.text;
    szPhoneNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:szPhoneNumber];
    if (szPhoneNumber.length == 0){
        [self shakeInvalidFields:self.viewPhone];
        return;
    }
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANCompanyManager sharedInstance] requestSearchNewWorkersByPhoneNumber:szPhoneNumber Callback:^(int status, NSArray *arrWorkers) {
        if (status == SUCCESS_WITH_NO_ERROR && arrWorkers != nil){
            int count = (int) [arrWorkers count];
            if (count == 0){
                self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND;
                [self refreshViews];
                [GANGlobalVCManager showHudInfoWithMessage:@"No new worker found!" DismissAfter:-1 Callback:nil];
            }
            else {
                [self buildSearchResultWithArray:arrWorkers];
                self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_FOUND;
                [self refreshViews];
                [GANGlobalVCManager showHudSuccessWithMessage:[NSString stringWithFormat:@"%d worker(s) found!", (int) [arrWorkers count]] DismissAfter:-1 Callback:nil];
            }
        }
        else if (status == ERROR_NOT_FOUND){
            self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND;
            [self refreshViews];
            [GANGlobalVCManager showHudInfoWithMessage:@"No worker found!" DismissAfter:-1 Callback:nil];
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

- (void) doAddMyWorkers{
    NSMutableArray *arrUserIds = [[NSMutableArray alloc] init];
    
    GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:nSelectedIndex];
    
    [arrUserIds addObject:worker.szId];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANCompanyManager sharedInstance] requestAddMyWorkerWithUserIds:arrUserIds Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker is added successfully." DismissAfter:-3 Callback:^{
                [self.arrWorkerAdded addObject:worker.modelPhone];
                [self.tableview reloadData];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error." DismissAfter:-1 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Company - Add worker");
}

- (void) doInvite{
    NSString *szCompanyId = [GANUserManager getCompanyDataModel].szId;
    GANPhoneDataModel *phone = [[GANPhoneDataModel alloc] init];
    if(self.enumStatus == GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND) {
        phone.szLocalNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:self.txtPhone.text];
    } else {
        GANPhonebookContactDataModel *worker = [self.arrWorkersFound objectAtIndex:nSelectedIndex];
        phone.szLocalNumber = worker.modelPhone.szLocalNumber;
    }
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANCompanyManager sharedInstance] requestSendInvite:phone CompanyId:szCompanyId Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Invitation SMS will be sent shortly." DismissAfter:-1 Callback:nil];
            [self.arrWorkerAdded addObject:phone];
            [self.tableview reloadData];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error" DismissAfter:-1 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Company - Send invite");
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
    
    for(int i = 0; i < self.arrWorkerAdded.count; i ++) {
        GANPhoneDataModel *model = [self.arrWorkerAdded objectAtIndex:i];
        if([[model getBeautifiedPhoneNumber] isEqualToString:cell.lblPhoneNumber.text]) {
            cell.btnAdd.titleLabel.text = @"Added";
        } else {
            cell.btnAdd.titleLabel.text = @"Add";
        }
    }
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

- (IBAction)onBtnSearchClick:(id)sender {
    [self.view endEditing:YES];
    [self searchWorkers];
}

- (IBAction)onBtnContinueClick:(id)sender {
    [self.view endEditing:YES];
    
    if(self.fromCustomVC == ENUM_COMPANY_ADDWORKERS_FROM_HOME) {
        [self.tabBarController setSelectedIndex:2];
        [self.navigationController popToRootViewControllerAnimated:NO];
    } else if(self.fromCustomVC == ENUM_COMPANY_ADDWORKERS_FROM_MESSAGE) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if(self.fromCustomVC == ENUM_COMPANY_ADDWORKERS_FROM_RECRUITJOB) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if(self.fromCustomVC == ENUM_COMPANY_ADDWORKERS_FROM_RETAINMYWORKERS) {
        [self.tabBarController setSelectedIndex:2];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (IBAction)onBtnInviteClick:(id)sender {
    [self.view endEditing:YES];
    
    GANJobRecruitPopupVC *vc = [[GANJobRecruitPopupVC alloc] initWithNibName:@"GANJobRecruitPopupVC" bundle:nil];
    
    vc.delegate = self;
    vc.view.backgroundColor = [UIColor clearColor];
    
    [vc setRecruitButtonTitle:@"Invite them to Ganaz"];
    [vc setEditButtonTitle:@"Go back"];
    
    NSString *strDescription = [NSString stringWithFormat:@"%@ is not\n using Ganaz yet", self.txtPhone.text];
    [vc setDescriptionTitle:strDescription];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - GANCompanySuggestWorkersItemTVCDelegate
- (void)onAddWorker:(NSInteger)nIndex {
    
    if (self.enumStatus == GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_FOUND){
        
        GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:nIndex];
    
        for(int i = 0; i < self.arrWorkerAdded.count; i ++) {
            GANPhoneDataModel *model = [self.arrWorkerAdded objectAtIndex:i];
            if([[model getBeautifiedPhoneNumber] isEqualToString:[worker.modelPhone getBeautifiedPhoneNumber]]) {
                return;
            }
        }
        
        nSelectedIndex = nIndex;
        
        [self doAddMyWorkers];
    } else {
        // Invite
        nSelectedIndex = nIndex;
        
        GANPhonebookContactDataModel *worker = [self.arrWorkersFound objectAtIndex:nSelectedIndex];
        
        GANJobRecruitPopupVC *vc = [[GANJobRecruitPopupVC alloc] initWithNibName:@"GANJobRecruitPopupVC" bundle:nil];
        
        vc.delegate = self;
        vc.view.backgroundColor = [UIColor clearColor];
        
        [vc setRecruitButtonTitle:@"Invite them to Ganaz"];
        [vc setEditButtonTitle:@"Go back"];
        
        NSString *strDescription = [NSString stringWithFormat:@"%@ is not\n using Ganaz yet", [worker getFullName]];
        [vc setDescriptionTitle:strDescription];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - GANJobRecruitPopupVCDelegate
- (void) didRecruit {
    // Add
    [self doInvite];
}

- (void) didEdit {
    
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
