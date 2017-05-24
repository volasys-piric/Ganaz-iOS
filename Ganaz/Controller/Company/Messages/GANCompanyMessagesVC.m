//
//  GANCompanyMessagesVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyMessagesVC.h"
#import "GANMessageItemTVC.h"
#import "GANMessageManager.h"
#import "GANMessageDataModel.h"
#import "GANJobManager.h"
#import "GANJobDataModel.h"
#import "GANMyWorkersManager.h"
#import "GANUserManager.h"

#import "Global.h"
#import "GANGenericFunctionManager.h"

@interface GANCompanyMessagesVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;

@property (strong, nonatomic) NSMutableArray *arrMessages;

@end

@implementation GANCompanyMessagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 75;
    
    self.arrMessages = [[NSMutableArray alloc] init];
    
    [self buildMessageList];
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
    [self.tableview registerNib:[UINib nibWithNibName:@"MessageItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_MESSAGEITEM"];
}

- (void) refreshViews{
    self.btnSendMessage.layer.cornerRadius = 3;
}

- (void) buildMessageList{
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    [self.arrMessages removeAllObjects];
    
    for (int i = 0; i < (int) [managerMessage.arrMessages count]; i++){
        GANMessageDataModel *message = [managerMessage.arrMessages objectAtIndex:i];
        if ([message amIReceiver] == NO && [message amISender] == NO) continue;
        if ((message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE) ||
            (message.enumType == GANENUM_MESSAGE_TYPE_APPLICATION)){
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

- (void) gotoSendMessageVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGES_CHOOSEWORKER"];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANMessageItemTVC *) cell AtIndex: (int) index{
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
    cell.lblDateTime.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    
    if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
        cell.lblTitle.text = [NSString stringWithFormat:@"Message To: %@", message.szReceiverUserId];
        cell.lblMessage.text = [message getContentsEN];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_APPLICATION){
        GANJobManager *managerJob = [GANJobManager sharedInstance];
        int indexJob = [managerJob getIndexForMyJobsByJobId:message.szJobId];
        if (indexJob != -1){
            GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:indexJob];
            cell.lblTitle.text = [NSString stringWithFormat:@"Worker interested: %@", [job getTitleEN]];
        }
        else {
            cell.lblTitle.text = @"New job inquiry";
        }
        
        cell.lblMessage.text = @"";
        [[GANMyWorkersManager sharedInstance] requestGetWorkerDetailsByWorkerUserId:message.szSenderUserId Callback:^(int index) {
            if (index != -1){
                GANUserWorkerDataModel *worker = [[GANMyWorkersManager sharedInstance].arrWorkersFound objectAtIndex:index];
                cell.lblMessage.text = [NSString stringWithFormat:@"Call %@ @%@", worker.szUserName, [worker.modelPhone getBeautifiedPhoneNumber]];
            }
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

#pragma mark - UIButton Delegate

- (IBAction)onBtnSendMessageClick:(id)sender {
    [self gotoSendMessageVC];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATED]) ||
        ([[notification name] isEqualToString:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED])){
        [self buildMessageList];
    }
}

@end
