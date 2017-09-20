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
#import "GANCompanyMapPopupVC.h"
#import "GANConformMessagePopupVC.h"

#import "GANCompanyManager.h"
#import "GANCacheManager.h"
#import "GANMyWorkerDataModel.h"
#import "GANFadeTransitionDelegate.h"
#import "GANMessageManager.h"

#import "GANGlobalVCManager.h"
#import "GANAppManager.h"

#define NON_SELECTED -1

@interface GANCompanyMessageChooseWorkersVC () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, GANMyWorkerNickNameEditPopupVCDelegate, GANOnboardingWorkerNickNamePopupVCDelegate, GANWorkerItemTVCDelegate, GANCompanyMapPopupVCDelegate, GANConformMessagePopupVCDelegate>
{
    NSInteger nSelectedIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UIView *viewPopupWrapper;
@property (weak, nonatomic) IBOutlet UIView *viewPopupPanel;
@property (weak, nonatomic) IBOutlet UIView *viewMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnAutoTranslate;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UIButton *btnAddWorker;
@property (strong, nonatomic) IBOutlet UIButton *btnMap;
@property (strong, nonatomic) IBOutlet UIImageView *imgMapIcon;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPopupPanelBottomSpace;

@property (strong, nonatomic) NSMutableArray *arrWorkerSelected;
@property (assign, atomic) BOOL isPopupShowing;
@property (assign, atomic) BOOL isAutoTranslate;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;
@property (strong, nonatomic) GANLocationDataModel *mapData;

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
    
    nSelectedIndex = NON_SELECTED;
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self buildWorkerList];
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
    self.btnContinue.layer.cornerRadius = 3;
    self.btnSubmit.layer.cornerRadius = 3;
    self.viewMessage.layer.cornerRadius = 3;
    self.btnAddWorker.layer.cornerRadius = 3;
    [self refreshAutoTranslateView];
}

- (void) refreshPopupView{
    self.viewPopupWrapper.hidden = !self.isPopupShowing;
}

- (void) refreshAutoTranslateView{
    if (self.isAutoTranslate == YES){
        [self.btnAutoTranslate setImage:[UIImage imageNamed:@"icon-checked"] forState:UIControlStateNormal];
    }
    else {
        [self.btnAutoTranslate setImage:[UIImage imageNamed:@"icon-unchecked"] forState:UIControlStateNormal];
    }
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

- (void) buildWorkerList{
    self.arrWorkerSelected = [[NSMutableArray alloc] init];
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    
    for (int i = 0; i < (int)[managerCompany.arrMyWorkers count]; i++){
        [self.arrWorkerSelected addObject:@(NO)];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
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
    
    self.isPopupShowing = NO;
    int height = (int) self.viewPopupPanel.frame.size.height;
    
    self.constraintPopupPanelBottomSpace.constant = 0;
    self.viewPopupWrapper.alpha = 1;
    [self.viewPopupWrapper layoutIfNeeded];
    
    self.textview.text = @"";
    
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

- (BOOL) isWorkerSelected{
    for (int i = 0; i < (int) [self.arrWorkerSelected count]; i++){
        if ([[self.arrWorkerSelected objectAtIndex:i] boolValue] == YES) return YES;
    }
    return NO;
}

- (void) checkOnboardingWorker {
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    
    NSInteger nOnboardingWorkerCount = 0;
    for (int i = 0; i < (int) [self.arrWorkerSelected count]; i++){
        if ([[self.arrWorkerSelected objectAtIndex:i] boolValue] == YES){
            GANMyWorkerDataModel *myWorker = [managerCompany.arrMyWorkers objectAtIndex:i];
            if(myWorker.modelWorker.enumType == GANENUM_USER_TYPE_ONBOARDING_WORKER) {
                nOnboardingWorkerCount++;
            }
        }
    }
    
    if(nOnboardingWorkerCount == 0) {
        [self doSendMessage];
    } else {
        [self showSendMessagePopup:nOnboardingWorkerCount];
    }
}

- (void) doSendMessage{
    NSString *szMessage = self.textview.text;
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    NSMutableArray *arrReceivers = [[NSMutableArray alloc] init];
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    
    for (int i = 0; i < (int) [self.arrWorkerSelected count]; i++){
        if ([[self.arrWorkerSelected objectAtIndex:i] boolValue] == YES){
            GANMyWorkerDataModel *myWorker = [managerCompany.arrMyWorkers objectAtIndex:i];
            [arrReceivers addObject:@{@"user_id": myWorker.szWorkerUserId,
                                      @"company_id": @""}];
        }
    }
    
    NSDictionary *metaData;
    if(self.mapData) {
        metaData = @{@"map" : [self.mapData serializeToMetaDataDictionary]};
    }
    
    [[GANMessageManager sharedInstance] requestSendMessageWithJobId:@"NONE" Type:GANENUM_MESSAGE_TYPE_MESSAGE Receivers:arrReceivers ReceiversPhoneNumbers: nil Message:szMessage MetaData:metaData AutoTranslate:self.isAutoTranslate FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Message sent!" DismissAfter:-1 Callback:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
    GANACTIVITY_REPORT(@"Company - Send message");
}

- (void) showSendMessagePopup:(NSInteger) nCount {
    dispatch_async(dispatch_get_main_queue(), ^{
        GANConformMessagePopupVC *vc = [[GANConformMessagePopupVC alloc] initWithNibName:@"GANConformMessagePopupVC" bundle:nil];
        vc.delegate = self;
        [vc setTransitioningDelegate:self.transController];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        [vc setDescription:nCount];
    });
}

#pragma mark - GANConformMessagePopupVCDelegate
- (void) sendMessagetoWorkers {
    [self doSendMessage];
}

#pragma mark - UITableViewDelegate

- (void) configureCell: (GANWorkerItemTVC *) cell AtIndex: (int) index{
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:index];
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
    
    BOOL isSelected = [[self.arrWorkerSelected objectAtIndex:index] boolValue];
    [cell setItemSelected:isSelected];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[GANCompanyManager sharedInstance].arrMyWorkers count];
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
    BOOL isSelected = [[self.arrWorkerSelected objectAtIndex:index] boolValue];
    [self.arrWorkerSelected replaceObjectAtIndex:index withObject:@(!isSelected)];
    [self.tableview reloadData];
}

- (void) changeMyWorkerNickName: (NSInteger) index{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:index];
        
        
        if(myWorker.modelWorker.enumType == GANENUM_USER_TYPE_ONBOARDING_WORKER){
            GANOnboardingWorkerNickNamePopupVC *vc = [[GANOnboardingWorkerNickNamePopupVC alloc] initWithNibName:@"GANOnboardingWorkerNickNamePopupVC" bundle:nil];
            vc.delegate = self;
            
            vc.view.backgroundColor = [UIColor clearColor];
            [vc setTransitioningDelegate:self.transController];
            vc.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:vc animated:YES completion:^{
                
            }];
            
            vc.nIndex = index;
            [vc setTitle:[myWorker.modelWorker.modelPhone getBeautifiedPhoneNumber]];
            if(![myWorker.szNickname isEqualToString:@""] || myWorker.szNickname != nil)
                vc.txtNickName.text = myWorker.szNickname;
        } else {
            GANMyWorkerNickNameEditPopupVC *vc = [[GANMyWorkerNickNameEditPopupVC alloc] initWithNibName:@"GANMyWorkerNickNameEditPopupVC" bundle:nil];
            vc.delegate = self;
            
            vc.view.backgroundColor = [UIColor clearColor];
            [vc setTransitioningDelegate:self.transController];
            vc.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:vc animated:YES completion:^{
                
            }];
            
            vc.nIndex = index;
            [vc setTitle:[myWorker.modelWorker.modelPhone getBeautifiedPhoneNumber]];
            if(![myWorker.szNickname isEqualToString:@""] || myWorker.szNickname != nil)
                vc.txtNickName.text = myWorker.szNickname;
        }        
        
    });
}

#pragma mark - GANWorkerITEMTVCDelegate
- (void) setWorkerNickName:(NSInteger)nIndex {
    nSelectedIndex = nIndex;
    
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:nIndex];
    if(myWorker.modelWorker.enumType == GANENUM_USER_TYPE_WORKER) {
        [self changeMyWorkerNickName:nSelectedIndex];
        return;
    }
    
    NSString *szUserName = [myWorker getDisplayName];
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:szUserName delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Re-send Invitation",@"Edit", nil];
    popup.tag = 0;
    [popup showInView:self.view];
}

- (void) setOnboardingWorkerNickName:(NSString*)szNickName index:(NSInteger) nIndex {
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:nIndex];
    myWorker.szNickname = szNickName;
    
    //Add NickName
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerCompany requestUpdateMyWorkerNicknameWithMyWorkerId:myWorker.szId Nickname:szNickName Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker's alias has been updated" DismissAfter:-1 Callback:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableview reloadData];
            });
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
        nSelectedIndex = NON_SELECTED;
    }];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 0: {
            switch (buttonIndex) {
                case 0:
                    [self resendInvite:nSelectedIndex];
                    break;
                case 1:
                    [self changeMyWorkerNickName:nSelectedIndex];
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
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:nIndex];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANCompanyManager sharedInstance] requestSendInvite:myWorker.modelWorker.modelPhone CompanyId:szCompanyId inviteOnly:YES Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"An invitation will be sent shortly via SMS" DismissAfter:-1 Callback:nil];
            [self getMyWorkerList];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
        nSelectedIndex = NON_SELECTED;
    }];
    GANACTIVITY_REPORT(@"Company - Send invite");
}

- (void) getMyWorkerList {
    [[GANCompanyManager sharedInstance] requestGetMyWorkersListWithCallback:^(int status) {
        if(status == SUCCESS_WITH_NO_ERROR) {
            [self buildWorkerList];
        } else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
}

#pragma mark - GANMyWorkerNickNameEditPopupVCDelegate
- (void) setMyWorkerNickName:(NSString*)szNickName index:(NSInteger) nIndex {
    GANMyWorkerDataModel *myWorker = [[GANCompanyManager sharedInstance].arrMyWorkers objectAtIndex:nIndex];
    myWorker.szNickname = szNickName;
    
    //Add NickName
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerCompany requestUpdateMyWorkerNicknameWithMyWorkerId:myWorker.szId Nickname:szNickName Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker's alias has been updated" DismissAfter:-1 Callback:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableview reloadData];
            });
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue." DismissAfter:-1 Callback:nil];
        }
        nSelectedIndex = NON_SELECTED;
    }];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnContinueClick:(id)sender {
    [self.view endEditing:YES];
    if ([self isWorkerSelected] == NO){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select the worker(s) you want to message" DismissAfter:-1 Callback:nil];
        return;
    }
    [self animateToShowPopup];
}

- (IBAction)onBtnAddWorkerClick:(id)sender {
    [self.view endEditing:YES];
    [self gotoAddWorkerVC];
}

- (IBAction)onBtnTranslateClick:(id)sender {
    [self.view endEditing:YES];
    self.isAutoTranslate = !self.isAutoTranslate;
    [self refreshAutoTranslateView];
}

- (IBAction)onBtnSubmitClick:(id)sender {
    [self.view endEditing:YES];
    NSString *sz = self.textview.text;
    if (sz.length == 0){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please enter a message to send" DismissAfter:-1 Callback:nil];
        return;
    }
    
    [self animateToHidePopup];
    [self checkOnboardingWorker];
}

- (IBAction)onBtnPopupWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self animateToHidePopup];
}

- (IBAction)onBtnMap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        GANCompanyMapPopupVC *vc = [[GANCompanyMapPopupVC alloc] initWithNibName:@"GANCompanyMapPopupVC" bundle:nil];
        vc.delegate = self;
        vc.view.backgroundColor = [UIColor clearColor];
        [vc setTransitioningDelegate:self.transController];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:nil];
    });
}

#pragma mark - GANCompanyMapPopupVCDelegate
- (void) submitLocation:(GANLocationDataModel *)location {
    self.mapData = location;
    self.imgMapIcon.image = [UIImage imageNamed:@"map_pin-green"];
    [self.btnMap.titleLabel setTextColor:GANUICOLOR_THEMECOLOR_GREEN];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED]) ||
             ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED])){
        [self buildWorkerList];
    }
}

@end
