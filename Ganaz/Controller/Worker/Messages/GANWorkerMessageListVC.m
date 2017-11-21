//
//  GANWorkerMessageListVC.m
//  Ganaz
//
//  Created by Chris Lin on 11/1/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerMessageListVC.h"
#import "GANMessageListItemTVC.h"
#import "GANWorkerMessageThreadVC.h"

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

@interface GANWorkerMessageListVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSMutableArray<GANMessageDataModel *> *arrayMessages;
@property (assign, atomic) BOOL isVCVisible;

@end

@implementation GANWorkerMessageListVC

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

        /*
        BOOL foundMessage = NO;         // Message, Application, Suggest
        BOOL foundRecruit = NO;         // Recruit
        BOOL foundSurvey = NO;          // Survey
        */
        
        for (int j = nMessages - 1; j >= 0; j--) {
            GANMessageDataModel *message = [thread.arrayMessages objectAtIndex:j];
            if ([message amIReceiver] == NO && [message amISender] == NO) continue;
            if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) continue;
        
            /*
            if (foundMessage == NO) {
                if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE ||
                    message.enumType == GANENUM_MESSAGE_TYPE_APPLICATION ||
                    message.enumType == GANENUM_MESSAGE_TYPE_SUGGEST) {
                    foundMessage = YES;
                    [self.arrayMessages addObject:message];
                }
            }
            
            if (foundRecruit == NO) {
                if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT) {
                    foundRecruit = YES;
                    [self.arrayMessages addObject:message];
                }
            }
            
            if (foundSurvey == NO) {
                if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT ||
                    message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE) {
                    foundSurvey = YES;
                    [self.arrayMessages addObject:message];
                }
            }
            
            if (foundMessage == YES && foundRecruit == YES && foundSurvey == YES) break;
             */
            
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

- (void) gotoMessageThreadVCAtIndex: (int) index{
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    NSString *messageId = message.szId;
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    int indexThread = -1;
    for (int i = 0; i < (int) [managerMessage.arrayThreads count]; i++) {
        GANMessageThreadDataModel *thread = [managerMessage.arrayThreads objectAtIndex:i];
        if ([thread existsMessageWithMessageId:messageId] == YES) {
            indexThread = i;
            break;
        }
    }
    if (indexThread == -1) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WorkerMessage" bundle:nil];
        GANWorkerMessageThreadVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_MESSAGE_THREAD"];
        vc.indexThread = indexThread;
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
    GANACTIVITY_REPORT(@"Company - Go to message thread from Messages");
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANMessageListItemTVC *) cell AtIndex: (int) index{
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    
    int indexCell = index;
    cell.index = indexCell;
    cell.labelDateTime.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    BOOL amISender = [message amISender];
    BOOL didRead = YES;
    
    if (amISender == YES){
        didRead = YES;
        GANMessageReceiverDataModel *receiverPrimary = [message getPrimaryReceiver];
        
        if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
            cell.labelMessage.text = [message getContentsES];
            cell.labelTitle.text = @"Mensaje enviado";       // Message sent
            
            [managerCache requestGetCompanyDetailsByCompanyId:receiverPrimary.szCompanyId Callback:^(int indexCompany) {
                // Check if cell is already re-initiated for new item
                if (cell.index != indexCell) return;
                if (indexCompany != -1){
                    GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                    cell.labelTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                }
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_APPLICATION){
            cell.labelTitle.text = @"Solicitud de trabajo";                   // Job application
            cell.labelMessage.text = @"Nueva solicitud de trabajo";           // New job inquiry
            
            [managerCache requestGetCompanyDetailsByCompanyId:receiverPrimary.szCompanyId Callback:^(int indexCompany) {
                // Check if cell is already re-initiated for new item
                if (cell.index != indexCell) return;
                if (indexCompany == -1) {
                    return;
                }
                
                GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                cell.labelTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                
                [company requestJobsListWithJobId:message.szJobId Callback:^(int status) {
                    // Check if cell is already re-initiated for new item
                    if (cell.index != indexCell) return;
                    if (status != SUCCESS_WITH_NO_ERROR){
                        return;
                    }
                    int indexJob = [company getIndexForJob:message.szJobId];
                    if (indexJob != -1){
                        GANJobDataModel *job = [company.arrJobs objectAtIndex:indexJob];
                        cell.labelMessage.text = [NSString stringWithFormat:@"Solicitud de trabajo: %@", [job getTitleES]];       // Job application:
                    }
                    else {
                        cell.labelMessage.text = @"No se encontró el trabajo";    // Job not found
                    }
                }];
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SUGGEST) {
            // Suggest Friend
            cell.labelTitle.text = @"Amigo sugerido";                           // Job application
            cell.labelMessage.text = @"Nueva solicitud de trabajo";             // New job inquiry
            
            [managerCache requestGetCompanyDetailsByCompanyId:receiverPrimary.szCompanyId Callback:^(int indexCompany) {
                // Check if cell is already re-initiated for new item
                if (cell.index != indexCell) return;
                if (indexCompany == -1) {
                    return;
                }
                
                GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                cell.labelTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                
                [company requestJobsListWithJobId:message.szJobId Callback:^(int status) {
                    // Check if cell is already re-initiated for new item
                    if (cell.index != indexCell) return;
                    if (status != SUCCESS_WITH_NO_ERROR){
                        return;
                    }
                    int indexJob = [company getIndexForJob:message.szJobId];
                    if (indexJob != -1){
                        GANJobDataModel *job = [company.arrJobs objectAtIndex:indexJob];
                        // Suggest Friend {phone number} for {job title}
                        cell.labelMessage.text = [NSString stringWithFormat:@"Sugerir amigo %@ para %@",[message getPhoneNumberForSuggestFriend], [job getTitleES]];       // Suggest Friend:
                    }
                    else {
                        cell.labelMessage.text = @"No se encontró el trabajo";    // Job not found
                    }
                }];
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) {
            cell.labelTitle.text = @"Encuesta";
            // You answered survey.
            cell.labelMessage.text = @"Usted contestó la encuesta.";
            
            [managerCache requestGetCompanyDetailsByCompanyId:receiverPrimary.szCompanyId Callback:^(int indexCompany) {
                // Check if cell is already re-initiated for new item
                if (cell.index != indexCell) return;
                if (indexCompany != -1){
                    GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                    cell.labelTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                }
            }];
        }
    }
    else {
        GANMessageReceiverDataModel *receiver = [message getReceiverMyself];
        didRead = (receiver != nil && receiver.enumStatus != GANENUM_MESSAGE_STATUS_NEW);
        
        if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
            cell.labelTitle.text = @"Mensaje recibido";           // Message received
            cell.labelMessage.text = [message getContentsES];
            [managerCache requestGetCompanyDetailsByCompanyId:message.modelSender.szCompanyId Callback:^(int indexCompany) {
                // Check if cell is already re-initiated for new item
                if (cell.index != indexCell) return;
                if (indexCompany != -1){
                    GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                    cell.labelTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                }
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT){
            cell.labelTitle.text = @"Reclutado";              // Recruited
            cell.labelMessage.text = @"Reclutado";            // Recruited
            [managerCache requestGetCompanyDetailsByCompanyId:message.modelSender.szCompanyId Callback:^(int indexCompany) {
                // Check if cell is already re-initiated for new item
                if (cell.index != indexCell) return;
                if (indexCompany == -1) {
                    return;
                }
                
                GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                cell.labelTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                
                [company requestJobsListWithJobId:message.szJobId Callback:^(int status) {
                    // Check if cell is already re-initiated for new item
                    if (cell.index != indexCell) return;
                    if (status != SUCCESS_WITH_NO_ERROR){
                        return;
                    }
                    int indexJob = [company getIndexForJob:message.szJobId];
                    if (indexJob != -1){
                        GANJobDataModel *job = [company.arrJobs objectAtIndex:indexJob];
                        cell.labelMessage.text = [NSString stringWithFormat:@"Trabajo: %@", [job getTitleES]];        // Job:
                    }
                    else {
                        cell.labelMessage.text = @"No se encontró el trabajo";            // Job not found
                    }
                }];
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE ||
                 message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT){
            // Survey
            cell.labelTitle.text = @"Encuesta";
            cell.labelMessage.text = [NSString stringWithFormat:@"Encuesta: %@", [message getContentsES]];
            
            [managerCache requestGetCompanyDetailsByCompanyId:message.modelSender.szCompanyId Callback:^(int indexCompany) {
                // Check if cell is already re-initiated for new item
                if (cell.index != indexCell) return;
                if (indexCompany != -1){
                    GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                    cell.labelTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                }
            }];
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
    [self gotoMessageThreadVCAtIndex:(int) indexPath.row];
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
