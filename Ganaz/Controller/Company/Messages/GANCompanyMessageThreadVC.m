//
//  GANCompanyMessageThreadVC.m
//  Ganaz
//
//  Created by Piric Djordje on 10/31/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyMessageThreadVC.h"
#import "GANMessageItemMeTVC.h"
#import "GANMessageItemYouTVC.h"
#import "GANCompanyMapPopupVC.h"
#import "GANMessageWithChargeConfirmationPopupVC.h"
#import "GANFadeTransitionDelegate.h"

#import "GANCompanyManager.h"
#import "GANMessageManager.h"
#import "GANJobManager.h"
#import "GANAppManager.h"

#import "Global.h"
#import "UIColor+GANColor.h"
#import "GANGlobalVCManager.h"
#import "GANGenericFunctionManager.h"
#import <IQKeyboardManager.h>

@interface GANCompanyMessageThreadVC () <UITableViewDelegate, UITableViewDataSource, GANCompanyMapPopupVCDelegate, GANMessageWithChargeConfirmationPopupDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewInputWrapper;
@property (weak, nonatomic) IBOutlet UIImageView *imageAttachMap;
@property (weak, nonatomic) IBOutlet UIButton *buttonAttachMap;
@property (weak, nonatomic) IBOutlet UIButton *buttonTranslate;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITextField *textfieldInput;

@property (strong, nonatomic) NSMutableArray <GANMessageDataModel *> *arrayMessages;
@property (strong, nonatomic) NSArray<GANMessageReceiverDataModel *> *arrayReceivers;

@property (assign, atomic) float fIQKeyboardDistance;
@property (assign, atomic) BOOL isVCVisible;
@property (assign, atomic) BOOL isAutoTranslate;
@property (strong, nonatomic) GANLocationDataModel *modelLocation;
@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@end

@implementation GANCompanyMessageThreadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.textfieldInput.inputAccessoryView = [[UIView alloc] init];
    
    self.isVCVisible = NO;
    self.isAutoTranslate = YES;
    self.fIQKeyboardDistance = IQKeyboardManager.sharedManager.keyboardDistanceFromTextField;
    
    self.arrayMessages = [[NSMutableArray alloc] init];
    [self registerTableViewCellFromNib];
    
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    self.modelLocation = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];

    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(refreshTableview) userInfo:nil repeats:YES];

    GANMessageThreadDataModel *thread = [[GANMessageManager sharedInstance].arrayThreads objectAtIndex:self.indexThread];
    GANMessageDataModel *message = [thread getLatestMessage];
    self.arrayReceivers = message.arrayReceivers;
    self.navigationItem.title = @"Message";
    [message requestGetBeautifiedReceiversAbbrWithCallback:^(NSString *beautifiedName) {
        self.navigationItem.title = beautifiedName;
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
    
    IQKeyboardManager.sharedManager.keyboardDistanceFromTextField = 48;
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
    
    [self refreshAutoTranslateView];
    [self refreshMapIcon];
}

- (void) refreshMapIcon{
    if (self.modelLocation == nil){
        self.imageAttachMap.image = [UIImage imageNamed:@"map-pin"];
        [self.buttonAttachMap setTitleColor:[UIColor GANThemeMainColor] forState:UIControlStateNormal];
    }
    else {
        self.imageAttachMap.image = [UIImage imageNamed:@"map_pin-green"];
        [self.buttonAttachMap setTitleColor:[UIColor GANThemeGreenColor] forState:UIControlStateNormal];
    }
}

- (void) refreshAutoTranslateView{
    if (self.isAutoTranslate == YES){
        [self.buttonTranslate setImage:[UIImage imageNamed:@"icon-checked"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonTranslate setImage:[UIImage imageNamed:@"icon-unchecked"] forState:UIControlStateNormal];
    }
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
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    GANMessageThreadDataModel *thread = [managerMessage.arrayThreads objectAtIndex:self.indexThread];
    if ([thread getUnreadMessageCount] > 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[GANMessageManager sharedInstance] requestMarkAsReadWithThreadIndex:self.indexThread Callback:nil];
        });
    }
}

- (void) buildMessageList{
    [GANGlobalVCManager updateMessageBadge];
    
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    GANMessageThreadDataModel *thread = [managerMessage.arrayThreads objectAtIndex:self.indexThread];
    [self.arrayMessages removeAllObjects];
    
    for (int i = 0; i < (int) [thread.arrayMessages count]; i++){
        GANMessageDataModel *message = [thread.arrayMessages objectAtIndex:i];
        if ([message amIReceiver] == NO && [message amISender] == NO) continue;
        if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) continue;
        
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

- (void) showMapDlg{
    dispatch_async(dispatch_get_main_queue(), ^{
        GANCompanyMapPopupVC *vc = [[GANCompanyMapPopupVC alloc] initWithNibName:@"GANCompanyMapPopupVC" bundle:nil];
        vc.delegate = self;
        vc.view.backgroundColor = [UIColor clearColor];
        [vc setTransitioningDelegate:self.transController];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void) sendMessage{
    if (self.textfieldInput.text.length == 0) {
        [GANGlobalVCManager shakeView:self.viewInputWrapper];
        return;
    }
    [self checkOnboardingWorker];
}

- (void) checkOnboardingWorker {
    NSInteger countOnboardingWorker = 0;
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    
    for (int i = 0; i < (int) [self.arrayReceivers count]; i++) {
        GANMessageReceiverDataModel *receiver = [self.arrayReceivers objectAtIndex:i];
        int indexMyWorker = [managerCompany getIndexForMyWorkersWithUserId:receiver.szUserId];
        if (indexMyWorker == -1) continue;
        GANMyWorkerDataModel *myWorker = [managerCompany.arrMyWorkers objectAtIndex:indexMyWorker];
        
        if(myWorker.modelWorker.enumType == GANENUM_USER_TYPE_ONBOARDING_WORKER) {
            countOnboardingWorker++;
        }
    }
    if(countOnboardingWorker == 0) {
        [self doSendMessage];
    } else {
        [self showOnboardingConfirmationDlg:countOnboardingWorker];
    }
}

- (void) doSendMessage{
    NSString *szMessage = self.textfieldInput.text;
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    NSMutableArray *arrReceivers = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [self.arrayReceivers count]; i++) {
        GANMessageReceiverDataModel *receiver = [self.arrayReceivers objectAtIndex:i];
        [arrReceivers addObject:@{@"user_id": receiver.szUserId,
                                  @"company_id": receiver.szCompanyId}];
    }
    
    NSDictionary *dictMetaData = nil;
    if(self.modelLocation) {
        dictMetaData = @{@"map" : [self.modelLocation serializeToMetaDataDictionary]};
    }
    
    [[GANMessageManager sharedInstance] requestSendMessageWithJobId:@"NONE" Type:GANENUM_MESSAGE_TYPE_MESSAGE Receivers:arrReceivers ReceiversPhoneNumbers: nil Message:szMessage MetaData:dictMetaData AutoTranslate:self.isAutoTranslate FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Message sent!" DismissAfter:-1 Callback:^{
                [self buildMessageList];
                self.modelLocation = nil;
                [self refreshMapIcon];

            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Company - Send message");
}

- (void) showOnboardingConfirmationDlg:(NSInteger) count{
    dispatch_async(dispatch_get_main_queue(), ^{
        GANMessageWithChargeConfirmationPopupVC *vc = [[GANMessageWithChargeConfirmationPopupVC alloc] initWithNibName:@"GANMessageWithChargeConfirmationPopupVC" bundle:nil];
        vc.delegate = self;
        [vc setTransitioningDelegate:self.transController];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:nil];
        [vc setDescriptionWithCount:count];
    });
}

#pragma mark - UITableView Delegate

- (void) configureCellMe: (GANMessageItemMeTVC *) cell AtIndex: (int) index{
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    
    cell.labelTimestamp.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE) {
        cell.labelMessage.text = [message getContentsEN];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_RECRUIT) {
        int indexJob = [managerJob getIndexForMyJobsByJobId:message.szJobId];
        if (indexJob != -1){
            GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:indexJob];
            cell.labelMessage.text = [NSString stringWithFormat:@"[Recruit]\r\r%@", [job getTitleEN]];
        }
        else {
            cell.labelMessage.text = @"[Recruit]\r\rJob not found";
        }
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE) {
        cell.labelMessage.text = [NSString stringWithFormat:@"[Multiple Choice Survey]\r\r%@", [message getContentsEN]];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT) {
        cell.labelMessage.text = [NSString stringWithFormat:@"[Open-Ended Survey]\r\r%@", [message getContentsEN]];
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

- (void) configureCellYou: (GANMessageItemYouTVC *) cell AtIndex: (int) index{
    GANMessageDataModel *message = [self.arrayMessages objectAtIndex:index];
    GANJobManager *managerJob = [GANJobManager sharedInstance];
    
    cell.labelTimestamp.text = [GANGenericFunctionManager getBeautifiedPastTime:message.dateSent];
    if (message.enumType == GANENUM_MESSAGE_TYPE_MESSAGE) {
        cell.labelMessage.text = [message getContentsEN];
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_APPLICATION) {
        int indexJob = [managerJob getIndexForMyJobsByJobId:message.szJobId];
        if (indexJob != -1){
            GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:indexJob];
            cell.labelMessage.text = [NSString stringWithFormat:@"[Worker interested]\r\r%@", [job getTitleEN]];
        }
        else {
            cell.labelMessage.text = @"[Worker interested]\r\rJob not found";
        }
    }
    else if (message.enumType == GANENUM_MESSAGE_TYPE_SUGGEST) {
        int indexJob = [managerJob getIndexForMyJobsByJobId:message.szJobId];
        if (indexJob != -1){
            GANJobDataModel *job = [managerJob.arrMyJobs objectAtIndex:indexJob];
            cell.labelMessage.text = [NSString stringWithFormat:@"[Worker suggested]\r\r%@ might be interested in %@", [message getPhoneNumberForSuggestFriend], [job getTitleEN]];
        }
        else {
            cell.labelMessage.text = @"[Worker suggested]\r\rJob not found";
        }
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

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonTranslateClick:(id)sender {
    [self.view endEditing:YES];
    self.isAutoTranslate = !self.isAutoTranslate;
    [self refreshAutoTranslateView];
}

- (IBAction)onButtonMapClick:(id)sender {
    [self.view endEditing:YES];
    [self showMapDlg];
}

- (IBAction)onButtonSendClick:(id)sender {
    [self.view endEditing:YES];
    [self sendMessage];
}

#pragma mark - GANCompanyMapPopupVCDelegate

- (void) submitLocation:(GANLocationDataModel *)location {
    self.modelLocation = location;
    [self refreshMapIcon];
}

#pragma mark - GANMessageWithChargeConfirmationPopupVC Delegate

- (void)messageWithChargeConfirmationPopupDidSendClick:(GANMessageWithChargeConfirmationPopupVC *)popup {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doSendMessage];
    });
}

- (void)messageWithChargeConfirmationPopupDidCancelClick:(GANMessageWithChargeConfirmationPopupVC *)popup {
    
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
