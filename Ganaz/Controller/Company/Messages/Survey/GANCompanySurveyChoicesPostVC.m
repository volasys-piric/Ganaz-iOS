//
//  GANCompanySurveyChoicesPostVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySurveyChoicesPostVC.h"
#import "GANFadeTransitionDelegate.h"
#import "GANMessageWithChargeConfirmationPopupVC.h"
#import "GANCompanyMessageListVC.h"
#import "GANCompanyMessageThreadVC.h"
#import "GANSurveyManager.h"
#import "GANMessageManager.h"

#import "GANGlobalVCManager.h"
#import "Global.h"
#import "GANAppManager.h"
#import "UITextView+Placeholder.h"

@interface GANCompanySurveyChoicesPostVC () <UITextViewDelegate, GANMessageWithChargeConfirmationPopupDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@property (weak, nonatomic) IBOutlet UIView *viewQuestion;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer1;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer2;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer3;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer4;

@property (weak, nonatomic) IBOutlet UITextView *textviewQuestion;
@property (weak, nonatomic) IBOutlet UITextView *textviewChoice1;
@property (weak, nonatomic) IBOutlet UITextView *textviewChoice2;
@property (weak, nonatomic) IBOutlet UITextView *textviewChoice3;
@property (weak, nonatomic) IBOutlet UITextView *textviewChoice4;

@property (weak, nonatomic) IBOutlet UILabel *labelReceivers;

@property (weak, nonatomic) IBOutlet UIButton *buttonAutoTranslate;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;

@property (assign, atomic) BOOL isAutoTranslate;
@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@end

@implementation GANCompanySurveyChoicesPostVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isAutoTranslate = NO;
    
    [self refreshViews];
    [self refreshFields];
    self.transController = [[GANFadeTransitionDelegate alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.viewQuestion.layer.cornerRadius = 3;
    self.viewAnswer1.layer.cornerRadius = 3;
    self.viewAnswer2.layer.cornerRadius = 3;
    self.viewAnswer3.layer.cornerRadius = 3;
    self.viewAnswer4.layer.cornerRadius = 3;
    self.buttonSubmit.layer.cornerRadius = 3;

    self.viewQuestion.clipsToBounds = YES;
    self.viewAnswer1.clipsToBounds = YES;
    self.viewAnswer2.clipsToBounds = YES;
    self.viewAnswer3.clipsToBounds = YES;
    self.viewAnswer4.clipsToBounds = YES;
    self.buttonSubmit.clipsToBounds = YES;
    
    self.textviewQuestion.delegate = self;
    self.textviewChoice1.delegate = self;
    self.textviewChoice2.delegate = self;
    self.textviewChoice3.delegate = self;
    self.textviewChoice4.delegate = self;
    
    [self refreshAutoTranslateView];
}

- (void) refreshAutoTranslateView{
    if (self.isAutoTranslate == YES){
        [self.buttonAutoTranslate setImage:[UIImage imageNamed:@"icon-checked"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonAutoTranslate setImage:[UIImage imageNamed:@"icon-unchecked"] forState:UIControlStateNormal];
    }
}

- (void) refreshFields{
    [[GANMessageManager sharedInstance] requestGetBeautifiedReceiversAbbrWithReceivers:self.arrayReceivers Callback:^(NSString *beautifiedName) {
        self.labelReceivers.text = beautifiedName;
    }];
}

#pragma mark - Logic

- (BOOL) checkMandatoryFields {
    NSString *szQuestion = self.textviewQuestion.text;
    NSString *szChoice1 = self.textviewChoice1.text;
    NSString *szChoice2 = self.textviewChoice2.text;
    NSString *szChoice3 = self.textviewChoice3.text;
    NSString *szChoice4 = self.textviewChoice4.text;
    int count = 4;
    if (szQuestion.length == 0){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please input question." DismissAfter:-1 Callback:nil];
        return NO;
    }
    if (szChoice1.length == 0){
        count = count - 1;
    }
    if (szChoice2.length == 0){
        count = count - 1;
    }
    if (szChoice3.length == 0){
        count = count - 1;
    }
    if (szChoice4.length == 0){
        count = count - 1;
    }
    
    if (count < 2) {
        [GANGlobalVCManager showHudErrorWithMessage:@"Please input at least 2 choices." DismissAfter:-1 Callback:nil];
        return NO;
    }
    return YES;
}

- (void) doSubmitSurvey{
    if ([self checkMandatoryFields] == NO) return;
    
    NSString *szQuestion = self.textviewQuestion.text;
    NSString *szChoice1 = self.textviewChoice1.text;
    NSString *szChoice2 = self.textviewChoice2.text;
    NSString *szChoice3 = self.textviewChoice3.text;
    NSString *szChoice4 = self.textviewChoice4.text;
    NSMutableArray *arrayChoices = [[NSMutableArray alloc] init];
    if (szChoice1.length > 0){
        [arrayChoices addObject:szChoice1];
    }
    if (szChoice2.length > 0){
        [arrayChoices addObject:szChoice2];
    }
    if (szChoice3.length > 0){
        [arrayChoices addObject:szChoice3];
    }
    if (szChoice4.length > 0){
        [arrayChoices addObject:szChoice4];
    }

    GANSurveyManager *managerSurvey = [GANSurveyManager sharedInstance];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerSurvey requestCreateSurveyWithType:GANENUM_SURVEYTYPE_CHOICESINGLE Question:szQuestion Choices:arrayChoices Receivers:self.arrayReceivers PhoneNumbers:nil MeataData:nil AutoTranslate:self.isAutoTranslate Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Survey has been posted successfully." DismissAfter:-1 Callback:^{
                [self refreshMessagesList];
            }];
            GANACTIVITY_REPORT(@"Company - Post survey");
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an error" DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) refreshMessagesList{
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    [GANGlobalVCManager showHudProgressWithMessage:@"Loading messages..."];
    [managerMessage requestGetMessageListWithCallback:^(int status) {
        [GANGlobalVCManager hideHudProgressWithCallback:^{
            [self gotoMessageListVC];
        }];
    }];
}

- (void) gotoMessageListVC {
    UINavigationController *nav = self.navigationController;
    NSArray <UIViewController *> *arrayVCs = nav.viewControllers;
    
    GANCompanyMessageListVC *vcList = nil;
    
    for (int i = 0; i < (int) [arrayVCs count]; i++) {
        UIViewController *vc = [arrayVCs objectAtIndex:i];
        if ([vc isKindOfClass:[GANCompanyMessageListVC class]] == YES) {
            vcList = (GANCompanyMessageListVC *) vc;
            break;
        }
    }
    
    if (vcList == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
        vcList = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGES_LIST"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController setViewControllers:@[vcList] animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
    
    GANACTIVITY_REPORT(@"Company - Go to MessageList from Survey");
}

- (void) gotoMessageThreadVC{
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    int indexThread = [managerMessage getIndexForMessageThreadWithReceivers:self.arrayReceivers];
    if (indexThread == -1 && [self.arrayReceivers count] == 1) {
        indexThread = [managerMessage getIndexForMessageThreadWithSender:[self.arrayReceivers firstObject]];
    }

    UINavigationController *nav = self.navigationController;
    NSArray <UIViewController *> *arrayVCs = nav.viewControllers;
    
    GANCompanyMessageListVC *vcList = nil;
    GANCompanyMessageThreadVC *vcThread = nil;
    
    for (int i = 0; i < (int) [arrayVCs count]; i++) {
        UIViewController *vc = [arrayVCs objectAtIndex:i];
        if ([vc isKindOfClass:[GANCompanyMessageListVC class]] == YES) {
            vcList = (GANCompanyMessageListVC *) vc;
        }
        
        if ([vc isKindOfClass:[GANCompanyMessageThreadVC class]] == YES) {
            vcThread = (GANCompanyMessageThreadVC *) vc;
        }
    }
    
    if (vcList == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
        vcList = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGES_LIST"];
    }
    
    if (vcThread == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
        vcThread = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGE_THREAD"];
    }
    
    vcThread.indexThread = indexThread;
    vcThread.arrayReceivers = [[NSMutableArray alloc] initWithArray: self.arrayReceivers];
    vcThread.isFacebookLeadWorker = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController setViewControllers:@[vcList, vcThread] animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    });
    
    GANACTIVITY_REPORT(@"Company - Go to MessageThread from Survey");
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonAutoTranslateClick:(id)sender {
    [self.view endEditing:YES];
    self.isAutoTranslate = !self.isAutoTranslate;
    [self refreshAutoTranslateView];
}

- (IBAction)onButtonSubmitClick:(id)sender {
    [self.view endEditing:YES];
    [self doSubmitSurvey];
}

@end
