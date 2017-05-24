//
//  GANWorkerMessagesVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/26/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerMessagesVC.h"
#import "GANMessageItemTVC.h"
#import "GANMessageManager.h"
#import "GANMessageDataModel.h"

#import "GANUserManager.h"
#import "GANJobManager.h"

#import "GANCompanyManager.h"
#import "GANGlobalVCManager.h"
#import "GANWorkerJobDetailsVC.h"
#import "Global.h"
#import "GANGenericFunctionManager.h"

@interface GANWorkerMessagesVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *arrMessages;

@end

@implementation GANWorkerMessagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 75;
    
    self.arrMessages = [[NSMutableArray alloc] init];
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
        });
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
    [self.tableview registerNib:[UINib nibWithNibName:@"MessageItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_MESSAGEITEM"];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[GANMessageManager sharedInstance] getUnreadMessageCount] > 0){
        [[GANMessageManager sharedInstance] requestGetMessageListWithCallback:nil];
    }
}

- (void) refreshViews{
    [self buildMessageList];
    [GANGlobalVCManager updateMessageBadge];
}

- (void) buildMessageList{
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    [self.arrMessages removeAllObjects];
    
    for (int i = 0; i < (int) [managerMessage.arrMessages count]; i++){
        GANMessageDataModel *message = [managerMessage.arrMessages objectAtIndex:i];
        if ([message amIReceiver] == NO) continue;
        if ((message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE) ||
            (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT)){
            [self.arrMessages addObject:message];
        }
    }
    
    [self.arrMessages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GANMessageDataModel *msg1 = obj1;
        GANMessageDataModel *msg2 = obj2;
        return [msg2.dateSent compare:msg1.dateSent];
    }];
    
    [self.tableview reloadData];
}

- (void) gotoJobDetailsVCWithJobId: (NSString *) jobId CompanyId: (NSString *) companyId{
    if (jobId.length == 0) return;
    if (companyId.length == 0) return;
    
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [managerCompany requestGetCompanyDetailsByCompanyId:companyId Callback:^(int indexCompany) {
        if (indexCompany == -1) {
            [GANGlobalVCManager hideHudProgress];
            return;
        }
        
        GANCompanyDataModel *company = [managerCompany.arrCompaniesFound objectAtIndex:indexCompany];
        [company requestJobsListWithCallback:^(int status) {
            [GANGlobalVCManager hideHudProgress];
            if (status != SUCCESS_WITH_NO_ERROR){
                return;
            }
            int indexJob = [company getIndexForJob:jobId];
            if (indexJob == -1) return;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
            GANWorkerJobDetailsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_JOBDETAILS"];
            vc.indexCompany = indexCompany;
            vc.indexJob = indexJob;
            vc.isRecruited = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        }];
    }];
}

- (void) gotoMessageDetailsAtIndex: (int) index{
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
    if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT){
        [self gotoJobDetailsVCWithJobId:message.szJobId CompanyId:message.szSenderCompanyId];
    }
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANMessageItemTVC *) cell AtIndex: (int) index{
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
    cell.lblMessage.text = [message getContentsES];
    cell.lblDateTime.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    
    if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
        cell.lblTitle.text = @"";
        [[GANCompanyManager sharedInstance] getCompanyBusinessNameESByCompanyId:message.szSenderCompanyId Callback:^(NSString *businessNameES) {
            cell.lblTitle.text = businessNameES;
        }];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT){
        cell.lblTitle.text = @"";
        cell.lblMessage.text = @"Nuevo trabajo disponible";
        [[GANCompanyManager sharedInstance] getCompanyBusinessNameESByCompanyId:message.szSenderCompanyId Callback:^(NSString *businessNameES) {
            cell.lblTitle.text = businessNameES;
        }];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell refreshViewsWithType:message.enumType];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANMessageItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_MESSAGEITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    [self gotoMessageDetailsAtIndex:index];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATED]) ||
        ([[notification name] isEqualToString:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED])){
        [self refreshViews];
    }
    else if ([[notification name] isEqualToString:GANLOCALNOTIFICATION_CONTENTS_TRANSLATED]){
        [self.tableview reloadData];
    }
}

@end
