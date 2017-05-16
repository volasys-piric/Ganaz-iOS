//
//  GANCompanyMessageChooseWorkersVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyMessageChooseWorkersVC.h"
#import "GANWorkerItemTVC.h"

#import "GANMyWorkersManager.h"
#import "GANMyWorkerDataModel.h"

#import "GANMessageManager.h"

#import "Global.h"
#import "GANGlobalVCManager.h"

@interface GANCompanyMessageChooseWorkersVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UIView *viewPopupWrapper;
@property (weak, nonatomic) IBOutlet UIView *viewPopupPanel;
@property (weak, nonatomic) IBOutlet UIView *viewMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnAutoTranslate;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPopupPanelBottomSpace;

@property (strong, nonatomic) NSMutableArray *arrWorkerSelected;
@property (assign, atomic) BOOL isPopupShowing;
@property (assign, atomic) BOOL isAutoTranslate;

@end

@implementation GANCompanyMessageChooseWorkersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.isPopupShowing = NO;
    self.isAutoTranslate = NO;
    
    [self buildWorkerList];
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
    [self.tableview registerNib:[UINib nibWithNibName:@"WorkerItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_WORKERITEM"];
}

- (void) refreshViews{
    self.btnContinue.layer.cornerRadius = 3;
    self.btnSubmit.layer.cornerRadius = 3;
    self.viewMessage.layer.cornerRadius = 3;
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
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_ADDWORKER"];
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) buildWorkerList{
    self.arrWorkerSelected = [[NSMutableArray alloc] init];
    GANMyWorkersManager *managerWorker = [GANMyWorkersManager sharedInstance];
    
    for (int i = 0; i < (int)[managerWorker.arrMyWorkers count]; i++){
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

- (void) doSendMessage{
    NSString *szMessage = self.textview.text;
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    NSMutableArray *arrReceiverUserIds = [[NSMutableArray alloc] init];
    GANMyWorkersManager *managerWorker = [GANMyWorkersManager sharedInstance];
    
    for (int i = 0; i < (int) [self.arrWorkerSelected count]; i++){
        if ([[self.arrWorkerSelected objectAtIndex:i] boolValue] == YES){
            GANMyWorkerDataModel *myWorker = [managerWorker.arrMyWorkers objectAtIndex:i];
            [arrReceiverUserIds addObject:myWorker.szWorkerUserId];
        }
    }

    [[GANMessageManager sharedInstance] requestSendMessageWithJobId:@"NONE" Type:GANENUM_MESSAGE_TYPE_MESSAGE Receivers:arrReceiverUserIds Message:szMessage AutoTranslate:self.isAutoTranslate Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Message is sent!" DismissAfter:-1 Callback:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
    }];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANWorkerItemTVC *) cell AtIndex: (int) index{
    GANMyWorkerDataModel *myWorker = [[GANMyWorkersManager sharedInstance].arrMyWorkers objectAtIndex:index];
    cell.lblWorkerId.text = myWorker.szUserName;
    cell.viewContainer.layer.cornerRadius = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL isSelected = [[self.arrWorkerSelected objectAtIndex:index] boolValue];
    [cell setItemSelected:isSelected];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[GANMyWorkersManager sharedInstance].arrMyWorkers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANWorkerItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKERITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int) indexPath.row;
    BOOL isSelected = [[self.arrWorkerSelected objectAtIndex:index] boolValue];
    [self.arrWorkerSelected replaceObjectAtIndex:index withObject:@(!isSelected)];
    [self.tableview reloadData];
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnContinueClick:(id)sender {
    [self.view endEditing:YES];
    if ([self isWorkerSelected] == NO){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select workers to send message." DismissAfter:-1 Callback:nil];
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
        [GANGlobalVCManager showHudErrorWithMessage:@"Please input message to send." DismissAfter:-1 Callback:nil];
        return;
    }
    
    [self animateToHidePopup];
    [self doSendMessage];
}

- (IBAction)onBtnPopupWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self animateToHidePopup];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED]) ||
             ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED])){
        [self buildWorkerList];
    }
}

@end
