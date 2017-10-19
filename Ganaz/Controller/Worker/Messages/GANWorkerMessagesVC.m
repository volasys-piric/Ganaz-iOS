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

#import "GANCacheManager.h"
#import "GANGlobalVCManager.h"
#import "GANWorkerJobDetailsVC.h"
#import "GANWorkerSurveyChoicesVC.h"
#import "GANWorkerSurveyOpenTextVC.h"

#import "Global.h"
#import "GANGenericFunctionManager.h"
#import "GANAppManager.h"

@interface GANWorkerMessagesVC () <UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *arrMessages;

@property (weak, nonatomic) IBOutlet UIView *viewPopupWrapper;
@property (weak, nonatomic) IBOutlet UIView *viewPopupPanel;
@property (weak, nonatomic) IBOutlet UIView *viewMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnAutoTranslate;
@property (weak, nonatomic) IBOutlet UIButton *btnReply;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPopupPanelBottomSpace;
@property (weak, nonatomic) IBOutlet UILabel *lblReplyTitle;

@property (assign, atomic) BOOL isVCVisible;
@property (assign, atomic) BOOL isPopupShowing;
@property (assign, atomic) BOOL isAutoTranslate;
@property (assign, atomic) int indexMessageForReply;

@end

@implementation GANWorkerMessagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 75;
    
    self.isVCVisible = NO;
    self.isAutoTranslate = NO;
    self.isPopupShowing = NO;
    self.arrMessages = [[NSMutableArray alloc] init];
    
    [self.btnReply setTitle:@"Responder" forState:UIControlStateNormal];        // Reply
    
    [self buildMessageList];
    [self registerTableViewCellFromNib];
    [self refreshViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(refreshData) userInfo:nil repeats:YES];    
}

- (void) refreshData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
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
    [self.tableview registerNib:[UINib nibWithNibName:@"GANMessageItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_MESSAGEITEM"];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.isVCVisible = YES;
    [self updateReadStatusIfNeeded];
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.isVCVisible = NO;
}

- (void) updateReadStatusIfNeeded{
    if (self.isVCVisible == NO) return;
    if (self.navigationController.visibleViewController != self) return;
    if ([[GANMessageManager sharedInstance] getUnreadMessageCount] > 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[GANMessageManager sharedInstance] requestMarkAsReadAllMessagesWithCallback:nil];
        });
    }
}
- (void) refreshViews{
    [self buildMessageList];
    self.btnReply.layer.cornerRadius = 3;
    self.viewMessage.layer.cornerRadius = 3;
    [self refreshAutoTranslateView];
}

- (void) refreshAutoTranslateView{
    if (self.isAutoTranslate == YES){
        [self.btnAutoTranslate setImage:[UIImage imageNamed:@"icon-checked"] forState:UIControlStateNormal];
    }
    else {
        [self.btnAutoTranslate setImage:[UIImage imageNamed:@"icon-unchecked"] forState:UIControlStateNormal];
    }
}

- (void) buildMessageList{
    [GANGlobalVCManager updateMessageBadge];
    
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    [self.arrMessages removeAllObjects];
    
    for (int i = 0; i < (int) [managerMessage.arrMessages count]; i++){
        GANMessageDataModel *message = [managerMessage.arrMessages objectAtIndex:i];
        if ([message amIReceiver] == NO && [message amISender] == NO) continue;
        [self.arrMessages addObject:message];
    }
    
    [self.arrMessages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GANMessageDataModel *msg1 = obj1;
        GANMessageDataModel *msg2 = obj2;
        return [msg2.dateSent compare:msg1.dateSent];
    }];
    
    [self.tableview reloadData];
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
            
            [self.navigationController pushViewController:vc animated:YES];
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        }];
    }];
}

#pragma mark - UI Stuff

- (void) showPopupForReplyMessage: (BOOL) isAutoTranslate{
    // If incoming message is translated, the outgoing message will be translated automatically.
    self.isAutoTranslate = isAutoTranslate;
    self.textview.text = @"";
    [self animateToShowPopup];
}

- (void) animateToShowPopup{
    if (self.isPopupShowing == YES) return;
    self.isPopupShowing = YES;
    
    // Animate to show
    int height = (int) self.viewPopupPanel.frame.size.height;
    
    self.viewPopupWrapper.hidden = NO;
    self.viewPopupWrapper.alpha = 0;
    self.constraintPopupPanelBottomSpace.constant = -height;
    [self.viewPopupWrapper layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.constraintPopupPanelBottomSpace.constant = 0;
        self.viewPopupWrapper.alpha = 1;
        [self.viewPopupWrapper layoutIfNeeded];
    }];
}

- (void) animateToHidePopup{
    if (self.isPopupShowing == NO) return;
    
    self.isPopupShowing = NO;
    int height = (int) self.viewPopupPanel.frame.size.height;
    
    self.constraintPopupPanelBottomSpace.constant = 0;
    self.viewPopupWrapper.alpha = 1;
    [self.viewPopupWrapper layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.constraintPopupPanelBottomSpace.constant = -height;
        self.viewPopupWrapper.alpha = 0;
        [self.viewPopupWrapper layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished == YES){
            self.viewPopupWrapper.hidden = YES;
        }
    }];
}

#pragma mark - Biz Logic

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

- (void) showActionSheetForMessageAtIndex: (int) index{
    GANLOG(@"Message item clicked at index = %d", index);
    
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
    if (message.enumType == GANENUM_MESSAGE_TYPE_SUGGEST){
        return;
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
        [self replyMessageAtIndex:index];
    }
    else if ((message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT) || (message.enumType == GANENUM_MESSAGE_TYPE_APPLICATION)){
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        // Cancel
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        
        // View Job Details
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Ver más" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self gotoMessageDetailsAtIndex: index];
        }]];
        
        // Reply with message
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Responder" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self replyMessageAtIndex:index];
        }]];
        
        // Present action sheet.
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE ||
             message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT ||
             message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) {
        GANCacheManager *managerCache = [GANCacheManager sharedInstance];
        [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
        [managerCache requestGetIndexForSurveyBySurveyId:message.szSurveyId Callback:^(int index) {
            if (index == -1){
                [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error." DismissAfter:-1 Callback:nil];
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
}

- (void) gotoMessageDetailsAtIndex: (int) index{
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
    if ([message amISender] == YES){
        [self gotoJobDetailsVCWithJobId:message.szJobId CompanyId:message.szReceiverCompanyId];
    }
    else {
        [self gotoJobDetailsVCWithJobId:message.szJobId CompanyId:message.szSenderCompanyId];
    }
    GANACTIVITY_REPORT(@"Worker - Go to job details from Message item");
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

- (void) replyMessageAtIndex: (int) index{
    self.indexMessageForReply = index;
    
    // Reply
    self.lblReplyTitle.text = @"Responder";
    
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
    
    NSString *szCompanyId = @"";
    if ([message amISender] == YES){
        szCompanyId = message.szReceiverCompanyId;
    }
    else {
        szCompanyId = message.szSenderCompanyId;
    }
    [managerCache requestGetCompanyDetailsByCompanyId:szCompanyId Callback:^(int indexCompany) {
        if (indexCompany != -1){
            GANCompanyDataModel *company = [[GANCacheManager sharedInstance].arrayCompanies objectAtIndex:indexCompany];
            // Reply to
            self.lblReplyTitle.text = [NSString stringWithFormat:@"Responder a %@", [company getBusinessNameES]];
        }
    }];
    
    [self showPopupForReplyMessage:message.isAutoTranslate];
}

- (void) doReplyMessage{
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:self.indexMessageForReply];
    NSArray *arrReceivers;
    
    if ([message amISender] == YES){
        arrReceivers = @[@{@"user_id": message.szReceiverUserId, @"company_id": message.szReceiverCompanyId}];
    }
    else {
        arrReceivers = @[@{@"user_id": message.szSenderUserId, @"company_id": message.szSenderCompanyId}];
    }
    
    NSString *szMessage = self.textview.text;
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    
    [[GANMessageManager sharedInstance] requestSendMessageWithJobId:@"NONE" Type:GANENUM_MESSAGE_TYPE_MESSAGE Receivers:arrReceivers ReceiversPhoneNumbers: nil Message:szMessage MetaData: nil AutoTranslate:self.isAutoTranslate FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            // Message is successfully sent!
            [GANGlobalVCManager showHudSuccessWithMessage:@"Éxito! Su mensaje ha sido enviado" DismissAfter:-1 Callback:^{
                [self animateToHidePopup];
            }];
        }
        else {
            // Sorry, we've encountered an issue.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error." DismissAfter:-1 Callback:nil];
        }
    }];
    
    GANACTIVITY_REPORT(@"Worker - Reply Message");
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANMessageItemTVC *) cell AtIndex: (int) index{
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];

    cell.lblDateTime.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    BOOL amISender = [message amISender];
    if (amISender == YES){
        if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
            cell.lblTitle.text = @"Mensaje enviado";       // Message sent
            cell.lblMessage.text = [message getContentsES];
            [managerCache requestGetCompanyDetailsByCompanyId:message.szReceiverCompanyId Callback:^(int indexCompany) {
                if (indexCompany != -1){
                    GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                    cell.lblTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                }
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_APPLICATION){
            cell.lblTitle.text = @"Solicitud de trabajo";                   // Job application
            cell.lblMessage.text = @"Nueva solicitud de trabajo";           // New job inquiry
            
            [managerCache requestGetCompanyDetailsByCompanyId:message.szReceiverCompanyId Callback:^(int indexCompany) {
                if (indexCompany == -1) {
                    return;
                }
                
                GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                cell.lblTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                
                [company requestJobsListWithJobId:message.szJobId Callback:^(int status) {
                    if (status != SUCCESS_WITH_NO_ERROR){
                        return;
                    }
                    int indexJob = [company getIndexForJob:message.szJobId];
                    if (indexJob != -1){
                        GANJobDataModel *job = [company.arrJobs objectAtIndex:indexJob];
                        cell.lblMessage.text = [NSString stringWithFormat:@"Solicitud de trabajo: %@", [job getTitleES]];       // Job application:
                    }
                    else {
                        cell.lblMessage.text = @"No se encontró el trabajo";    // Job not found
                    }
                }];
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SUGGEST){
            // Suggest Friend
            cell.lblTitle.text = @"Amigo sugerido";                           // Job application
            cell.lblMessage.text = @"Nueva solicitud de trabajo";             // New job inquiry
            
            [managerCache requestGetCompanyDetailsByCompanyId:message.szReceiverCompanyId Callback:^(int indexCompany) {
                if (indexCompany == -1) {
                    return;
                }
                
                GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                cell.lblTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                
                [company requestJobsListWithJobId:message.szJobId Callback:^(int status) {
                    if (status != SUCCESS_WITH_NO_ERROR){
                        return;
                    }
                    int indexJob = [company getIndexForJob:message.szJobId];
                    if (indexJob != -1){
                        GANJobDataModel *job = [company.arrJobs objectAtIndex:indexJob];
                        // Suggest Friend {phone number} for {job title}
                        cell.lblMessage.text = [NSString stringWithFormat:@"Sugerir amigo %@ para %@",[message getPhoneNumberForSuggestFriend], [job getTitleES]];       // Suggest Friend:
                    }
                    else {
                        cell.lblMessage.text = @"No se encontró el trabajo";    // Job not found
                    }
                }];
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER){
            cell.lblTitle.text = @"Encuesta";
            // You answered survey.
            cell.lblMessage.text = @"Usted contestó la encuesta.";
            
            [managerCache requestGetIndexForSurveyBySurveyId:message.szSurveyId Callback:^(int index) {
                if (index != -1){
                    cell.lblTitle.text = [[managerCache.arraySurvey objectAtIndex:index].modelQuestion getTextES];
                }
            }];
        }
    }
    else {
        if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
            cell.lblTitle.text = @"Mensaje recibido";           // Message received
            cell.lblMessage.text = [message getContentsES];
            [managerCache requestGetCompanyDetailsByCompanyId:message.szSenderCompanyId Callback:^(int indexCompany) {
                if (index != -1){
                    GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                    cell.lblTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                }
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT){
            cell.lblTitle.text = @"Reclutado";              // Recruited
            cell.lblMessage.text = @"Reclutado";            // Recruited
            [managerCache requestGetCompanyDetailsByCompanyId:message.szSenderCompanyId Callback:^(int indexCompany) {
                if (indexCompany == -1) {
                    return;
                }
                
                GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                cell.lblTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];

                [company requestJobsListWithJobId:message.szJobId Callback:^(int status) {
                    if (status != SUCCESS_WITH_NO_ERROR){
                        return;
                    }
                    int indexJob = [company getIndexForJob:message.szJobId];
                    if (indexJob != -1){
                        GANJobDataModel *job = [company.arrJobs objectAtIndex:indexJob];
                        cell.lblMessage.text = [NSString stringWithFormat:@"Trabajo: %@", [job getTitleES]];        // Job:
                    }
                    else {
                        cell.lblMessage.text = @"No se encontró el trabajo";            // Job not found
                    }
                }];
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE ||
                 message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT){
            // Survey
            cell.lblTitle.text = @"Encuesta";
            cell.lblMessage.text = [message getContentsES];
            
            [managerCache requestGetCompanyDetailsByCompanyId:message.szSenderCompanyId Callback:^(int indexCompany) {
                if (index != -1){
                    GANCompanyDataModel *company = [managerCache.arrayCompanies objectAtIndex:indexCompany];
                    cell.lblTitle.text = [NSString stringWithFormat:@"%@", [company getBusinessNameES]];
                }
            }];
        }
    }
    
    cell.lblMessage.delegate = self;
    
    if([message hasLocationInfo] == YES) {
        cell.locationCenter = [[CLLocation alloc]initWithLatitude:message.locationInfo.fLatitude longitude:message.locationInfo.fLongitude];
    }
    else {
        cell.locationCenter = nil;
    }
    
    BOOL didRead = !([message amIReceiver] && message.enumStatus == GANENUM_MESSAGE_STATUS_NEW);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell refreshViewsWithType:message.enumType DidRead:didRead DidSend:amISender];
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
    [self showActionSheetForMessageAtIndex:index];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnTranslateClick:(id)sender {
    [self.view endEditing:YES];
    self.isAutoTranslate = !self.isAutoTranslate;
    [self refreshAutoTranslateView];
}

- (IBAction)onBtnReplyClick:(id)sender {
    [self.view endEditing:YES];
    NSString *sz = self.textview.text;
    if (sz.length == 0){
        // Please input message to send.
        [GANGlobalVCManager showHudErrorWithMessage:@"Por favor ingrese el mensaje para enviar." DismissAfter:-1 Callback:nil];
        return;
    }
    [self doReplyMessage];
}

- (IBAction)onBtnPopupWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self animateToHidePopup];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATED]) ||
        ([[notification name] isEqualToString:GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED])){
        [self buildMessageList];
        [self updateReadStatusIfNeeded];
    }
    else if ([[notification name] isEqualToString:GANLOCALNOTIFICATION_CONTENTS_TRANSLATED]){
        [self.tableview reloadData];
    }
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
    [self callPhoneNumber:phoneNumber];
}

@end
