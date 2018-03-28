//
//  GANCompanyCandidatesMessageListVC.m
//  Ganaz
//
//  Created by Chris Lin on 1/31/18.
//  Copyright © 2018 Ganaz. All rights reserved.
//

#import "GANCompanyCandidatesMessageListVC.h"
#import "GANMessageListItemTVC.h"
#import "GANCompanyMessageThreadVC.h"
#import "GANCompanySurveyChoicesResultVC.h"
#import "GANCompanySurveyOpenTextResultVC.h"
#import "GANJobsDetailsVC.h"

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

@interface GANCompanyCandidatesMessageListVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIButton *buttonMessageAll;

@property (strong, nonatomic) NSMutableArray<GANMessageDataModel *> *arrayMessages;
@property (assign, atomic) BOOL isVCVisible;

@end

@implementation GANCompanyCandidatesMessageListVC

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
    if ([[GANMessageManager sharedInstance] getUnreadCandidateMessageCount] > 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[GANMessageManager sharedInstance] requestMarkAsReadAllCandidateMessagesWithCallback:nil];
        });
    }
}

- (void) refreshViews{
    self.buttonMessageAll.clipsToBounds = YES;
    self.buttonMessageAll.layer.cornerRadius = 3;
    
    
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    if (self.indexJob != -1 && self.indexJob < (int) [managerJob.arrMyJobs count]) {
        GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:self.indexJob];
        if (job != nil) {
            self.navigationItem.title = [NSString stringWithFormat:@"%@ - Candidates", [job getTitleEN]];
        }
    }
}

- (void) buildMessageList{
    [GANGlobalVCManager updateMessageBadge];
    
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    [self.arrayMessages removeAllObjects];
    
    for (int i = 0; i < (int) [managerMessage.arrayCandidateThreads count]; i++) {
        GANMessageThreadDataModel *thread = [managerMessage.arrayCandidateThreads objectAtIndex:i];
        GANMessageDataModel *message = [thread.arrayMessages lastObject];
        [self.arrayMessages addObject:message];
    }
    
    [self.arrayMessages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GANMessageDataModel *msg1 = obj1;
        GANMessageDataModel *msg2 = obj2;
        return [msg2.dateSent compare:msg1.dateSent];
    }];
    
    if ([self.arrayMessages count] == 0) {
        self.buttonMessageAll.hidden = YES;
    }
    else {
        self.buttonMessageAll.hidden = NO;
    }
    
    [self.tableview reloadData];
}

#pragma mark - Navigation

- (void) gotoMessageThreadVCAtIndex: (int) index{
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    NSString *messageId = message.szId;
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    int indexThread = -1;
    for (int i = 0; i < (int) [managerMessage.arrayCandidateThreads count]; i++) {
        GANMessageThreadDataModel *thread = [managerMessage.arrayCandidateThreads objectAtIndex:i];
        if ([thread existsMessageWithMessageId:messageId] == YES) {
            indexThread = i;
            break;
        }
    }
    if (indexThread == -1) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
        GANCompanyMessageThreadVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGE_THREAD"];
        vc.indexThread = indexThread;
        vc.isCandidateThread = YES;
        
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
    GANACTIVITY_REPORT(@"Company - Go to message thread from Messages");
}

- (void) gotoMessageThreadVCForAllCandidates{
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:self.indexJob];
    GANJobCandidatesMappingDataModel *mapping = [managerJob getJobCandidatesMappingByJobId:job.szId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
        GANCompanyMessageThreadVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGE_THREAD"];
        vc.indexThread = -1;
        vc.isCandidateThread = YES;
        vc.arrayReceivers = [[NSMutableArray alloc] init];
        [vc.arrayReceivers addObjectsFromArray:mapping.arrayCandidates];
        
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
    GANACTIVITY_REPORT(@"Company - Go to message thread from Messages");
}

- (void) gotoJobDetailsVCAtIndex: (int) index {
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    int indexJob = [managerJob getIndexForMyJobsByJobId:message.szJobId];
    if (indexJob == -1){
        return;
    }
    
    [managerJob initializeOnboardingJobAtIndex:indexJob];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANJobsDetailsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_JOBS_DETAILS"];
    vc.indexJob = indexJob;
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to job details from job list");
}

- (void) gotoSurveyDetailsAtIndex: (int) index {
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    if ([message isSurveyMessage] == NO){
        return;
    }
    
    GANSurveyManager *managerSurvey = [GANSurveyManager sharedInstance];
    int indexSurvey = [managerSurvey getIndexForSurveyWithSurveyId:message.szSurveyId];
    if (indexSurvey == -1) return;
    GANSurveyDataModel *survey = [managerSurvey.arraySurveys objectAtIndex:indexSurvey];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [survey requestGetAnswersWithCallback:^(int status) {
        [GANGlobalVCManager hideHudProgressWithCallback:^{
            if (survey.enumType == GANENUM_SURVEYTYPE_CHOICESINGLE) {
                [self gotoSurveyChoicesResultVCAtSurveyIndex:indexSurvey];
            }
            else if (survey.enumType == GANENUM_SURVEYTYPE_OPENTEXT) {
                [self gotoSurveyOpenTextResultVCAtSurveyIndex:indexSurvey];
            }
        }];
    }];
    
}

- (void) gotoSurveyChoicesResultVCAtSurveyIndex: (int) indexSurvey{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
    GANCompanySurveyChoicesResultVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SURVEY_CHOICESRESULT"];
    vc.indexSurvey = indexSurvey;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to Survey Results from Message");
}

- (void) gotoSurveyOpenTextResultVCAtSurveyIndex: (int) indexSurvey{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
    GANCompanySurveyOpenTextResultVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SURVEY_OPENTEXTRESULT"];
    vc.indexSurvey = indexSurvey;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to Survey Results from Message");
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANMessageListItemTVC *) cell AtIndex: (int) index{
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    
    cell.labelDateTime.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    BOOL amISender = [message amISender];
    BOOL didRead = YES;
    
    if (amISender == YES){
        int nReceivers = [message getReceiversCount];
        didRead = YES;
        
        if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE || message.enumType == GANENUM_MESSAGE_TYPE_FACEBOOKMESSAGE){
            cell.labelMessage.text = [message getContentsEN];
            
            if (nReceivers == 1) {
                cell.labelTitle.text = @"Message sent";
            }
            else {
                cell.labelTitle.text = @"Group message sent";
            }
            
            [managerMessage requestGetBeautifiedReceiversAbbrWithReceivers:message.arrayReceivers Callback:^(NSString *beautifiedName) {
                cell.labelTitle.text = beautifiedName;
            }];
        }
        
        else if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT){
            cell.labelTitle.text = @"Recruiting";
            int indexJob = [managerJob getIndexForMyJobsByJobId:message.szJobId];
            if (indexJob != -1){
                GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:indexJob];
                cell.labelTitle.text = [NSString stringWithFormat:@"Recruiting: %@", [job getTitleEN]];
            }
            
            cell.labelMessage.text = [NSString stringWithFormat:@"Sent to %d worker(s)", nReceivers];
            [managerMessage requestGetBeautifiedReceiversAbbrWithReceivers:message.arrayReceivers Callback:^(NSString *beautifiedName) {
                cell.labelMessage.text = [NSString stringWithFormat:@"Sent to %@", beautifiedName];
            }];
        }
        
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE ||
                 message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT){
            cell.labelTitle.text = @"Survey";
            cell.labelMessage.text = [message getContentsEN];
            
            [managerMessage requestGetBeautifiedReceiversAbbrWithReceivers:message.arrayReceivers Callback:^(NSString *beautifiedName) {
                cell.labelTitle.text = beautifiedName;
            }];
        }
    }
    
    else {
        // If it's multiple company user, we need to first lookup "myself (current user)" in receivers, and if not found (in rare case), we just refer the primary receiver.
        if ([message getReceiverMyself] != nil) {
            didRead = !([message getReceiverMyself].enumStatus == GANENUM_MESSAGE_STATUS_NEW);
        }
        else {
            didRead = !([message getPrimaryReceiver].enumStatus == GANENUM_MESSAGE_STATUS_NEW);
        }
        
        if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE || message.enumType == GANENUM_MESSAGE_TYPE_FACEBOOKMESSAGE){
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
            cell.labelTitle.text = @"Suggest";
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
    int index = (int) indexPath.row;
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    
    if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT) {
        // Go to job details vc
        [self gotoJobDetailsVCAtIndex:index];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT ||
             message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE) {
        // Go to survey details vc
        [self gotoSurveyDetailsAtIndex:index];
    }
    else {
        // Go to message thread vc
        [self gotoMessageThreadVCAtIndex:index];
    }
    
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonMessageAllClick:(id)sender {
    [self gotoMessageThreadVCForAllCandidates];
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
