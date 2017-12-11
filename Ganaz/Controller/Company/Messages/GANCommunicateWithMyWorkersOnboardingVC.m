//
//  GANCommunicateWithMyWorkersOnboardingVC.m
//  Ganaz
//
//  Created by forever on 8/19/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCommunicateWithMyWorkersOnboardingVC.h"
#import "GANWorkerSuggestFriendItemTVC.h"
#import "GANComposeMessageOnboardingVC.h"

#import "GANPhonebookContactsManager.h"
#import "GANGlobalVCManager.h"
#import "GANGenericFunctionManager.h"
#import "UIView+Shake.h"

@interface GANCommunicateWithMyWorkersOnboardingVC ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (strong, nonatomic) IBOutlet UITableView *tblWorker;
@property (strong, nonatomic) IBOutlet UIButton *btnAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnContinue;
@property (strong, nonatomic) IBOutlet UIView *viewSearch;

@property (strong, nonatomic) NSMutableArray *arrFilteredContacts;
@property (strong, nonatomic) NSMutableArray *arrAddedUsers;

@end

@implementation GANCommunicateWithMyWorkersOnboardingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tblWorker.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tblWorker.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.arrFilteredContacts = [[NSMutableArray alloc] init];
    self.arrAddedUsers = [[NSMutableArray alloc] init];
    
    [self refreshViews];
    [self registerTableViewCellFromNib];
    [self askPermissionForPhoneBook];
}

- (void) refreshViews{
    self.viewSearch.layer.cornerRadius = 3;
    self.viewSearch.clipsToBounds = YES;
    
    self.btnAdd.layer.cornerRadius = 3;
    self.btnAdd.clipsToBounds = YES;
    
    self.btnContinue.layer.cornerRadius = 3;
    self.btnContinue.clipsToBounds = YES;
}

- (void) registerTableViewCellFromNib{
    [self.tblWorker registerNib:[UINib nibWithNibName:@"WorkerSuggestFriendItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKER_SUGGESTFRIEND"];
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
    
    [self.arrFilteredContacts removeAllObjects];
    
    GANPhonebookContactsManager *managerPhonebook = [GANPhonebookContactsManager sharedInstance];
    if (managerPhonebook.isContactsListBuilt == NO){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblWorker reloadData];
        });
        return;
    }
    
    NSString *keyword = [self.txtPhoneNumber.text lowercaseString];
    keyword = [keyword stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    if (keyword.length == 0){
        [self.arrFilteredContacts addObjectsFromArray:managerPhonebook.arrContacts];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblWorker reloadData];
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
        [self.tblWorker reloadData];
    });
}

- (IBAction)onAdd:(id)sender {
    
    if (self.txtPhoneNumber.text.length == 0){
        [self shakeInvalidFields:self.viewSearch];
        return;
    }
    
    NSString *szPhoneNumber = [GANGenericFunctionManager getValidPhoneNumber:self.txtPhoneNumber.text];
    
    if([szPhoneNumber isEqualToString:@""]) {
        [GANGlobalVCManager showHudErrorWithMessage:@"Please enter a valid phone number" DismissAfter:-1 Callback:nil];
        return;
    }
    
    GANPhonebookContactDataModel *newContact = [[GANPhonebookContactDataModel alloc] init];
    
    newContact.modelPhone = [[GANPhoneDataModel alloc] init];
    newContact.modelPhone.szLocalNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:szPhoneNumber];
    
    if([self isAddedUser:newContact] == NO) {
        [self.arrAddedUsers addObject:newContact];
        [self gotoMessageOnboarding];
    } else {
        [GANGlobalVCManager showHudErrorWithMessage:@"This user has already been added" DismissAfter:-1 Callback:nil];
    }
}

- (IBAction)onContinue:(id)sender {
    
    if(self.arrAddedUsers.count == 0) {
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select the contact(s) you want to message" DismissAfter:-1 Callback:nil];
        return;
    }
    
    [self gotoMessageOnboarding];
}

- (void) gotoMessageOnboarding {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANComposeMessageOnboardingVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGES_ONBOARDING"];
    vc.aryCommunicateUsers = [self.arrAddedUsers mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) shakeInvalidFields: (UIView *) viewContainer{
    [viewContainer shake:6 withDelta:8 speed:0.07];
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onTextFieldSearchChanged:(id)sender {
    [self buildFilteredArray];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANWorkerSuggestFriendItemTVC *) cell AtIndex: (int) index{
    GANPhonebookContactDataModel *contact = [self.arrFilteredContacts objectAtIndex:index];
    cell.labelName.text = [contact getFullName];
    cell.labelPhone.text = [contact.modelPhone getBeautifiedPhoneNumber];
    
    if ([self isAddedUser:contact] == YES){
        [cell.imageCheck setImage:[UIImage imageNamed:@"icon-checked"]];
    }
    else {
        [cell.imageCheck setImage:[UIImage imageNamed:@"icon-unchecked"]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrFilteredContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkerSuggestFriendItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKER_SUGGESTFRIEND"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = (int) indexPath.row;
    GANPhonebookContactDataModel *contact = [self.arrFilteredContacts objectAtIndex:index];
    if([self isAddedUser:contact] == NO) {
        [self.arrAddedUsers addObject:contact];
    } else {
        [self.arrAddedUsers removeObject:contact];
    }
    
    [self.tblWorker reloadData];
}

- (BOOL) isAddedUser:(GANPhonebookContactDataModel *)newContact {
    for(int i = 0; i < self.arrAddedUsers.count; i ++) {
        GANPhonebookContactDataModel *contact = [self.arrAddedUsers objectAtIndex:i];
        if([contact.modelPhone.szLocalNumber isEqualToString:newContact.modelPhone.szLocalNumber]) {
            return YES;
        }
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
