//
//  GANCompanyAddWorkerVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyAddWorkerVC.h"
#import "GANWorkerItemTVC.h"
#import "GANUIPhoneTextField.h"

#import "GANUserWorkerDataModel.h"
#import "GANCompanyManager.h"
#import "GANUserManager.h"

#import "GANUtils.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"
#import "GANGlobalVCManager.h"
#import <UIView+Shake.h>

@interface GANCompanyAddWorkerVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UIView *viewPhone;
@property (weak, nonatomic) IBOutlet GANUIPhoneTextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;

@property (strong, nonatomic) NSMutableArray *arrWorkersFound;
@property (strong, nonatomic) NSMutableArray *arrWorkersSelected;

@end

@implementation GANCompanyAddWorkerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.arrWorkersSelected = [[NSMutableArray alloc] init];
    self.arrWorkersFound = [[NSMutableArray alloc] init];
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"WorkerItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKERITEM"];
}

- (void) refreshViews{
    self.viewPhone.layer.cornerRadius = 3;
    self.btnAdd.layer.cornerRadius = 3;
}

#pragma mark - Biz Logic

- (BOOL) isWorkerSelected{
    for (int i = 0; i < (int) [self.arrWorkersSelected count]; i++){
        BOOL selected = [[self.arrWorkersSelected objectAtIndex:i] boolValue];
        if (selected == YES) return YES;
    }
    return NO;
}

- (void) shakeInvalidFields: (UIView *) viewContainer{
    [viewContainer shake:6 withDelta:8 speed:0.07];
}

- (void) showEmptyPanel: (BOOL) show{
    self.btnInvite.hidden = !show;
    self.tableview.hidden = show;
    self.btnAdd.hidden = show;
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
                [self showEmptyPanel:NO];
                [GANGlobalVCManager showHudInfoWithMessage:@"No new worker found!" DismissAfter:-1 Callback:nil];
            }
            else {
                [self buildSearchResultWithArray:arrWorkers];
                [self showEmptyPanel:NO];
                [GANGlobalVCManager showHudSuccessWithMessage:[NSString stringWithFormat:@"%d worker(s) found!", (int) [arrWorkers count]] DismissAfter:-1 Callback:nil];
            }
        }
        else if (status == ERROR_NOT_FOUND){
            [self showEmptyPanel:YES];
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

    [self.arrWorkersSelected removeAllObjects];
    for (int i = 0; i < (int) [arr count]; i++){
        [self.arrWorkersSelected addObject:@(NO)];
    }
    
    [self.tableview reloadData];
}

- (void) doAddMyWorkers{
    NSMutableArray *arrUserIds = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [self.arrWorkersSelected count]; i++){
        BOOL selected = [[self.arrWorkersSelected objectAtIndex:i] boolValue];
        if (selected == YES){
            GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:i];
            [arrUserIds addObject:worker.szId];
        }
    }
    if ([arrUserIds count] == 0) return;
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANCompanyManager sharedInstance] requestAddMyWorkerWithUserIds:arrUserIds Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker is added successfully." DismissAfter:-3 Callback:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error." DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) doInvite{
    NSString *szCompanyId = [GANUserManager getCompanyDataModel].szId;
    GANPhoneDataModel *phone = [[GANPhoneDataModel alloc] init];
    phone.szLocalNumber = [GANGenericFunctionManager stripNonnumericsFromNSString:self.txtPhone.text];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANCompanyManager sharedInstance] requestSendInvite:phone CompanyId:szCompanyId Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Invitation SMS will be sent shortly." DismissAfter:-1 Callback:nil];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error" DismissAfter:-1 Callback:nil];
        }
    }];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANWorkerItemTVC *) cell AtIndex: (int) index{
    GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:index];
    cell.lblWorkerId.text = worker.szUserName;
    
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL isSelected = [[self.arrWorkersSelected objectAtIndex:index] boolValue];
    [cell setItemSelected:isSelected];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrWorkersFound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkerItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKERITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    BOOL isSelected = [[self.arrWorkersSelected objectAtIndex:index] boolValue];
    [self.arrWorkersSelected replaceObjectAtIndex:index withObject:@(!isSelected)];
    [self.tableview reloadData];
}

- (IBAction)onBtnSearchClick:(id)sender {
    [self.view endEditing:YES];
    [self searchWorkers];
}

- (IBAction)onBtnAddClick:(id)sender {
    [self.view endEditing:YES];
    if ([self isWorkerSelected] == NO){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select workers to add!" DismissAfter:-1 Callback:nil];
        return;
    }
    [self doAddMyWorkers];
}

- (IBAction)onBtnInviteClick:(id)sender {
    [self.view endEditing:YES];
    [self doInvite];
}

@end
