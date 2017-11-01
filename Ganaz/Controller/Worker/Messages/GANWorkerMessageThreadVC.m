//
//  GANWorkerMessageThreadVC.m
//  Ganaz
//
//  Created by Chris Lin on 11/1/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerMessageThreadVC.h"
#import "GANMessageItemMeTVC.h"
#import "GANMessageItemYouTVC.h"
#import "GANWorkerSurveyChoicesVC.h"
#import "GANWorkerSurveyOpenTextVC.h"
#import "GANWorkerJobDetailsVC.h"

#import "GANMessageManager.h"
#import "GANAppManager.h"
#import "GANCacheManager.h"
#import "GANJobManager.h"

#import "Global.h"
#import "UIColor+GANColor.h"
#import "GANGlobalVCManager.h"
#import "GANGenericFunctionManager.h"
#import <IQKeyboardManager.h>

@interface GANWorkerMessageThreadVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *viewInputWrapper;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITextField *textfieldInput;

@property (strong, nonatomic) GANMessageThreadDataModel *modelThread;
@property (strong, nonatomic) NSMutableArray <GANMessageDataModel *> *arrayMessages;
@property (strong, nonatomic) GANUserRefDataModel *modelReceiver;

@property (assign, atomic) float fIQKeyboardDistance;
@property (assign, atomic) BOOL isVCVisible;

@end

@implementation GANWorkerMessageThreadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.textfieldInput.inputAccessoryView = [[UIView alloc] init];
    
    self.isVCVisible = NO;
    self.fIQKeyboardDistance = IQKeyboardManager.sharedManager.keyboardDistanceFromTextField;
    
    self.arrayMessages = [[NSMutableArray alloc] init];
    [self registerTableViewCellFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(refreshTableview) userInfo:nil repeats:YES];
    
    self.navigationItem.title = @"Mesanjes";

    self.modelThread = [[GANMessageManager sharedInstance].arrayThreads objectAtIndex:self.indexThread];
    GANMessageDataModel *message = [self.modelThread getLatestMessage];
    
    if ([message amISender] == YES) {
        self.modelReceiver = [message getPrimaryReceiver];
    }
    else {
        self.modelReceiver = message.modelSender;
    }
    
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    [managerCache requestGetCompanyDetailsByCompanyId:self.modelReceiver.szCompanyId Callback:^(int indexCompany) {
        if (indexCompany == -1) {
            return;
        }
        
        GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
        self.navigationItem.title = [company getBusinessNameES];
    }];
    
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.isVCVisible = YES;
    [self updateReadStatusIfNeeded];
    [self buildMessageList];
    
    IQKeyboardManager.sharedManager.keyboardDistanceFromTextField = 8;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isVCVisible = NO;
    IQKeyboardManager.sharedManager.keyboardDistanceFromTextField = self.fIQKeyboardDistance;
}

- (void) refreshViews {
    self.viewInputWrapper.layer.borderColor = [UIColor GANThemeGreenColor].CGColor;
    self.viewInputWrapper.layer.borderWidth = 1;
    self.viewInputWrapper.layer.cornerRadius = 5;
    self.viewInputWrapper.clipsToBounds = YES;
}

- (void) scrollToBottom{
    if ([self.arrayMessages count] == 0) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.arrayMessages count] - 1 inSection:0];
        [self.tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    });
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"MessageItemMeTVC" bundle:nil] forCellReuseIdentifier:@"TVC_MESSAGEITEM_ME"];
    [self.tableview registerNib:[UINib nibWithNibName:@"MessageItemYouTVC" bundle:nil] forCellReuseIdentifier:@"TVC_MESSAGEITEM_YOU"];
}

- (void) updateReadStatusIfNeeded{
    if (self.isVCVisible == NO) return;
    if ([self.modelThread.arrayMessages count] == 0) return;
    
    if ([self.modelThread getUnreadMessageCount] > 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[GANMessageManager sharedInstance] requestMarkAsReadWithThreadIndex:self.indexThread Callback:nil];
        });
    }
}

- (void) buildMessageList{
    [GANGlobalVCManager updateMessageBadge];
    
    [self.arrayMessages removeAllObjects];
    
    for (int i = 0; i < (int) [self.modelThread.arrayMessages count]; i++){
        GANMessageDataModel *message = [self.modelThread.arrayMessages objectAtIndex:i];
        if ([message amIReceiver] == NO && [message amISender] == NO) continue;
        [self.arrayMessages addObject:message];
    }
    
    [self.arrayMessages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GANMessageDataModel *msg1 = obj1;
        GANMessageDataModel *msg2 = obj2;
        return [msg1.dateSent compare:msg2.dateSent];
    }];
    
    [self refreshTableview];
}
- (void) refreshMessageThread {
    [self refreshTableview];
}

- (void) refreshTableview{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
        [self scrollToBottom];
    });
}

#pragma mark - Logic

- (void) sendMessage{
    if (self.textfieldInput.text.length == 0) {
        [GANGlobalVCManager shakeView:self.viewInputWrapper];
        return;
    }
    [self doSendMessage];
}

- (void) doSendMessage{
    NSArray *arrReceivers;
    arrReceivers = @[@{@"user_id": self.modelReceiver.szUserId, @"company_id": self.modelReceiver.szCompanyId}];
    
    NSString *szMessage = self.textfieldInput.text;
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    
    [[GANMessageManager sharedInstance] requestSendMessageWithJobId:@"NONE" Type:GANENUM_MESSAGE_TYPE_MESSAGE Receivers:arrReceivers ReceiversPhoneNumbers: nil Message:szMessage MetaData: nil AutoTranslate:NO FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            // Message is successfully sent!
            [GANGlobalVCManager showHudSuccessWithMessage:@"Éxito! Su mensaje ha sido enviado" DismissAfter:-1 Callback:^{
                [self buildMessageList];
                self.textfieldInput.text = @"";
            }];
        }
        else {
            // Sorry, we've encountered an issue.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:-1 Callback:nil];
        }
    }];
    
    GANACTIVITY_REPORT(@"Worker - Reply Message");
}

- (void) callPhoneNumber: (NSString *) phoneNumber{
    phoneNumber = [GANGenericFunctionManager beautifyPhoneNumber:phoneNumber CountryCode:@"US"];
    
    // Title: Confirmation, Message: Do you want to call %@?
    [GANGlobalVCManager promptWithVC:self Title:@"Confirmación" Message:[NSString stringWithFormat:@"Quieres llamar a %@?", phoneNumber] ButtonYes:@"Yes" ButtonNo:@"NO" CallbackYes:^{
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",[GANGenericFunctionManager stripNonnumericsFromNSString:phoneNumber]]];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
            GANACTIVITY_REPORT(@"Worker - Call phone");
        }
        else{
            // Your device does not support phone calls
            [GANGlobalVCManager showHudErrorWithMessage:@"Tu dispositivo no es compatible con llamadas telefónicas" DismissAfter:-1 Callback:nil];
        }
    } CallbackNo:nil];
}

- (void) gotoJobDetailsAtIndex: (int) index{
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    if ([message amISender] == YES){
        [self gotoJobDetailsVCWithJobId:message.szJobId CompanyId:[message getPrimaryReceiver].szCompanyId];
    }
    else {
        [self gotoJobDetailsVCWithJobId:message.szJobId CompanyId:message.modelSender.szCompanyId];
    }
    GANACTIVITY_REPORT(@"Worker - Go to job details from Message item");
}

- (void) gotoJobDetailsVCWithJobId: (NSString *) jobId CompanyId: (NSString *) companyId{
    if ([GANJobManager isValidJobId:jobId] == NO) return;
    if (companyId.length == 0) return;
    
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [managerCache requestGetCompanyDetailsByCompanyId:companyId Callback:^(int indexCompany) {
        if (indexCompany == -1) {
            [GANGlobalVCManager hideHudProgress];
            return;
        }
        
        GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
        [company requestJobsListWithJobId:jobId Callback:^(int status) {
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                if (status != SUCCESS_WITH_NO_ERROR){
                    return;
                }
                int indexJob = [company getIndexForJob:jobId];
                if (indexJob == -1) return;
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
                GANWorkerJobDetailsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_JOBDETAILS"];
                vc.indexCompany = indexCompany;
                vc.indexJob = indexJob;
                
                [self.navigationController pushViewController:vc animated:YES];
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            }];
        }];
    }];
}
- (void) gotoSurveyDetailsAtIndex: (int) index {
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    if ([message isSurveyMessage] == NO){
        return;
    }
    
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];

    [managerCache requestGetIndexForSurveyBySurveyId:message.szSurveyId Callback:^(int index) {
        if (index == -1){
            // Sorry, we've encountered an error.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:-1 Callback:nil];
        }
        else {
            GANSurveyDataModel *survey = [managerCache.arraySurvey objectAtIndex:index];
            [GANGlobalVCManager hideHudProgressWithCallback:^{
                if (survey.enumType == GANENUM_SURVEYTYPE_CHOICESINGLE) {
                    [self gotoWorkerSurveyChoicesVCAtSurveyIndex:index];
                }
                else if (survey.enumType == GANENUM_SURVEYTYPE_OPENTEXT) {
                    [self gotoWorkerSurveyOpenTextVCAtSurveyIndex:index];
                }
            }];
        }
    }];
}

- (void) gotoWorkerSurveyChoicesVCAtSurveyIndex: (int) indexSurvey{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WorkerMessage" bundle:nil];
    GANWorkerSurveyChoicesVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_SURVEY_CHOICESINGLE"];
    vc.indexSurvey = indexSurvey;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Worker - Go to Survey Details from Message");
}

- (void) gotoWorkerSurveyOpenTextVCAtSurveyIndex: (int) indexSurvey{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WorkerMessage" bundle:nil];
    GANWorkerSurveyOpenTextVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_SURVEY_OPENTEXT"];
    vc.indexSurvey = indexSurvey;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Worker - Go to Survey Details from Message");
}

#pragma mark - UITableView Delegate

- (void) configureCellYou: (GANMessageItemYouTVC *) cell AtIndex: (int) index{
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    
    cell.labelTimestamp.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    int indexCell = index;
    cell.index = indexCell;
    
    if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE) {
        cell.labelMessage.text = [message getContentsES];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT) {
        cell.labelMessage.text = [NSString stringWithFormat:@"Reclutado: "];
        
        [managerCache requestGetCompanyDetailsByCompanyId:message.modelSender.szCompanyId Callback:^(int indexCompany) {
            if (indexCompany == -1) {
                return;
            }
            
            GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
            [company requestJobsListWithJobId:message.szJobId Callback:^(int status) {
                if (status != SUCCESS_WITH_NO_ERROR){
                    return;
                }
                // Check if cell is already re-initiated for new item
                if (cell.index != indexCell) return;
                int indexJob = [company getIndexForJob:message.szJobId];
                if (indexJob != -1){
                    GANJobDataModel *job = [company.arrJobs objectAtIndex:indexJob];
                    cell.labelMessage.text = [NSString stringWithFormat:@"Reclutado: %@", [job getTitleES]];        // Recruited:
                }
                else {
                    cell.labelMessage.text = @"Reclutado: No se encontró el trabajo";            // Job not found
                }
            }];
        }];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE ||
             message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT) {
        cell.labelMessage.text = [NSString stringWithFormat:@"Encuesta: Toca para responder de forma anónima"];
        [managerCache requestGetIndexForSurveyBySurveyId:message.szSurveyId Callback:^(int index) {
            // Check if cell is already re-initiated for new item
            if (cell.index != indexCell) return;
            if (index == -1){
            }
            else {
                GANSurveyDataModel *survey = [managerCache.arraySurvey objectAtIndex:index];
                cell.labelMessage.text = [NSString stringWithFormat:@"Encuesta: %@\rToca para responder de forma anónima.", [survey.modelQuestion getTextES]];
            }
        }];
    }
    else {
        cell.labelMessage.text = [message getContentsEN];
    }
    
    if ([message hasLocationInfo] == YES) {
        [cell showMapWithLatitude:message.locationInfo.fLatitude Longitude:message.locationInfo.fLongitude];
    }
    else {
        [cell hideMap];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) configureCellMe: (GANMessageItemMeTVC *) cell AtIndex: (int) index{
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    
    int indexCell = index;
    cell.index = indexCell;
    cell.labelTimestamp.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE) {
        cell.labelMessage.text = [message getContentsEN];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_APPLICATION) {
        // Job application:
        cell.labelMessage.text = [NSString stringWithFormat:@"Solicitud de trabajo: "];
        
        [managerCache requestGetCompanyDetailsByCompanyId:self.modelReceiver.szCompanyId Callback:^(int indexCompany) {
            if (indexCompany == -1) {
                return;
            }
            
            GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
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
                    cell.labelMessage.text = @"Solicitud de trabajo: No se encontró el trabajo";    // Job not found
                }
            }];
        }];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_SUGGEST) {
        cell.labelMessage.text = [NSString stringWithFormat:@"Solicitud de trabajo: Sugerir amigo %@", [message getPhoneNumberForSuggestFriend]];
        [managerCache requestGetCompanyDetailsByCompanyId:self.modelReceiver.szCompanyId Callback:^(int indexCompany) {
            if (indexCompany == -1) {
                return;
            }
            
            GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
            [company requestJobsListWithJobId:message.szJobId Callback:^(int status) {
                // Check if cell is already re-initiated for new item
                if (cell.index != indexCell) return;
                if (status != SUCCESS_WITH_NO_ERROR){
                    return;
                }
                int indexJob = [company getIndexForJob:message.szJobId];
                if (indexJob != -1){
                    GANJobDataModel *job = [company.arrJobs objectAtIndex:indexJob];
                    cell.labelMessage.text = [NSString stringWithFormat:@"Solicitud de trabajo: Sugerir amigo %@ para %@", [message getPhoneNumberForSuggestFriend], [job getTitleES]];       // Job application:
                }
                else {
                    cell.labelMessage.text = @"Solicitud de trabajo: No se encontró el trabajo";    // Job not found
                }
            }];
        }];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) {
        cell.labelMessage.text = [NSString stringWithFormat:@"Encuesta: Usted contestó la encuesta."];
        [managerCache requestGetIndexForSurveyBySurveyId:message.szSurveyId Callback:^(int index) {
            // Check if cell is already re-initiated for new item
            if (cell.index != indexCell) return;
            if (index == -1){
            }
            else {
                GANSurveyDataModel *survey = [managerCache.arraySurvey objectAtIndex:index];
                cell.labelMessage.text = [NSString stringWithFormat:@"Encuesta: %@\rUsted contestó la encuesta.", [survey.modelQuestion getTextES]];
            }
        }];
    }
    else {
        cell.labelMessage.text = [message getContentsES];
    }
    
    if ([message hasLocationInfo] == YES) {
        [cell showMapWithLatitude:message.locationInfo.fLatitude Longitude:message.locationInfo.fLongitude];
    }
    else {
        [cell hideMap];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    if ([message amISender] == YES) {
        GANMessageItemMeTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_MESSAGEITEM_ME"];
        [self configureCellMe:cell AtIndex:(int) indexPath.row];
        return cell;
    }
    else {
        GANMessageItemYouTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_MESSAGEITEM_YOU"];
        [self configureCellYou:cell AtIndex:(int) indexPath.row];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    
    if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT ||
        message.enumType == GANENUM_MESSAGE_TYPE_APPLICATION){
        [self gotoJobDetailsAtIndex:index];
    }
    else if ([message isSurveyMessage] == YES){
        [self gotoSurveyDetailsAtIndex:index];
    }
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonSendClick:(id)sender {
    [self.view endEditing:YES];
    [self sendMessage];
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

