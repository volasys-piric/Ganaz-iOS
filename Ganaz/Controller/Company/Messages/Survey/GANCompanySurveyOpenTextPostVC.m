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
    for (int i = 0; i < count; i++) {
        GANMyWorkerDataModel *worker = [self.arrayReceivers objectAtIndex:i];
        if (i == 0){
            szReceivers = [worker getDisplayName];
        }
        else {
            szReceivers = [NSString stringWithFormat:@"%@, %@", szReceivers, [worker getDisplayName]];
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
    
    NSMutableArray <GANUserRefDataModel *> *arrayReceiversUserRef = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [self.arrayReceivers count]; i++) {
        GANMyWorkerDataModel *worker = [self.arrayReceivers objectAtIndex:i];
        GANUserRefDataModel *userRef = [[GANUserRefDataModel alloc] init];
        userRef.szCompanyId = @"";
        userRef.szUserId = worker.szWorkerUserId;
        [arrayReceiversUserRef addObject:userRef];
    }
    GANSurveyManager *managerSurvey = [GANSurveyManager sharedInstance];
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [managerSurvey requestCreateSurveyWithType:GANENUM_SURVEYTYPE_OPENTEXT Question:szQuestion Choices:nil Receivers:arrayReceiversUserRef PhoneNumbers:nil MeataData:nil AutoTranslate:self.isAutoTranslate Callback:^(int status) {
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
            [self gotoMessagesVC];
        }];
    }];
}

- (void) gotoMessagesVC{
    UINavigationController *nav = self.navigationController;
    NSArray <UIViewController *> *arrayVCs = nav.viewControllers;
    for (int i = 0; i < (int) [arrayVCs count]; i++) {
        UIViewController *vc = [arrayVCs objectAtIndex:i];
        if ([vc isKindOfClass:[GANCompanyMessageListVC class]] == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToViewController:vc animated:YES];
            });
            return;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGES_LIST"];
    [self.navigationController setViewControllers:@[vc] animated:YES];
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
