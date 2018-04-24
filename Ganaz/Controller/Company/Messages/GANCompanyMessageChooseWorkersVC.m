//
//  GANCompanyMessageChooseWorkersVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyMessageChooseWorkersVC.h"
#import "GANWorkerItemTVC.h"
#import "GANCompanyCrewItemTVC.h"
#import "GANCompanyChooseWorkerHeaderTVC.h"
#import "GANCompanyChooseWorkerGroupHeaderTVC.h"
#import "GANCompanyAddWorkerVC.h"
#import "GANMyWorkerNickNameEditPopupVC.h"
#import "GANOnboardingWorkerNickNamePopupVC.h"
#import "GANCompanyMessageThreadVC.h"
#import "GANSurveyTypeChoosePopupVC.h"
#import "GANCompanySurveyChoicesPostVC.h"
#import "GANCompanySurveyOpenTextPostVC.h"
#import "GANCompanyCrewDetailsVC.h"
#import "GANCompanyCrewPopupVC.h"

#import "GANCompanyManager.h"
#import "GANCacheManager.h"
#import "GANMyWorkerDataModel.h"
#import "GANFadeTransitionDelegate.h"
#import "GANMessageManager.h"

#import "GANGlobalVCManager.h"
#import "GANAppManager.h"
#import "UIColor+GANColor.h"
#import "Global.h"

#define NON_SELECTED -1
#define CONSTANT_TABLEVIEWCELLHEIGHT                63

@interface GANCompanyMessageChooseWorkersVC () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, GANMyWorkerNickNameEditPopupVCDelegate, GANOnboardingWorkerNickNamePopupVCDelegate, GANWorkerItemTVCDelegate, GANSurveyTypeChoosePopupDelegate, GANCompanyCrewPopupDelegate, GANCompanyCrewItemTVCDelegate, GANCompanyChooseWorkerGroupHeaderTVCDelegate, GANCompanyChooseWorkerHeaderTVCDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UIButton *buttonSendMessage;
@property (weak, nonatomic) IBOutlet UIButton *buttonSendSurvey;

@property (strong, nonatomic) NSMutableArray *arrayCrewsSelected;
@property (strong, nonatomic) NSMutableArray *arrayWorkersSelected;
@property (strong, nonatomic) NSMutableArray *arrayMyWorkers;

@property (assign, atomic) BOOL isPopupShowing;
@property (assign, atomic) BOOL isAutoTranslate;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;
@property (strong, nonatomic) GANLocationDataModel *mapData;
@property (assign, atomic) int indexSelected;
@property (assign, atomic) BOOL isFirstLoad;
@property (strong, nonatomic) NSString *szSearchKeyword;

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
    self.isFirstLoad = YES;
    self.szSearchKeyword = @"";
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    
    self.indexSelected = NON_SELECTED;
    
    NSLog(@"Checkpoint - 1.1: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
    [self registerTableViewCellFromNib];
    [self refreshViews];
    
    NSLog(@"Checkpoint - 1.2: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLocalNotificationReceived:)
                                                 name:nil
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"Checkpoint - 2.1: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
    [self buildFilteredArray];
    [self refreshCrewList];

    if (self.isFirstLoad == NO) {
        [self refreshAllList];
    }
    self.isFirstLoad = NO;
    NSLog(@"Checkpoint - 2.2: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
}

- (void) refreshAllList {
    NSLog(@"Checkpoint - 3.1: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    [managerCompany requestGetMyWorkersListWithCallback:^(int status) {
        [managerCompany requestGetCrewsListWithCallback:^(int status) {
            [self buildFilteredArray];
            [self refreshCrewList];
            NSLog(@"Checkpoint - 3.2: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
        }];
    }];
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
    [self.tableview registerNib:[UINib nibWithNibName:@"CompanyCrewItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_COMPANYCREWITEM"];
    [self.tableview registerNib:[UINib nibWithNibName:@"CompanyChooseWorkerHeaderTVC" bundle:nil] forCellReuseIdentifier:@"TVC_COMPANYCHOOSEWORKER_HEADER"];
    [self.tableview registerNib:[UINib nibWithNibName:@"CompanyChooseWorkerGroupHeaderTVC" bundle:nil] forCellReuseIdentifier:@"TVC_COMPANYCHOOSEWORKER_GROUPHEADER"];
}

- (void) refreshViews{
    self.buttonSendMessage.layer.cornerRadius = 3;
    self.buttonSendSurvey.layer.cornerRadius = 3;
    
    self.buttonSendMessage.clipsToBounds = YES;
    self.buttonSendSurvey.clipsToBounds = YES;
    
    self.buttonSendSurvey.layer.borderColor = [UIColor GANThemeMainColor].CGColor;
    self.buttonSendSurvey.layer.borderWidth = 1;
    [self.buttonSendSurvey setTitleColor:[UIColor GANThemeMainColor] forState:UIControlStateNormal];    
}

- (void) gotoAddWorkerVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    GANCompanyAddWorkerVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_ADDWORKER"];
    vc.fromCustomVC = ENUM_COMPANY_ADDWORKERS_FROM_MESSAGE;
    vc.szDescription = @"Who do you want to message?";
    vc.szCrewId = @"";
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to add-worker from Message");
}

- (void) buildFilteredArray{
    NSLog(@"Checkpoint - 4.1: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
    self.arrayMyWorkers = [[NSMutableArray alloc] init];

    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    NSString *keyword = [self.szSearchKeyword lowercaseString];
    keyword = [keyword stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    if (managerCompany.isMyWorkersLoading == YES) {
        [self buildWorkerList];
        return;
    }
    
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
    NSLog(@"Checkpoint - 4.2: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
    [self buildWorkerList];
}

- (void) buildWorkerList{
    NSLog(@"Checkpoint - 5.1: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
    self.arrayWorkersSelected = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int)[self.arrayMyWorkers count]; i++){
        [self.arrayWorkersSelected addObject:@(NO)];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableview reloadData];
        [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 1)] withRowAnimation:UITableViewRowAnimationNone];
        [self refreshWorkersSelectAllButton];
    });
    NSLog(@"Checkpoint - 5.2: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
}

- (void) refreshCrewList{
    NSLog(@"Checkpoint - 6.1: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
    int count = (int) [[GANCompanyManager sharedInstance].arrayCrews count];
    self.arrayCrewsSelected = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        [self.arrayCrewsSelected addObject:@(NO)];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
    NSLog(@"Checkpoint - 6.2: Timestamp = %f", [[NSDate date] timeIntervalSince1970]);
}

- (void) refreshWorkersSelectAllButton{
    [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 1)] withRowAnimation:UITableViewRowAnimationNone];
}

- (int) getWorkersSelectedCount{
    int count = 0;
    for (int i = 0; i < (int) [self.arrayWorkersSelected count]; i++) {
        if ([[self.arrayWorkersSelected objectAtIndex:i] boolValue] == YES) count++;
    }
    return count;
}

- (void) doWorkersSelectAll{
    int count = [self getWorkersSelectedCount];
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
        [self refreshWorkersSelectAllButton];
    });
}

#pragma mark - Logic

- (NSMutableArray <GANUserRefDataModel *> *) buildMutableReceiversArrayForSelectedWorkers {
    NSMutableArray <GANUserRefDataModel *> *arrayReceivers = [[NSMutableArray alloc] init];
    
    // Add selected workers...
    for (int i = 0; i < (int) [self.arrayWorkersSelected count]; i++) {
        if ([[self.arrayWorkersSelected objectAtIndex:i] boolValue] == YES) {
            GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:i];
            GANUserRefDataModel *userRef = [[GANUserRefDataModel alloc] init];
            userRef.szCompanyId = @"";
            userRef.szUserId = myWorker.szWorkerUserId;
            [arrayReceivers addObject:userRef];
        }
    }
    
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    
    // Add selected groups...
    for (int i = 0; i < (int) [self.arrayCrewsSelected count]; i++) {
        if ([[self.arrayCrewsSelected objectAtIndex:i] boolValue] == YES) {
            GANCrewDataModel *crew = [managerCompany.arrayCrews objectAtIndex:i];
            NSArray <GANMyWorkerDataModel *> *arrayMembers = [managerCompany getMembersListForCrew:crew.szId];
            for (GANMyWorkerDataModel *member in arrayMembers) {
                BOOL isAlreadyAdded = NO;
                for (GANUserRefDataModel *receiver in arrayReceivers) {
                    if ([member.szWorkerUserId isEqualToString:receiver.szUserId] == YES) {
                        isAlreadyAdded = YES;
                        break;
                    }
                }
                if (isAlreadyAdded == NO) {
                    GANUserRefDataModel *userRef = [[GANUserRefDataModel alloc] init];
                    userRef.szCompanyId = @"";
                    userRef.szUserId = member.szWorkerUserId;
                    [arrayReceivers addObject:userRef];
                }
            }
        }
    }
    
    return arrayReceivers;
}

- (void) gotoCrewDetailsVCAtIndex: (int) index{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyCrew" bundle:nil];
        GANCompanyCrewDetailsVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_CREW_DETAILS"];
        vc.indexCrew = index;
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
}

- (void) gotoMessageThreadVC{
    NSMutableArray <GANUserRefDataModel *> *arrayReceivers = [self buildMutableReceiversArrayForSelectedWorkers];
    
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    int indexThread = [managerMessage getIndexForGeneralMessageThreadWithReceivers:arrayReceivers];
    if (indexThread == -1 && [arrayReceivers count] == 1) {
        indexThread = [managerMessage getIndexForGeneralMessageThreadWithSender:[arrayReceivers firstObject]];
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
    vc.isCandidateThread = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Replace VC
        NSMutableArray <UIViewController *> *arrayVCs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [arrayVCs removeLastObject];
        [arrayVCs addObject:vc];
        [self.navigationController setViewControllers:arrayVCs animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
    
    GANACTIVITY_REPORT(@"Company - Go to MessageComposer from Messages");
}

- (void) showCreateCrewDlg {
    dispatch_async(dispatch_get_main_queue(), ^{
        GANCompanyCrewPopupVC *vc = [[GANCompanyCrewPopupVC alloc] initWithNibName:@"CompanyCrewPopupVC" bundle:nil];
        vc.delegate = self;
        [vc setTransitioningDelegate:self.transController];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:nil];
    });
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

- (BOOL) isCrewSelected {
    for (int i = 0; i < (int) [self.arrayCrewsSelected count]; i++) {
        if ([[self.arrayCrewsSelected objectAtIndex:i] boolValue] == YES) return YES;
    }
    return NO;
}

#pragma mark - UITableViewDelegate

- (void) configureGroupHeaderCell: (GANCompanyChooseWorkerGroupHeaderTVC *) cell {
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) configureWorkerHeaderCell: (GANCompanyChooseWorkerHeaderTVC *) cell {
    BOOL show = YES;
    BOOL selectedAll = NO;
    
    if ([self.arrayWorkersSelected count] == 0) {
        show = NO;
    }
    int count = [self getWorkersSelectedCount];
    if (count == (int) [self.arrayWorkersSelected count]) {
        // All selected
        selectedAll = YES;
    }
    else {
        selectedAll = NO;
    }
    
    [cell refreshSelectAllButton:show SelectedAll:selectedAll];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) configureWorkerCell: (GANWorkerItemTVC *) cell AtIndex: (int) index{
    NSLog(@"Checkpoint - 7.%d: Timestamp = %f", index, [[NSDate date] timeIntervalSince1970]);
    GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:index];
    cell.lblWorkerId.text = [myWorker getDisplayName];
    cell.delegate = self;
    cell.index = index;
    
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

- (void) configureCrewCell: (GANCompanyCrewItemTVC *) cell AtIndex: (int) index {
    GANCrewDataModel *crew = [[GANCompanyManager sharedInstance].arrayCrews objectAtIndex:index];
    cell.index = index;
    cell.delegate = self;
    cell.labelName.text = crew.szTitle;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *arrayMembers = [[GANCompanyManager sharedInstance] getMembersListForCrew:crew.szId];
    BOOL onboardingWorkerFound = NO;
    for (GANMyWorkerDataModel *myWorker in arrayMembers) {
        if (myWorker.modelWorker.enumType == GANENUM_USER_TYPE_ONBOARDING_WORKER) {
            onboardingWorkerFound = YES;
            break;
        }
    }
    
    if (onboardingWorkerFound == YES) {
        [cell setItemGreenDot:NO];
    }
    else {
        [cell setItemGreenDot:YES];
    }
    
    BOOL isSelected = [[self.arrayCrewsSelected objectAtIndex:index] boolValue];
    [cell setItemSelected:isSelected];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return [[GANCompanyManager sharedInstance].arrayCrews count];
    }
    else if (section == 2) {
        return 1;
    }
    else if (section == 3) {
        return [self.arrayMyWorkers count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int section = (int) indexPath.section;
    int row = (int) indexPath.row;
    if (section == 0) {
        GANCompanyChooseWorkerGroupHeaderTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_COMPANYCHOOSEWORKER_GROUPHEADER"];
        [self configureGroupHeaderCell:cell];
        return cell;
    }
    else if (section == 1) {
        GANCompanyCrewItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_COMPANYCREWITEM"];
        [self configureCrewCell:cell AtIndex:row];
        return cell;
    }
    else if (section == 2) {
        GANCompanyChooseWorkerHeaderTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_COMPANYCHOOSEWORKER_HEADER"];
        [self configureWorkerHeaderCell:cell];
        return cell;
    }
    else if (section == 3) {
        GANWorkerItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_WORKERITEM"];
        [self configureWorkerCell:cell AtIndex:row];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int section = (int) indexPath.section;
    if (section == 0) {
        return 80;
    }
    else if (section == 2) {
        return 132;
    }
    return CONSTANT_TABLEVIEWCELLHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int section = (int) indexPath.section;
    int row = (int) indexPath.row;
    if (section == 3) {
        BOOL isSelected = [[self.arrayWorkersSelected objectAtIndex:row] boolValue];
        [self.arrayWorkersSelected replaceObjectAtIndex:row withObject:@(!isSelected)];
        [self.tableview reloadData];
    }
    else if (section == 1) {
        BOOL isSelected = [[self.arrayCrewsSelected objectAtIndex:row] boolValue];
        [self.arrayCrewsSelected replaceObjectAtIndex:row withObject:@(!isSelected)];
        [self.tableview reloadData];
    }
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

- (void) workerItemTableViewCellDidDotsClick:(GANWorkerItemTVC *)cell {
    self.indexSelected = cell.index;
    GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:cell.index];
    NSString *szUserName = [myWorker getDisplayName];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:szUserName message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *actionEdit = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeMyWorkerNickName:self.indexSelected];
        });
    }];
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSString *szMessage = [NSString stringWithFormat:@"Are you sure you want to delete %@ from your workers list?", szUserName];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [GANGlobalVCManager promptWithVC:self Title:nil Message:szMessage ButtonYes:@"Yes" ButtonNo:@"No" CallbackYes:^{
                [self deleteMyWorkerAtIndex:cell.index];
            } CallbackNo:nil];
        });
    }];
    
    [alertController addAction:actionDelete];

    if (myWorker.modelWorker.enumType == GANENUM_USER_TYPE_ONBOARDING_WORKER) {
        UIAlertAction *actionResendInvitation = [UIAlertAction actionWithTitle:@"Resend Invitation" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self resendInvite:self.indexSelected];
            });
        }];
        [alertController addAction:actionResendInvitation];
    }
    
    [alertController addAction:actionEdit];
    [alertController addAction:actionCancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void) resendInvite:(NSInteger) nIndex {
    NSString *szCompanyId = [GANUserManager getCompanyDataModel].szId;
    GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:self.indexSelected];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    [[GANCompanyManager sharedInstance] requestSendInvite:myWorker.modelWorker.modelPhone CompanyId:szCompanyId inviteOnly:YES Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"An invitation will be sent shortly via SMS" DismissAfter:-1 Callback:nil];
            [self refreshMyWorkerList];
            GANACTIVITY_REPORT(@"Company - Send invitation");
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:nil];
        }
        self.indexSelected = NON_SELECTED;
    }];
    GANACTIVITY_REPORT(@"Company - Send invite");
}

- (void) deleteMyWorkerAtIndex: (int) index {
    GANMyWorkerDataModel *myWorker = [self.arrayMyWorkers objectAtIndex:self.indexSelected];
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerCompany requestDeleteMyWorker:myWorker.szId Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Worker has been successfully deleted." DismissAfter:-1 Callback:^{
                [self buildFilteredArray];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error" DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) refreshMyWorkerList {
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
    if ([self isWorkerSelected] == NO && [self isCrewSelected] == NO){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select the workers or groups you want to message" DismissAfter:-1 Callback:nil];
        return;
    }
    [self gotoMessageThreadVC];
}

- (IBAction)onButtonSendSurveyClick:(id)sender {
    [self.view endEditing:YES];
    if ([self isWorkerSelected] == NO && [self isCrewSelected] == NO){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select the workers or groups you want to message" DismissAfter:-1 Callback:nil];
        return;
    }
    [self showSurveyTypeChooseDlg];
}

#pragma mark -NSNotification

- (void) onLocalNotificationReceived:(NSNotification *) notification{
    if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED]) ||
             ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED])){
        [self buildFilteredArray];
    }
    else if (([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATED]) ||
             ([[notification name] isEqualToString:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATEFAILED])){
        [self refreshCrewList];
    }
}

#pragma mark - GANCompanyCrewItemTVCDelegate

- (void)companyCrewItemCellDidDotClick:(GANCompanyCrewItemTVC *)cell {
    [self gotoCrewDetailsVCAtIndex:cell.index];
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

#pragma mark - GANCompanyCrewPopupVC Delegate

- (void)companyCrewPopupDidCrewCreate:(int)indexCrew {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self gotoCrewDetailsVCAtIndex:indexCrew];
    });
}

- (void) companyCrewPopupCanceled {
    
}

#pragma mark - GANCompanyChooseWorker Delegates

- (void) didAddWorkerClick {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        [self gotoAddWorkerVC];
    });
}

- (void) didAddGroupClick {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        [self showCreateCrewDlg];
    });
}

- (void) didSelectAllClick {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        [self doWorkersSelectAll];
    });
}

- (void)didTextfieldSearchChange:(NSString *)text {
    self.szSearchKeyword = text;
    [self buildFilteredArray];
}

@end
