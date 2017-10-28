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
#import "GANCompanyManager.h"
#import "GANCacheManager.h"
#import "GANUserManager.h"
#import "GANSurveyManager.h"
#import "GANAppManager.h"

#import "GANCompanyMessageComposerVC.h"
#import "GANCompanySurveyChoicesResultVC.h"
#import "GANCompanySurveyOpenTextResultVC.h"

#import "GANGenericFunctionManager.h"
#import "Global.h"
#import "GANGlobalVCManager.h"


@interface GANCompanyMessagesVC () <UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;

@property (weak, nonatomic) IBOutlet UIView *viewPopupWrapper;
@property (weak, nonatomic) IBOutlet UIView *viewPopupPanel;
@property (weak, nonatomic) IBOutlet UIView *viewMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnAutoTranslate;
@property (weak, nonatomic) IBOutlet UIButton *btnReply;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPopupPanelBottomSpace;
@property (weak, nonatomic) IBOutlet UILabel *lblReplyTitle;

@property (assign, atomic) BOOL isPopupShowing;
@property (assign, atomic) BOOL isAutoTranslate;
@property (assign, atomic) int indexMessageForReply;
@property (assign, atomic) BOOL isVCVisible;

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
    
    self.isVCVisible = NO;
    self.isPopupShowing = NO;
    self.isAutoTranslate = NO;
    self.arrMessages = [[NSMutableArray alloc] init];
    
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
    self.btnSendMessage.layer.cornerRadius = 3;
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
        if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) continue;
        
        [self.arrMessages addObject:message];
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
    GANACTIVITY_REPORT(@"Company - Go to send message from Messages");
}

#pragma mark - UI Stuff

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
    
    self.textview.text = @"";
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

- (void) callSuggestedFriendAtIndex: (int) indexMessage{
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:indexMessage];
    NSString *phoneNumber = [message getPhoneNumberForSuggestFriend];
    [GANGlobalVCManager promptWithVC:self Title:@"Confirmation" Message:[NSString stringWithFormat:@"Do you want to call %@?", phoneNumber] ButtonYes:@"Yes" ButtonNo:@"NO" CallbackYes:^{
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",[GANGenericFunctionManager stripNonnumericsFromNSString:phoneNumber]]];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
            GANACTIVITY_REPORT(@"Company - Call phone");
        }
        else{
            [GANGlobalVCManager showHudErrorWithMessage:@"Your device does not support phone calls" DismissAfter:-1 Callback:nil];
        }
    } CallbackNo:nil];
}

- (void) callPhoneNumber: (NSString *) phoneNumber{
    phoneNumber = [GANGenericFunctionManager beautifyPhoneNumber:phoneNumber CountryCode:@"US"];
    
    [GANGlobalVCManager promptWithVC:self Title:@"Confirmation" Message:[NSString stringWithFormat:@"Do you want to call %@?", phoneNumber] ButtonYes:@"Yes" ButtonNo:@"NO" CallbackYes:^{
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",[GANGenericFunctionManager stripNonnumericsFromNSString:phoneNumber]]];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
            GANACTIVITY_REPORT(@"Company - Call phone");
        }
        else{
            [GANGlobalVCManager showHudErrorWithMessage:@"Your device does not support phone calls" DismissAfter:-1 Callback:nil];
        }
    } CallbackNo:nil];
}

- (void) doReplyMessage{
    /*
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:self.indexMessageForReply];
    NSArray *arrReceivers;
    
    if ([message amISender] == YES){
        arrReceivers = @[@{@"user_id": message.szReceiverUserId, @"company_id": message.szReceiverCompanyId}];
    }
    else {
        arrReceivers = @[@{@"user_id": message.szSenderUserId, @"company_id": message.szSenderCompanyId}];
    }
    
    NSString *szMessage = self.textview.text;
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANMessageManager sharedInstance] requestSendMessageWithJobId:@"NONE" Type:GANENUM_MESSAGE_TYPE_MESSAGE Receivers:arrReceivers ReceiversPhoneNumbers: nil Message:szMessage MetaData: nil AutoTranslate:self.isAutoTranslate FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Message is succesfully sent!" DismissAfter:-1 Callback:^{
                [self animateToHidePopup];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
     */
    GANACTIVITY_REPORT(@"Company - Reply message");
}

// MARK: ActionSheet for Survey

- (void) showActionSheetForSurveyAtIndex: (int) index{
    /*
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
    if ([message isSurveyMessage] == NO){
        return;
    }
    
    NSString *szUserId = @"";
    if ([message amISender] == YES){
        szUserId = message.szReceiverUserId;
    }
    else {
        szUserId = message.szSenderUserId;
    }
    
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    int indexMyWorker = [managerCompany getIndexForMyWorkersWithUserId:szUserId];
    if (indexMyWorker == -1) return;
    
    GANSurveyManager *managerSurvey = [GANSurveyManager sharedInstance];
    int indexSurvey = [managerSurvey getIndexForSurveyWithSurveyId:message.szSurveyId];
    if (indexSurvey == -1) return;
    GANSurveyDataModel *survey = [managerSurvey.arraySurveys objectAtIndex:indexSurvey];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Cancel
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    // View Survey Results
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"View Survey Results" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (survey.enumType == GANENUM_SURVEYTYPE_CHOICESINGLE) {
            [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
            [survey requestGetAnswersWithCallback:^(int status) {
                [GANGlobalVCManager hideHudProgressWithCallback:^{
                    [self gotoSurveyChoicesResultVCAtSurveyIndex:indexSurvey];
                }];
            }];
        }
        else if (survey.enumType == GANENUM_SURVEYTYPE_OPENTEXT) {
            [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
            [survey requestGetAnswersWithCallback:^(int status) {
                [GANGlobalVCManager hideHudProgressWithCallback:^{
                    [self gotoSurveyOpenTextResultVCAtSurveyIndex:indexSurvey];
                }];
            }];
        }
    }]];
    
    // Reply with message
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Send Message" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self gotoMessageComposerVCAtMyWorkerIndex:indexMyWorker];
        });
    }]];
    
    // Present action sheet.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:actionSheet animated:YES completion:nil];
    });
     */
}

- (void) replyMessageAtIndex: (int) index{
    /*
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
    
    NSString *szUserId = @"";
    if ([message amISender] == YES){
        szUserId = message.szReceiverUserId;
    }
    else {
        szUserId = message.szSenderUserId;
    }
    
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    int indexMyWorker = [managerCompany getIndexForMyWorkersWithUserId:szUserId];
    if (indexMyWorker == -1) return;
    
    [self gotoMessageComposerVCAtMyWorkerIndex:indexMyWorker];
     */
}

- (void) gotoMessageComposerVCAtMyWorkerIndex: (int) indexMyWorker{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
    GANCompanyMessageComposerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGE_COMPOSER"];
    vc.arrayReceivers = @[[[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:indexMyWorker]];
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to MessageComposer from Messages");
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

- (void) configureCell: (GANMessageItemTVC *) cell AtIndex: (int) index{
    /*
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    
    cell.lblDateTime.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    BOOL amISender = [message amISender];
    
    if (amISender == YES){
        if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
            cell.lblTitle.text = @"Message sent";
            cell.lblMessage.text = [message getContentsEN];
            [managerCache requestGetIndexForUserByUserId:message.szReceiverUserId Callback:^(int index) {
                if (index == -1) return;
                GANUserBaseDataModel *user = [managerCache.arrayUsers objectAtIndex:index];
                [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                    cell.lblTitle.text = [NSString stringWithFormat:@"Message To %@", displayName];
                }];
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT){
            cell.lblTitle.text = @"Recruit";
            cell.lblMessage.text = [message getContentsEN];
            
            int indexJob = [managerJob getIndexForMyJobsByJobId:message.szJobId];
            if (indexJob != -1){
                GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:indexJob];
                cell.lblMessage.text = [NSString stringWithFormat:@"Job: %@", [job getTitleEN]];
            }
            else {
                cell.lblMessage.text = @"Job not found";
            }
            
            [managerCache requestGetIndexForUserByUserId:message.szReceiverUserId Callback:^(int index) {
                if (index == -1) return;
                GANUserBaseDataModel *user = [managerCache.arrayUsers objectAtIndex:index];
                [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                    cell.lblTitle.text = [NSString stringWithFormat:@"Recruited %@", displayName];
                }];
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE ||
                 message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT){
            cell.lblTitle.text = @"Survey";
            cell.lblMessage.text = [message getContentsEN];
            
            [managerCache requestGetIndexForUserByUserId:message.szReceiverUserId Callback:^(int index) {
                if (index == -1) return;
                GANUserBaseDataModel *user = [managerCache.arrayUsers objectAtIndex:index];
                [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                    cell.lblTitle.text = [NSString stringWithFormat:@"Survey To %@", displayName];
                }];
            }];
        }
    }
    else {
        if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE){
            cell.lblTitle.text = @"Message received";
            cell.lblMessage.text = [message getContentsEN];
            [managerCache requestGetIndexForUserByUserId:message.szSenderUserId Callback:^(int index) {
                if (index == -1) return;
                GANUserBaseDataModel *user = [managerCache.arrayUsers objectAtIndex:index];
                [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                    cell.lblTitle.text = [NSString stringWithFormat:@"Message from %@", displayName];
                }];
            }];
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
            
            [[GANCacheManager sharedInstance] requestGetIndexForUserByUserId:message.szSenderUserId Callback:^(int index) {
                if (index != -1){
                    GANUserBaseDataModel *user = [[GANCacheManager sharedInstance].arrayUsers objectAtIndex:index];
                    [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                        cell.lblMessage.text = [NSString stringWithFormat:@"Reply to %@", displayName];
                    }];
                }
            }];
        }
        else if (message.enumType == GANENUM_MESSAGE_TYPE_SUGGEST){
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
            
            [[GANCacheManager sharedInstance] requestGetIndexForUserByUserId:message.szSenderUserId Callback:^(int index) {
                if (index != -1){
                    GANUserBaseDataModel *user = [[GANCacheManager sharedInstance].arrayUsers objectAtIndex:index];
                    [managerCompany getBestUserDisplayNameWithUserId:user.szId Callback:^(NSString *displayName) {
                        cell.lblMessage.text = [NSString stringWithFormat:@"%@ suggested worker @%@", displayName, [message getPhoneNumberForSuggestFriend]];
                    }];
                }
            }];
        }
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
    }
    
    if([message hasLocationInfo] == YES) {
        cell.locationCenter = [[CLLocation alloc]initWithLatitude:message.locationInfo.fLatitude longitude:message.locationInfo.fLongitude];
    }
    else {
        cell.locationCenter = nil;
    }
    
    cell.lblMessage.delegate = self;
    
    BOOL didRead = !([message amIReceiver] && message.enumStatus == GANENUM_MESSAGE_STATUS_NEW);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell refreshViewsWithType:message.enumType DidRead:didRead DidSend:amISender];
     */
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
    GANMessageDataModel *message = [self.arrMessages objectAtIndex:index];
    
    if (message.enumType == GANENUM_MESSAGE_TYPE_SUGGEST){
        [self callSuggestedFriendAtIndex:index];
    }
    else if ([message isSurveyMessage] == YES){
        [self showActionSheetForSurveyAtIndex:index];
    }
    else {
        [self replyMessageAtIndex:index];
    }
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnSendMessageClick:(id)sender {
    [self gotoSendMessageVC];
}

- (IBAction)onBtnTranslateClick:(id)sender {
    [self.view endEditing:YES];
    self.isAutoTranslate = !self.isAutoTranslate;
    [self refreshAutoTranslateView];
}

- (IBAction)onBtnReplyClick:(id)sender {
    [self.view endEditing:YES];
    NSString *sz = self.textview.text;
    if (sz.length == 0){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please enter a message to send" DismissAfter:-1 Callback:nil];
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
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
    [self callPhoneNumber:phoneNumber];
}

@end
