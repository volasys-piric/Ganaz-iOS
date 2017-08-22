//
//  GANSharePostingWithContactsVC.m
//  Ganaz
//
//  Created by forever on 7/31/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANSharePostingWithContactsVC.h"
#import "GANCompanySuggestWorkersItemTVC.h"
#import "GANJobPostingSharedPopupVC.h"
#import "GANMainChooseVC.h"
#import "GANFadeTransitionDelegate.h"
#import "GANPhonebookContactsManager.h"
#import "GANJobManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"
#import "GANAppManager.h"
#import "GANRecruitManager.h"

@interface GANSharePostingWithContactsVC ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, GANCompanySuggestWorkersItemTVCDelegate, GANJobPostingSharedPopupVCDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UIButton *buttonShare;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonDone;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;
@property (strong, nonatomic) NSMutableArray *arrFilteredContacts;
@property (assign, atomic) int indexSelected;

@end

@implementation GANSharePostingWithContactsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshView];
    
    self.txtSearch.delegate = self;
    
    self.tableView.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.indexSelected = -1;
    self.arrFilteredContacts = [[NSMutableArray alloc] init];
    
    [self registerTableViewCellFromNib];
    [self askPermissionForPhoneBook];
}

- (void) refreshView {
    
    self.buttonShare.layer.cornerRadius = 3.f;
    self.buttonShare.clipsToBounds = YES;
    
    self.buttonDone.layer.cornerRadius = 3.f;
    self.buttonDone.clipsToBounds = YES;
    
}

- (void) registerTableViewCellFromNib {
    [self.tableView registerNib:[UINib nibWithNibName:@"GANCompanySuggestWorkersItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_COMPANY_SUGGESTWORKERS"];
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
    self.indexSelected = -1;
    [self.arrFilteredContacts removeAllObjects];
    
    GANPhonebookContactsManager *managerPhonebook = [GANPhonebookContactsManager sharedInstance];
    if (managerPhonebook.isContactsListBuilt == NO){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        return;
    }
    
    NSString *keyword = [self.txtSearch.text lowercaseString];
    keyword = [keyword stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    if (keyword.length == 0){
        [self.arrFilteredContacts addObjectsFromArray:managerPhonebook.arrContacts];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        return;
    }
    
    for (int i = 0; i < (int) [managerPhonebook.arrContacts count]; i++){
        GANPhonebookContactDataModel *contact = [managerPhonebook.arrContacts objectAtIndex:i];
        NSString *sz = [NSString stringWithFormat:@"%@ %@ %@ %@", [contact getFullName], contact.modelPhone.szLocalNumber, [contact.modelPhone getBeautifiedPhoneNumber], contact.szEmail];
        sz = [sz lowercaseString];
        if ([sz rangeOfString:keyword].location != NSNotFound){
            [self.arrFilteredContacts addObject:contact];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void) doRecruitWorkers{

    if (self.indexSelected == -1 && [self.txtSearch.text isEqualToString:@""]){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select contact." DismissAfter:-1 Callback:nil];
        return;
    }
    
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    GANRecruitManager *managerRecruit = [GANRecruitManager sharedInstance];
    NSMutableArray *arrPhoneNumbers = [[NSMutableArray alloc] init];
    
    if(self.indexSelected == -1 ) {
        NSString *szPhoneNumber = [GANUtils validatePhoneNumber:self.txtSearch.text];
        if([szPhoneNumber isEqualToString:@""]) {
            [GANGlobalVCManager showAlertWithMessage:@"Please input valid Phone Number."];
            return;
        }
        [arrPhoneNumbers addObject:szPhoneNumber];
    } else {
        GANPhonebookContactDataModel *worker = [self.arrFilteredContacts objectAtIndex:self.indexSelected];
        [arrPhoneNumbers addObject:worker.modelPhone.szLocalNumber];
    }
    
    NSMutableArray *arrJobIds = [[NSMutableArray alloc] init];
    GANJobDataModel *job = [managerJob.arrMyJobs lastObject];
    [arrJobIds addObject:job.szId];

    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerRecruit requestSubmitRecruitWithJobIds:arrJobIds Broadcast:0 ReRecruitUserIds:nil PhoneNumbers:arrPhoneNumbers Callback:^(int status, int count) {
        
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager hideHudProgress];
            [self showPopupDialog];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error." DismissAfter:-1 Callback:nil];
        }
        self.indexSelected = -1;
        GANACTIVITY_REPORT(@"Company - Recruit");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onShare:(id)sender {
    [self.view endEditing:YES];
    [self doRecruitWorkers];
}

- (IBAction)onDone:(id)sender {
    [self.view endEditing:YES];
    [self gotoJobListVC];
}

- (void) gotoJobListVC {
    if(self.fromVC == ENUM_COMPANY_SHAREPOSTINGWITHCONTACT_FROM_JOBPOST) {
        [GANGlobalVCManager tabBarController:self.tabBarController shouldSelectViewController:1];
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void) showPopupDialog {
    GANJobPostingSharedPopupVC *vc = [[GANJobPostingSharedPopupVC alloc] initWithNibName:@"GANJobPostingSharedPopupVC" bundle:nil];
    
    vc.delegate = self;
    vc.view.backgroundColor = [UIColor clearColor];
    
    NSString *strDescription;
    if(self.indexSelected != -1) {
        GANPhonebookContactDataModel *contact = [self.arrFilteredContacts objectAtIndex:self.indexSelected];
        strDescription = [NSString stringWithFormat:@"Your job has been\nshared with\n%@", [contact getFullName]];
    } else {
        strDescription = [NSString stringWithFormat:@"Your job has been\nshared with\n%@", self.txtSearch.text];
    }
    
    [vc refreshFields:strDescription];
    [vc setTransitioningDelegate:self.transController];
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - GANJobPostingSharedPopupVCDelegate
- (void)didOK {
    
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onSeachTextFieldChanged:(id)sender {
    [self buildFilteredArray];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
-(void) configureCell: (GANCompanySuggestWorkersItemTVC *) cell AtIndex: (int) index{
    GANPhonebookContactDataModel *contact = [self.arrFilteredContacts objectAtIndex:index];
    cell.lblName.text = [contact getFullName];
    cell.lblPhoneNumber.text = [contact.modelPhone getBeautifiedPhoneNumber];
    cell.containerView.layer.cornerRadius = 4.f;
    cell.nIndex = index;
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GANCompanySuggestWorkersItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_COMPANY_SUGGESTWORKERS"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrFilteredContacts count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = (int) indexPath.row;
    self.indexSelected = index;
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63;
}

#pragma mark - GANCompanySuggestWorkersItemTVCDelegate
-(void) onWorkersShare:(NSInteger) nIndex {
    [self.view endEditing:YES];
    
    self.indexSelected = (int)nIndex;
    [self doRecruitWorkers];
}

@end
