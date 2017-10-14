//
//  GANCompanyAddWorkerVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyAddWorkerVC.h"
#import "GANCompanyAddWorkerItemTVC.h"
#import "GANInviteWorkerPopupVC.h"

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
#import "GANMessageManager.h"

typedef enum _ENUM_FOUNDSTATUS{
    GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NONE,
    GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_FOUND,
    GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND
} GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS;

typedef enum _ENUM_SEARCHRESULTITEMTYPE{
    GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_PHONEBOOKCONTACT,
    GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_WORKER,
}GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE;

@interface GANCompanyAddWorkerVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GANCompanyAddWorkerItemTVCDelegate, GANInviteWorkerPopupVCDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UIView *viewPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong, nonatomic) NSMutableArray *arrWorkersFound;

@property (assign, atomic) GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS enumStatus;
@property (assign, atomic) GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE enumSearchResultItemType;
@property (assign, atomic) int indexSelectedSearchResultItem;

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
    self.enumSearchResultItemType = GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_PHONEBOOKCONTACT;
    self.arrWorkersFound = [[NSMutableArray alloc] init];
    
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
        self.lblTitle.text = @"Suggested:";
        self.lblNote.text = @"If you have a large number of workers to add, you can send Ganaz a list of those workers at info@ganazapp.com and we’ll happily add them for you.";
        self.btnInvite.hidden = YES;
        self.btnAdd.hidden = NO;
    }
    else if (self.enumStatus == GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_FOUND){
        self.tableview.hidden = NO;
        self.lblTitle.text = @"Worker(s) found";
        self.lblNote.text = @"";
        self.btnInvite.hidden = YES;
        self.btnAdd.hidden = NO;
    }
    else if (self.enumStatus == GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND){
        self.tableview.hidden = YES;
        self.lblTitle.text = @"";
        self.lblNote.text = @"Note: any worker you invite to Ganaz will receive recruiting messages exclusively from you for 12 months unless they otherwise opt-out";
        self.btnInvite.hidden = NO;
        self.btnAdd.hidden = NO;
    }
}

- (void) shakeInvalidFields: (UIView *) viewContainer{
    [viewContainer shake:6 withDelta:8 speed:0.07];
}

#pragma mark - Biz Logic

- (void) askPermissionForPhoneBook{
    [[GANPhonebookContactsManager sharedInstance] requestPermissionForAddressBookWithCallback:^(BOOL granted) {
        if (granted){
            [[GANPhonebookContactsManager sharedInstance] buildContactsList];
            [self buildFilteredArray];
        }
        else {
            [GANGlobalVCManager showAlertControllerWithVC:self Title:@"Permission Not Granted" Message:@"You'll need to allow access to contacts later." Callback:nil];
        }
    }];
}

- (void) buildFilteredArray{
    [self.arrWorkersFound removeAllObjects];
    self.enumSearchResultItemType = GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_PHONEBOOKCONTACT;
    
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

- (void) showDlgForInviteWorkerWithName:(NSString*) name{
    GANInviteWorkerPopupVC *vc = [[GANInviteWorkerPopupVC alloc] initWithNibName:@"GANInviteWorkerPopupVC" bundle:nil];
    vc.delegate = self;
    vc.view.backgroundColor = [UIColor clearColor];
    [vc setTransitioningDelegate:self.transController];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
    
    [vc setDescription:name];
}

- (void) doSearchWorkerWithPhonebookContactAtIndex: (int) indexPhonebookContact{
    GANPhonebookContactDataModel *worker = [self.arrWorkersFound objectAtIndex:indexPhonebookContact];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANCompanyManager sharedInstance] requestSearchNewWorkersByPhoneNumber:worker.modelPhone.szLocalNumber Callback:^(int status, NSArray *arrWorkers) {
        if (status == SUCCESS_WITH_NO_ERROR && arrWorkers != nil){
            int count = (int) [arrWorkers count];
            if (count == 0){
                self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND;
                [GANGlobalVCManager hideHudProgressWithCallback:^{
                    [self showDlgForInviteWorkerWithName:[worker getFullName]];
                }];
            }
            else {
                [GANGlobalVCManager hideHudProgress];
                [self doAddMyWorkers:(NSArray<GANUserWorkerDataModel *> *) arrWorkers];
            }
        }
        else if (status == ERROR_NOT_FOUND){
            self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND;
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                [self showDlgForInviteWorkerWithName:[worker getFullName]];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) doSearchWorkerWithSearchString: (NSString *) keyword{
    // keyword = Phone number
    NSString *szPhoneNumber = keyword;
    
    if ([szPhoneNumber isEqualToString:@""]){
        [self shakeInvalidFields:self.viewPhone];
        return;
    }
    
    szPhoneNumber = [GANGenericFunctionManager getValidPhoneNumber:szPhoneNumber];
    if([szPhoneNumber isEqualToString:@""]) {
        [GANGlobalVCManager showHudErrorWithMessage:@"Please enter a valid phone number" DismissAfter:-1 Callback:nil];
        return;
    }

    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANCompanyManager sharedInstance] requestSearchNewWorkersByPhoneNumber:keyword Callback:^(int status, NSArray *arrWorkers) {
        if (status == SUCCESS_WITH_NO_ERROR && arrWorkers != nil){
            int count = (int) [arrWorkers count];
            if (count == 0){
                self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NOTFOUND;
                [self refreshViews];
                [GANGlobalVCManager showHudInfoWithMessage:@"No new workers found" DismissAfter:-1 Callback:nil];
            } else {
                [self buildSearchResultWithArray:arrWorkers];
                self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_FOUND;
                self.enumSearchResultItemType = GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_WORKER;
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

- (void) buildSearchResultWithArray: (NSArray *) results{
    [self.arrWorkersFound removeAllObjects];
    [self.arrWorkersFound addObjectsFromArray:results];
    
    [self.tableview reloadData];
}

- (void) doAddMyWorkers:(NSArray<GANUserWorkerDataModel *> *) arrWorkers {
    NSMutableArray *arrUserIds = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (int) [arrWorkers count]; i++) {
        GANUserWorkerDataModel *worker = [arrWorkers objectAtIndex:i];
        [arrUserIds addObject:worker.szId];
    }
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANCompanyManager sharedInstance] requestAddMyWorkerWithUserIds:arrUserIds Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker has been added successfully" DismissAfter:-3 Callback:^{
                [self.tableview reloadData];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Company - Add worker");
}

- (void) doInviteWorker:(BOOL) isInviteOnly{
    NSString *szCompanyId = [GANUserManager getCompanyDataModel].szId;
    GANPhoneDataModel *phone = [[GANPhoneDataModel alloc] init];
    if(self.indexSelectedSearchResultItem < 0) {
        phone.szLocalNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:self.txtPhone.text];
    }
    else {
        if (self.enumSearchResultItemType == GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_WORKER){
            GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:self.indexSelectedSearchResultItem];
            phone.szLocalNumber = worker.modelPhone.szLocalNumber;
        }
        else if (self.enumSearchResultItemType == GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_PHONEBOOKCONTACT){
            GANPhonebookContactDataModel *phonebookContact = [self.arrWorkersFound objectAtIndex:self.indexSelectedSearchResultItem];
            phone.szLocalNumber = phonebookContact.modelPhone.szLocalNumber;
        }
    }
    
    if([[GANCompanyManager sharedInstance] checkUserInMyworkerList:phone.szLocalNumber]) {
        [GANGlobalVCManager showHudInfoWithMessage:@"User is already added" DismissAfter:-1 Callback:nil];
        return;
    }
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANCompanyManager sharedInstance] requestSendInvite:phone CompanyId:szCompanyId inviteOnly:isInviteOnly Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            if(isInviteOnly)
                [GANGlobalVCManager showHudSuccessWithMessage:@"An invitation will be sent shortly via SMS" DismissAfter:-1 Callback:nil];
            else {
                [GANGlobalVCManager showHudSuccessWithMessage:@"Worker has been added successfully" DismissAfter:-3 Callback:^{
                    [self refreshMyWorkerList];
                }];
            }
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Company - Send invite");
}

- (void) refreshMyWorkerList {
    [[GANCompanyManager sharedInstance] requestGetMyWorkersListWithCallback:^(int status) {
        if(status == SUCCESS_WITH_NO_ERROR) {
            [self.tableview reloadData];
        } else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
    [[GANMessageManager sharedInstance] requestGetMessageListWithCallback:nil];
}

- (IBAction)onBtnSearchClick:(id)sender {
    [self.view endEditing:YES];
    [self doSearchWorkerWithSearchString:self.txtPhone.text];
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

    self.indexSelectedSearchResultItem = -1;
    
    GANPhoneDataModel *phone = [[GANPhoneDataModel alloc] init];
    [phone setLocalNumber:self.txtPhone.text];
    
    [self showDlgForInviteWorkerWithName:[phone getBeautifiedPhoneNumber]];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANCompanyAddWorkerItemTVC *) cell AtIndex: (int) index{
    if (self.enumSearchResultItemType == GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_PHONEBOOKCONTACT){
        GANPhonebookContactDataModel *phonebookContact = [self.arrWorkersFound objectAtIndex:index];
        cell.labelName.text = [phonebookContact getFullName];
        cell.labelPhoneNumber.text = [phonebookContact.modelPhone getBeautifiedPhoneNumber];
        
        cell.labelName.hidden = NO;
        cell.labelPhoneNumber.hidden = NO;
        cell.labelNameOnly.hidden = YES;
    }
    else if (self.enumSearchResultItemType == GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_WORKER){
        GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:index];
        cell.labelNameOnly.text = [worker getValidUsername];

        cell.labelName.hidden = YES;
        cell.labelPhoneNumber.hidden = YES;
        cell.labelNameOnly.hidden = NO;
    }
    cell.indexCell = index;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (void)companyAddWorkerTableViewCellDidAddClick:(GANCompanyAddWorkerItemTVC *)cell{
    int index = cell.indexCell;
    if (self.enumSearchResultItemType == GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_WORKER){
        GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:index];
        [self doAddMyWorkers:@[worker]];
    }
    else if (self.enumSearchResultItemType == GANENUM_COMPANYADDWORKERVC_SEARCHRESULTITEMTYPE_PHONEBOOKCONTACT){
        self.indexSelectedSearchResultItem = index;
        [self doSearchWorkerWithPhonebookContactAtIndex:index];
    }
}

#pragma mark - GANInviteWorkerPopupVCDelegate

- (void) companyInviteWorkerPopupDidInviteWorker:(GANInviteWorkerPopupVC *)popup{
    [self doInviteWorker:YES];
}

- (void) companyInviteWorkerPopupDidCommunicateWithWorker:(GANInviteWorkerPopupVC *)popup{
    [self doInviteWorker:NO];
}

- (void) companyInviteWorkerPopupDidCancel:(GANInviteWorkerPopupVC *)popup{
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onSeachTextFieldChanged:(id)sender {
    [self buildFilteredArray];
    
    self.enumStatus = GANENUM_COMPANYADDWORKERVC_FOUNDSTATUS_NONE;
    [self refreshViews];
}

@end
