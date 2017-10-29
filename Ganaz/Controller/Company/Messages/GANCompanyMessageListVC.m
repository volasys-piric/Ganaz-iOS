//
//  GANCompanyMessageListVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/29/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyMessageListVC.h"
#import "GANMessageListItemTVC.h"

#import "GANMessageManager.h"
#import "GANMessageDataModel.h"
#import "GANJobManager.h"
#import "GANJobDataModel.h"
#import "GANCompanyManager.h"
#import "GANCacheManager.h"
#import "GANUserManager.h"
#import "GANSurveyManager.h"
#import "GANAppManager.h"

#import "GANGenericFunctionManager.h"
#import "Global.h"
#import "GANGlobalVCManager.h"

@interface GANCompanyMessageListVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSMutableArray<GANMessageDataModel *> *arrayMessages;
@property (assign, atomic) BOOL isVCVisible;

@end

@implementation GANCompanyMessageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.arrayMessages = [[NSMutableArray alloc] init];
    self.isVCVisible = NO;
    
    [self buildMessageList];
    [self registerTableViewCellFromNib];
    [self refreshViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(refreshData) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"MessageListItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_MESSAGELISTITEM"];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.isVCVisible = YES;
    [self updateReadStatusIfNeeded];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self buildMessageList];
    });
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.isVCVisible = NO;
}

- (void) updateReadStatusIfNeeded{
    if (self.isVCVisible == NO) return;
    if ([[GANMessageManager sharedInstance] getUnreadMessageCount] > 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[GANMessageManager sharedInstance] requestMarkAsReadAllMessagesWithCallback:nil];
        });
    }
}

- (void) refreshViews{
}

- (void) buildMessageList{
    [GANGlobalVCManager updateMessageBadge];
    
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    [self.arrayMessages removeAllObjects];
    
    for (int i = 0; i < (int) [managerMessage.arrayThreads count]; i++) {
        GANMessageThreadDataModel *thread = [managerMessage.arrayThreads objectAtIndex:i];
        int nMessages = (int) [thread.arrayMessages count];
        for (int j = nMessages - 1; j >= 0; j--) {
            GANMessageDataModel *message = [thread.arrayMessages objectAtIndex:j];
            if ([message amIReceiver] == NO && [message amISender] == NO) continue;
            if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) continue;
            
            [self.arrayMessages addObject:message];
            break;
        }
    }
    
    [self.arrayMessages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
    GANACTIVITY_REPORT(@"Company - Go to send message from Messages");
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANMessageListItemTVC *) cell AtIndex: (int) index{
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    
    cell.labelDateTime.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    BOOL amISender = [message amISender];
    BOOL didRead = YES;
    
    if (amISender == YES){
        int nReceivers = [message getReceiversCount];
        didRead = YES;
        
        if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
            cell.labelMessage.text = [message getContentsEN];
            
            if (nReceivers == 1) {
                cell.labelTitle.text = @"Message sent";
            }
            else {
                cell.labelTitle.text = @"Group message sent";
            }
            
            [message requestGetBeautifiedReceiversAbbrWithCallback:^(NSString *beautifiedName) {
                cell.labelTitle.text = beautifiedName;
            }];
        }
        
        else if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT){
            cell.labelTitle.text = @"Recruiting";
            cell.labelMessage.text = [NSString stringWithFormat:@"Sent to %d worker(s)", nReceivers];
            
            int indexJob = [managerJob getIndexForMyJobsByJobId:message.szJobId];
            if (indexJob != -1){
                GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:indexJob];
                cell.labelTitle.text = [NSString stringWithFormat:@"Recruiting: %@", [job getTitleEN]];
            }
        }

        else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE ||
                 message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT){
            cell.labelTitle.text = @"Survey";
            cell.labelMessage.text = [message getContentsEN];
            
            [message requestGetBeautifiedReceiversAbbrWithCallback:^(NSString *beautifiedName) {
                cell.labelTitle.text = beautifiedName;
            }];
        }
    }
    
    else {
        didRead = !([message getPrimaryReceiver].enumStatus == GANENUM_MESSAGE_STATUS_NEW);
        
        if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
            cell.labelTitle.text = @"Message received";
            cell.labelMessage.text = [message getContentsEN];
            
            [managerCache requestGetIndexForUserByUserId:message.modelSender.szUserId Callback:^(int index) {
                if (index == -1) return;
                GANUserBaseDataModel *user = [managerCache.arrayUsers objectAtIndex:index];
                [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                    cell.labelTitle.text = displayName;
                }];
            }];
        }
        
        else if (message.enumType == GANENUM_MESSAGE_TYPE_APPLICATION){
            cell.labelTitle.text = @"New job inquiry";
            cell.labelMessage.text = [message getContentsEN];
            
            [managerCache requestGetIndexForUserByUserId:message.modelSender.szUserId Callback:^(int index) {
                if (index == -1) return;
                GANUserBaseDataModel *user = [managerCache.arrayUsers objectAtIndex:index];
                [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                    cell.labelTitle.text = displayName;
                }];
            }];
            
            GANJobManager *managerJob = [GANJobManager sharedInstance];
            int indexJob = [managerJob getIndexForMyJobsByJobId:message.szJobId];
            if (indexJob != -1){
                GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:indexJob];
                cell.labelMessage.text = [NSString stringWithFormat:@"Job App: %@", [job getTitleEN]];
            }
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SUGGEST){
            cell.labelTitle.text = @"New job inquiry";
            cell.labelMessage.text = [message getContentsEN];
            
            [managerCache requestGetIndexForUserByUserId:message.modelSender.szUserId Callback:^(int index) {
                if (index == -1) return;
                GANUserBaseDataModel *user = [managerCache.arrayUsers objectAtIndex:index];
                [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                    cell.labelTitle.text = displayName;
                }];
            }];
            
            GANJobManager *managerJob = [GANJobManager sharedInstance];
            int indexJob = [managerJob getIndexForMyJobsByJobId:message.szJobId];
            if (indexJob != -1){
                GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:indexJob];
                cell.labelMessage.text = [NSString stringWithFormat:@"Job App: %@ for %@", [job getTitleEN], [message getPhoneNumberForSuggestFriend]];
            }
        }
        /*
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER){
            cell.lblTitle.text = @"Survey";
            cell.lblMessage.text = [message getContentsEN];
            
            [managerCache requestGetIndexForUserByUserId:message.szSenderUserId Callback:^(int index) {
                if (index == -1) return;
                GANUserBaseDataModel *user = [managerCache.arrayUsers objectAtIndex:index];
                [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                    cell.lblTitle.text = [NSString stringWithFormat:@"Answer from %@", displayName];
                }];
            }];
        }
         */
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell refreshViewsWithType:message.enumType DidRead:didRead DidSend:amISender];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANMessageListItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_MESSAGELISTITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 73;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    int index = (int) indexPath.row;
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    
    if (message.enumType == GANENUM_MESSAGE_TYPE_SUGGEST){
        [self callSuggestedFriendAtIndex:index];
    }
    else if ([message isSurveyMessage] == YES){
        [self showActionSheetForSurveyAtIndex:index];
    }
    else {
        [self replyMessageAtIndex:index];
    }
     */
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATED]) ||
        ([[notification name] isEqualToString:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED])){
        [self buildMessageList];
        [self updateReadStatusIfNeeded];
    }
}

@end
