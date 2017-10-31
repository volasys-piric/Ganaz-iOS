//
//  GANCompanyMessageChooseWorkersVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyMessageChooseWorkersVC.h"
#import "GANWorkerItemTVC.h"
#import "GANCompanyAddWorkerVC.h"
#import "GANMyWorkerNickNameEditPopupVC.h"
#import "GANOnboardingWorkerNickNamePopupVC.h"
#import "GANCompanyMessageThreadVC.h"
#import "GANSurveyTypeChoosePopupVC.h"
#import "GANCompanySurveyChoicesPostVC.h"
#import "GANCompanySurveyOpenTextPostVC.h"

#import "GANCompanyManager.h"
#import "GANCacheManager.h"
#import "GANMyWorkerDataModel.h"
#import "GANFadeTransitionDelegate.h"
#import "GANMessageManager.h"

#import "GANGlobalVCManager.h"
#import "GANAppManager.h"
#import "UIColor+GANColor.h"

#define NON_SELECTED -1

@interface GANCompanyMessageChooseWorkersVC () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, GANMyWorkerNickNameEditPopupVCDelegate, GANOnboardingWorkerNickNamePopupVCDelegate, GANWorkerItemTVCDelegate, GANSurveyTypeChoosePopupDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewSearch;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITextField *textfieldSearch;

@property (weak, nonatomic) IBOutlet UIButton *buttonSendMessage;
@property (weak, nonatomic) IBOutlet UIButton *buttonSendSurvey;

@property (weak, nonatomic) IBOutlet UIButton *buttonAddWorker;
@property (weak, nonatomic) IBOutlet UIButton *buttonSelectAll;

@property (strong, nonatomic) NSMutableArray *arrayWorkersSelected;
@property (strong, nonatomic) NSMutableArray *arrayMyWorkers;

@property (assign, atomic) BOOL isPopupShowing;
@property (assign, atomic) BOOL isAutoTranslate;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;
@property (strong, nonatomic) GANLocationDataModel *mapData;
@property (assign, atomic) int indexSelected;

@end

@implementation GANCompanyMessageChooseWorkersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.isPopupShowing = NO;
    self.isAutoTranslate = NO;
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    
    self.indexSelected = NON_SELECTED;
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self buildFilteredArray];
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
    [self.tableview registerNib:[UINib nibWithNibName:@"WorkerItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKERITEM"];
}

- (void) refreshViews{
    self.buttonSendMessage.layer.cornerRadius = 3;
    self.buttonSendSurvey.layer.cornerRadius = 3;
    self.buttonAddWorker.layer.cornerRadius = 3;
    self.buttonSelectAll.layer.cornerRadius = 3;
    
    self.buttonSendMessage.clipsToBounds = YES;
    self.buttonSendSurvey.clipsToBounds = YES;
    self.buttonAddWorker.clipsToBounds = YES;
    self.buttonSelectAll.clipsToBounds = YES;
    
    self.buttonSendSurvey.layer.borderColor = [UIColor GANThemeMainColor].CGColor;
    self.buttonSendSurvey.layer.borderWidth = 1;
    [self.buttonSendSurvey setTitleColor:[UIColor GANThemeMainColor] forState:UIControlStateNormal];
    
    self.viewSearch.layer.borderColor = [UIColor GANThemeGreenColor].CGColor;
    self.viewSearch.layer.borderWidth = 1;
    self.viewSearch.layer.cornerRadius = 10;
    self.viewSearch.clipsToBounds = YES;
    
    self.buttonAddWorker.backgroundColor = [UIColor GANThemeGreenColor];
}

- (void) gotoAddWorkerVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANCompanyAddWorkerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_ADDWORKER"];
    vc.fromCustomVC = ENUM_COMPANY_ADDWORKERS_FROM_MESSAGE;
    vc.szDescription = @"Who do you want to message?";
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to add-worker from Message");
}

- (void) buildFilteredArray{
    self.arrayMyWorkers = [[NSMutableArray alloc] init];

    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    NSString *keyword = [self.textfieldSearch.text lowercaseString];
    keyword = [keyword stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    if (keyword.length == 0){
        [self.arrayMyWorkers addObjectsFromArray:managerCompany.arrMyWorkers];
        [self buildWorkerList];
        return;
    }
    
    for (int i = 0; i < (int) [managerCompany.arrMyWorkers count]; i++) {
        GANMyWorkerDataModel *myWorker = [managerCompany.arrMyWorkers objectAtIndex:i];
        NSString *sz = [NSString stringWithFormat:@"%@ %@ %@", [myWorker getDisplayName], myWorker.modelWorker.modelPhone.szLocalNumber, [myWorker.modelWorker.modelPhone getBeautifiedPhoneNumber]];
        sz = [sz lowercaseString];
        if ([sz rangeOfString:keyword].location != NSNotFound){
            [self.arrayMyWorkers addObject:myWorker];
        }
    }
    [self buildWorkerList];
}

- (void) buildWorkerList{
    self.arrayWorkersSelected = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int)[self.arrayMyWorkers count]; i++){
        [self.arrayWorkersSelected addObject:@(NO)];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
        [self refreshSelectAllButton];
    });
}

- (void) refreshSelectAllButton{
    if ([self.arrayWorkersSelected count] == 0) {
        self.buttonSelectAll.hidden = YES;
        return;
    }
    
    self.buttonSelectAll.hidden = NO;
    int count = [self getSelectedCount];
    if (count == (int) [self.arrayWorkersSelected count]) {
        // All selected
        [self.buttonSelectAll setTitle:@"Deselect\rworkers" forState:UIControlStateNormal];
        self.buttonSelectAll.backgroundColor = [UIColor GANThemeMainColor];
    }
    else {
        [self.buttonSelectAll setTitle:@"Select all\rworkers" forState:UIControlStateNormal];
        self.buttonSelectAll.backgroundColor = [UIColor GANThemeGreenColor];
    }
}

- (int) getSelectedCount{
    int count = 0;
    for (int i = 0; i < (int) [self.arrayWorkersSelected count]; i++) {
        if ([[self.arrayWorkersSelected objectAtIndex:i] boolValue] == YES) count++;
    }
    return count;
}

- (void) doSelectAll{
    int count = [self getSelectedCount];
    if (count == (int) [self.arrayWorkersSelected count]) {
        // Deselect
        for (int i = 0; i < (int) [self.arrayWorkersSelected count]; i++){
            [self.arrayWorkersSelected replaceObjectAtIndex:i withObject:@(NO)];
        }
    }
    else {
        // Select all
        for (int i = 0; i < (int) [self.arrayWorkersSelected count]; i++){
            [self.arrayWorkersSelected replaceObjectAtIndex:i withObject:@(YES)];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
        [self refreshSelectAllButton];
    });
}

#pragma mark - Logic

- (NSMutableArray <GANUserRefDataModel *> *) buildMutableReceiversArrayForSelectedWorkers {
    NSMutableArray <GANUserRefDataModel *> *arrayReceivers = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (int) [self.arrayWorkersSelected count]; i++){
        if ([[self.arrayWorkersSelected objectAtIndex:i] boolValue] == YES){
            GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:i];
            GANUserRefDataModel *userRef = [[GANUserRefDataModel alloc] init];
            userRef.szCompanyId = @"";
            userRef.szUserId = myWorker.szWorkerUserId;
            [arrayReceivers addObject:userRef];
        }
    }
    
    return arrayReceivers;
}

- (void) gotoMessageThreadVC{
    NSMutableArray <GANUserRefDataModel *> *arrayReceivers = [self buildMutableReceiversArrayForSelectedWorkers];
    
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    int indexThread = [managerMessage getIndexForMessageThreadWithReceivers:arrayReceivers];
    if (indexThread == -1 && [arrayReceivers count] == 1) {
        indexThread = [managerMessage getIndexForMessageThreadWithSender:[arrayReceivers firstObject]];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
    GANCompanyMessageThreadVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGE_THREAD"];
    
    if (indexThread != -1) {
        vc.indexThread = indexThread;
    }
    else {
        vc.indexThread = -1;
        vc.arrayReceivers = arrayReceivers;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
    
    GANACTIVITY_REPORT(@"Company - Go to MessageComposer from Messages");
}

- (void) showSurveyTypeChooseDlg {
    dispatch_async(dispatch_get_main_queue(), ^{
        GANSurveyTypeChoosePopupVC *vc = [[GANSurveyTypeChoosePopupVC alloc] initWithNibName:@"GANSurveyTypeChoosePopupVC" bundle:nil];
        vc.delegate = self;
        [vc setTransitioningDelegate:self.transController];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void) gotoSurveyChoicesPostVC{
    NSMutableArray <GANUserRefDataModel *> *arrayReceivers = [self buildMutableReceiversArrayForSelectedWorkers];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
    GANCompanySurveyChoicesPostVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SURVEY_CHOICESPOST"];
    vc.arrayReceivers = arrayReceivers;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to Survey from Message");
}

- (void) gotoSurveyOpenTextPostVC{
    NSMutableArray <GANUserRefDataModel *> *arrayReceivers = [self buildMutableReceiversArrayForSelectedWorkers];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
    GANCompanySurveyOpenTextPostVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SURVEY_OPENTEXTPOST"];
    vc.arrayReceivers = arrayReceivers;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to Survey from Message");
}

#pragma mark - Biz Logic

- (BOOL) isWorkerSelected{
    for (int i = 0; i < (int) [self.arrayWorkersSelected count]; i++){
        if ([[self.arrayWorkersSelected objectAtIndex:i] boolValue] == YES) return YES;
    }
    return NO;
}

#pragma mark - UITableViewDelegate

- (void) configureCell: (GANWorkerItemTVC *) cell AtIndex: (int) index{
    GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:index];
    cell.lblWorkerId.text = [myWorker getDisplayName];
    cell.delegate = self;
    cell.nIndex = index;
    
    if(myWorker.modelWorker.enumType == GANENUM_USER_TYPE_WORKER) {
        [cell setButtonColor:YES];
    } else {
        [cell setButtonColor:NO];
    }
    
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL isSelected = [[self.arrayWorkersSelected objectAtIndex:index] boolValue];
    [cell setItemSelected:isSelected];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayMyWorkers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkerItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKERITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    BOOL isSelected = [[self.arrayWorkersSelected objectAtIndex:index] boolValue];
    [self.arrayWorkersSelected replaceObjectAtIndex:index withObject:@(!isSelected)];
    [self.tableview reloadData];
}

- (void) changeMyWorkerNickName: (NSInteger) index{
    GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:index];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(myWorker.modelWorker.enumType == GANENUM_USER_TYPE_ONBOARDING_WORKER){
            GANOnboardingWorkerNickNamePopupVC *vc = [[GANOnboardingWorkerNickNamePopupVC alloc] initWithNibName:@"GANOnboardingWorkerNickNamePopupVC" bundle:nil];
            vc.delegate = self;
            
            vc.view.backgroundColor = [UIColor clearColor];
            [vc setTransitioningDelegate:self.transController];
            vc.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:vc animated:YES completion:^{
                
            }];
            
            [vc setTitle:[myWorker.modelWorker.modelPhone getBeautifiedPhoneNumber]];
            if(![myWorker.szNickname isEqualToString:@""] || myWorker.szNickname != nil)
                vc.textfieldNickname.text = myWorker.szNickname;
        }
        else {
            GANMyWorkerNickNameEditPopupVC *vc = [[GANMyWorkerNickNameEditPopupVC alloc] initWithNibName:@"GANMyWorkerNickNameEditPopupVC" bundle:nil];
            vc.delegate = self;
            
            vc.view.backgroundColor = [UIColor clearColor];
            [vc setTransitioningDelegate:self.transController];
            vc.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:vc animated:YES completion:^{
                
            }];
            
            [vc setTitle:[myWorker.modelWorker.modelPhone getBeautifiedPhoneNumber]];
            if(![myWorker.szNickname isEqualToString:@""] || myWorker.szNickname != nil)
                vc.textfieldNickname.text = myWorker.szNickname;
        }        
        
    });
}

#pragma mark - GANWorkerITEMTVCDelegate

- (void) setWorkerNickName:(NSInteger)nIndex {
    self.indexSelected = (int) nIndex;
    
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:nIndex];
    if(myWorker.modelWorker.enumType == GANENUM_USER_TYPE_WORKER) {
        [self changeMyWorkerNickName:self.indexSelected];
        return;
    }
    
    NSString *szUserName = [myWorker getDisplayName];
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:szUserName delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Re-send Invitation",@"Edit", nil];
    popup.tag = 0;
    [popup showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 0: {
            switch (buttonIndex) {
                case 0:
                    [self resendInvite:self.indexSelected];
                    break;
                case 1:
                    [self changeMyWorkerNickName:self.indexSelected];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void) resendInvite:(NSInteger) nIndex {
    NSString *szCompanyId = [GANUserManager getCompanyDataModel].szId;
    GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:self.indexSelected];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANCompanyManager sharedInstance] requestSendInvite:myWorker.modelWorker.modelPhone CompanyId:szCompanyId inviteOnly:YES Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"An invitation will be sent shortly via SMS" DismissAfter:-1 Callback:nil];
            [self getMyWorkerList];
            GANACTIVITY_REPORT(@"Company - Send invitation");
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
        self.indexSelected = NON_SELECTED;
    }];
    GANACTIVITY_REPORT(@"Company - Send invite");
}

- (void) getMyWorkerList {
    [[GANCompanyManager sharedInstance] requestGetMyWorkersListWithCallback:^(int status) {
        if(status == SUCCESS_WITH_NO_ERROR) {
            [self buildFilteredArray];
        } else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
}

#pragma mark - GANMyWorkerNickNameEditPopupVCDelegate

- (void) nicknameEditPopupDidUpdateWithNickname:(NSString *)nickname {
    GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:self.indexSelected];
    myWorker.szNickname = nickname;
    
    //Add NickName
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerCompany requestUpdateMyWorkerNicknameWithMyWorkerId:myWorker.szId Nickname:nickname Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker's alias has been updated" DismissAfter:-1 Callback:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableview reloadData];
            });
            GANACTIVITY_REPORT(@"Company - Change worker nickname");
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
        self.indexSelected = NON_SELECTED;
    }];
}

- (void) onboardingNicknameEditPopupDidUpdateWithNickname:(NSString *)nickname {
    GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:self.indexSelected];
    myWorker.szNickname = nickname;
    
    //Add NickName
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerCompany requestUpdateMyWorkerNicknameWithMyWorkerId:myWorker.szId Nickname:nickname Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker's alias has been updated" DismissAfter:-1 Callback:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableview reloadData];
            });
            GANACTIVITY_REPORT(@"Company - Change worker nickname");
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
        self.indexSelected = NON_SELECTED;
    }];
}

#pragma mark - UIButton Delegate

- (IBAction)onButtonSendMessageClick:(id)sender {
    [self.view endEditing:YES];
    if ([self isWorkerSelected] == NO){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select the worker(s) you want to message" DismissAfter:-1 Callback:nil];
        return;
    }
    [self gotoMessageThreadVC];
}

- (IBAction)onButtonSendSurveyClick:(id)sender {
    [self.view endEditing:YES];
    if ([self isWorkerSelected] == NO){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select the worker(s) you want to message" DismissAfter:-1 Callback:nil];
        return;
    }
    [self showSurveyTypeChooseDlg];
}

- (IBAction)onButtonAddWorkerClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoAddWorkerVC];
}

- (IBAction)onButtonSelectAllClick:(id)sender {
    [self.view endEditing:YES];
    [self doSelectAll];
}

#pragma mark - UITextField Delegate

- (IBAction)onTextfieldSearchChanged:(id)sender {
    [self buildFilteredArray];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED]) ||
             ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED])){
        [self buildFilteredArray];
    }
}

#pragma mark - GANSurveyTypeChoosePopupVC Delegate

- (void)surveyTypeChoosePopupDidChoiceSingleClick:(GANSurveyTypeChoosePopupVC *)popup {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self gotoSurveyChoicesPostVC];
    });
}

- (void)surveyTypeChoosePopupDidOpenTextClick:(GANSurveyTypeChoosePopupVC *)popup {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self gotoSurveyOpenTextPostVC];
    });
}

- (void)surveyTypeChoosePopupDidCancelClick:(GANSurveyTypeChoosePopupVC *)popup {
    
}

@end
