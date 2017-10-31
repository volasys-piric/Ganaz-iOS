//
//  GANCompanySurveyOpenTextPostVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySurveyOpenTextPostVC.h"
#import "GANFadeTransitionDelegate.h"
#import "GANMessageWithChargeConfirmationPopupVC.h"
#import "GANCompanyMessageListVC.h"
#import "GANCompanyMessageThreadVC.h"
#import "GANGlobalVCManager.h"

#import "GANSurveyManager.h"
#import "GANMessageManager.h"

#import "Global.h"
#import "GANAppManager.h"

#define GANCOMPANYSURVEYCHOICESPOSTVC_TEXTVIEW_PLACEHOLDER      @"Enter question here..."

@interface GANCompanySurveyOpenTextPostVC () <UITextViewDelegate, GANMessageWithChargeConfirmationPopupDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewQuestion;
@property (weak, nonatomic) IBOutlet UITextView *textviewQuestion;

@property (weak, nonatomic) IBOutlet UIButton *buttonAutoTranslate;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;

@property (weak, nonatomic) IBOutlet UILabel *labelReceivers;

@property (assign, atomic) BOOL isAutoTranslate;
@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@end

@implementation GANCompanySurveyOpenTextPostVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isAutoTranslate = NO;
    self.textviewQuestion.text = GANCOMPANYSURVEYCHOICESPOSTVC_TEXTVIEW_PLACEHOLDER;
    self.textviewQuestion.delegate = self;
    
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
    self.buttonSubmit.layer.cornerRadius = 3;
    
    self.viewQuestion.clipsToBounds = YES;
    self.buttonSubmit.clipsToBounds = YES;
    
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
    NSString *szReceivers = @"";
    int count = MIN(3, (int) [self.arrayReceivers count]);
    GANCompanyManager *managerCompany = [GANCompanyManager sharedInstance];
    
    for (int i = 0; i < count; i++) {
        GANUserRefDataModel *userRef = [self.arrayReceivers objectAtIndex:i];
        int indexMyWorker = [managerCompany getIndexForMyWorkersWithUserId:userRef.szUserId];
        if (indexMyWorker == -1) continue;
        GANMyWorkerDataModel *myWorker = [managerCompany.arrMyWorkers objectAtIndex:i];
        if (i == 0){
            szReceivers = [myWorker getDisplayName];
        }
        else {
            szReceivers = [NSString stringWithFormat:@"%@, %@", szReceivers, [myWorker getDisplayName]];
        }
    }
    
    if (count < [self.arrayReceivers count]) {
        szReceivers = [NSString stringWithFormat:@"%@... (+%d)", szReceivers, (int)([self.arrayReceivers count] - count)];
    }
    
    self.labelReceivers.text = szReceivers;
}

#pragma mark - Logic

- (BOOL) checkMandatoryFields {
    NSString *szQuestion = self.textviewQuestion.text;
    
    if (szQuestion.length == 0 || [szQuestion isEqualToString:GANCOMPANYSURVEYCHOICESPOSTVC_TEXTVIEW_PLACEHOLDER] == YES){
        [GANGlobalVCManager shakeView:self.viewQuestion];
        return NO;
    }
    return YES;
}

- (void) doSubmitSurvey{
    if ([self checkMandatoryFields] == NO) return;
    
    NSString *szQuestion = self.textviewQuestion.text;
    GANSurveyManager *managerSurvey = [GANSurveyManager sharedInstance];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerSurvey requestCreateSurveyWithType:GANENUM_SURVEYTYPE_OPENTEXT Question:szQuestion Choices:nil Receivers:self.arrayReceivers PhoneNumbers:nil MeataData:nil AutoTranslate:self.isAutoTranslate Callback:^(int status) {
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
            [self gotoMessageThreadVC];
        }];
    }];
}

- (void) gotoMessageThreadVC{
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    int indexThread = [managerMessage getIndexForMessageThreadWithReceivers:self.arrayReceivers];
    if (indexThread == -1 && [self.arrayReceivers count] == 1) {
        indexThread = [managerMessage getIndexForMessageThreadWithSender:[self.arrayReceivers firstObject]];
    }
    
    UINavigationController *nav = self.navigationController;
    NSArray <UIViewController *> *arrayVCs = nav.viewControllers;
    NSMutableArray <UIViewController *> *arrayNewVCs = [[NSMutableArray alloc] init];
    
    BOOL isMessageListVCFound = NO;
    BOOL isMessageThreadVCFound = NO;
    for (int i = 0; i < (int) [arrayVCs count]; i++) {
        UIViewController *vc = [arrayVCs objectAtIndex:i];
        if ([vc isKindOfClass:[GANCompanyMessageListVC class]] == YES) {
            [arrayNewVCs insertObject:vc atIndex:0];
            isMessageListVCFound = YES;
        }
        
        if ([vc isKindOfClass:[GANCompanyMessageThreadVC class]] == YES) {
            GANCompanyMessageThreadVC *vcThread = (GANCompanyMessageThreadVC *) vc;
            vcThread.indexThread = indexThread;
            vcThread.arrayReceivers = [[NSMutableArray alloc] initWithArray: self.arrayReceivers];

            
            [arrayNewVCs addObject:vcThread];
            isMessageThreadVCFound = YES;
        }
    }
    
    if (isMessageListVCFound == NO) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGES_LIST"];
        [arrayNewVCs insertObject:vc atIndex:0];
    }
    
    if (isMessageThreadVCFound == NO) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
        GANCompanyMessageThreadVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGE_THREAD"];
        vc.indexThread = indexThread;
        vc.arrayReceivers = [[NSMutableArray alloc] initWithArray: self.arrayReceivers];
        [arrayNewVCs addObject:vc];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController setViewControllers:arrayNewVCs animated:YES];
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

#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.textviewQuestion.text = @"";
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.textviewQuestion.text.length == 0) {
        self.textviewQuestion.text = GANCOMPANYSURVEYCHOICESPOSTVC_TEXTVIEW_PLACEHOLDER;
    }
}

@end
