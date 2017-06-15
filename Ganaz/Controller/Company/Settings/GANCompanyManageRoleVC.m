//
//  GANCompanyManageRoleVC.m
//  Ganaz
//
//  Created by Chris Lin on 6/2/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyManageRoleVC.h"
#import "GANUserManager.h"
#import "GANCompanyManager.h"
#import "GANUserCompanyDataModel.h"
#import "GANCompanyUserItemTVC.h"
#import "Global.h"
#import "GANGlobalVCManager.h"
#import "GANGenericFunctionManager.h"
#import "GANAppManager.h"

@interface GANCompanyManageRoleVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *lblNotes;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableviewHeight;

@property (strong, nonatomic) NSMutableArray<NSString *> *arrUserNames;
@property (strong, nonatomic) NSMutableArray *arrUserSelected;

@end

#define GANCOMPANYMANAGEROLEVC_CONSTANTS_TABLEVIEWCELLHEIGHT                    50

@implementation GANCompanyManageRoleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self buildUserList];
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
    [self.tableview registerNib:[UINib nibWithNibName:@"CompanyUserItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_COMPANYUSERITEM"];
}

- (void) refreshViews{
    self.lblNotes.text = [NSString stringWithFormat:@"Invite others at your company to use Ganaz and tell them to use this code while signing up so you can work together: %@", [GANUserManager getCompanyDataModel].szCode];
}

- (void) buildUserList{
    self.arrUserNames = [[NSMutableArray alloc] init];
    self.arrUserSelected = [[NSMutableArray alloc] init];
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    
    GANUserCompanyDataModel *me = [GANUserManager getUserCompanyDataModel];
    [self.arrUserNames addObject:[NSString stringWithFormat:@"%@ (You)", [me getFullName]]];
    [self.arrUserSelected addObject:@(me.enumType == GANENUM_USER_TYPE_COMPANY_ADMIN)];
    
    for (int i = 0; i < (int)[managerCompany.arrCompanyUsers count]; i++){
        GANUserCompanyDataModel *user = [managerCompany.arrCompanyUsers objectAtIndex:i];
        [self.arrUserNames addObject:[user getFullName]];
        [self.arrUserSelected addObject:@(user.enumType == GANENUM_USER_TYPE_COMPANY_ADMIN)];
    }
    
    self.constraintTableviewHeight.constant = GANCOMPANYMANAGEROLEVC_CONSTANTS_TABLEVIEWCELLHEIGHT * [self.arrUserNames count];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}

#pragma mark - Biz Logic

- (BOOL) isUserSelected{
    for (int i = 0; i < (int) [self.arrUserSelected count]; i++){
        if ([[self.arrUserSelected objectAtIndex:i] boolValue] == YES) return YES;
    }
    return NO;
}

- (void) promptForChangeRoleAtIndex: (int) index{
    [GANGlobalVCManager promptWithVC:self Title:@"Confirmation" Message:@"Are you sure you want to change this user's role?" ButtonYes:@"Yes" ButtonNo:@"No" CallbackYes:^{
        GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
        GANUserCompanyDataModel *user = [managerCompany.arrCompanyUsers objectAtIndex:(index - 1)];
        GANENUM_USER_TYPE typeNew;
        if (user.enumType == GANENUM_USER_TYPE_COMPANY_ADMIN){
            typeNew = GANENUM_USER_TYPE_COMPANY_REGULAR;
        }
        else if (user.enumType == GANENUM_USER_TYPE_COMPANY_REGULAR){
            typeNew = GANENUM_USER_TYPE_COMPANY_ADMIN;
        }
        else {
            return;
        }
        
        [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
        [managerCompany requestUpdateCompanyUserType:user.szId Type:typeNew Callback:^(int status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == SUCCESS_WITH_NO_ERROR){
                    [self buildUserList];
                    [GANGlobalVCManager showHudSuccessWithMessage:@"Succeeded!" DismissAfter:-1 Callback:nil];
                }
                else {
                    [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
                }                
            });
        }];
        GANACTIVITY_REPORT(@"Company - Change user role");
    } CallbackNo:nil];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANCompanyUserItemTVC *) cell AtIndex: (int) index{
    cell.lblName.text = [self.arrUserNames objectAtIndex:index];
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL isSelected = [[self.arrUserSelected objectAtIndex:index] boolValue];
    [cell setItemSelected:isSelected];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrUserNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANCompanyUserItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_COMPANYUSERITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return GANCOMPANYMANAGEROLEVC_CONSTANTS_TABLEVIEWCELLHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    if (index == 0) return;
    [self promptForChangeRoleAtIndex:index];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_COMPANYUSERSLIST_UPDATED]) ||
        ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_COMPANYUSERSLIST_UPDATEFAILED])){
        [self buildUserList];
    }
}

@end
