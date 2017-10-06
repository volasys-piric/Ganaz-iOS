//
//  GANCompanySurveyChoicesPostVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySurveyChoicesPostVC.h"
#import "GANFadeTransitionDelegate.h"
#import "GANConformMessagePopupVC.h"
#import "GANCompanyMessagesVC.h"
#import "GANSurveyManager.h"
#import "GANMessageManager.h"

#import "GANGlobalVCManager.h"
#import "Global.h"

@interface GANCompanySurveyChoicesPostVC () <UITextFieldDelegate, GANConformMessagePopupVCDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@property (weak, nonatomic) IBOutlet UIView *viewQuestion;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer1;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer2;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer3;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer4;

@property (weak, nonatomic) IBOutlet UITextField *textfieldQuestion;
@property (weak, nonatomic) IBOutlet UITextField *textfieldAnswer1;
@property (weak, nonatomic) IBOutlet UITextField *textfieldAnswer2;
@property (weak, nonatomic) IBOutlet UITextField *textfieldAnswer3;
@property (weak, nonatomic) IBOutlet UITextField *textfieldAnswer4;

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
    
    self.textfieldQuestion.delegate = self;
    self.textfieldAnswer1.delegate = self;
    self.textfieldAnswer2.delegate = self;
    self.textfieldAnswer3.delegate = self;
    self.textfieldAnswer4.delegate = self;
    
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
    NSString *szQuestion = self.textfieldQuestion.text;
    NSString *szAnswer1 = self.textfieldAnswer1.text;
    NSString *szAnswer2 = self.textfieldAnswer2.text;
    NSString *szAnswer3 = self.textfieldAnswer3.text;
    NSString *szAnswer4 = self.textfieldAnswer4.text;
    
    if (szQuestion.length == 0){
        [GANGlobalVCManager shakeView:self.viewQuestion InScrollView:self.scrollview];
        return NO;
    }
    if (szAnswer1.length == 0){
        [GANGlobalVCManager shakeView:self.viewAnswer1 InScrollView:self.scrollview];
        return NO;
    }
    if (szAnswer2.length == 0){
        [GANGlobalVCManager shakeView:self.viewAnswer1 InScrollView:self.scrollview];
        return NO;
    }
    if (szAnswer3.length == 0){
        [GANGlobalVCManager shakeView:self.viewAnswer1 InScrollView:self.scrollview];
        return NO;
    }
    if (szAnswer4.length == 0){
        [GANGlobalVCManager shakeView:self.viewAnswer1 InScrollView:self.scrollview];
        return NO;
    }
    return YES;
}

- (void) doSubmitSurvey{
    if ([self checkMandatoryFields] == NO) return;
    
    NSString *szQuestion = self.textfieldQuestion.text;
    NSString *szAnswer1 = self.textfieldAnswer1.text;
    NSString *szAnswer2 = self.textfieldAnswer2.text;
    NSString *szAnswer3 = self.textfieldAnswer3.text;
    NSString *szAnswer4 = self.textfieldAnswer4.text;

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
    [managerSurvey requestCreateSurveyWithType:GANENUM_SURVEYTYPE_CHOICESINGLE Question:szQuestion Choices:@[szAnswer1, szAnswer2, szAnswer3, szAnswer4] Receivers:arrayReceiversUserRef PhoneNumbers:nil MeataData:nil AutoTranslate:self.isAutoTranslate Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Your survey is posted successfully." DismissAfter:-1 Callback:^{
                [self refreshMessagesList];
            }];
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
        if ([vc isKindOfClass:[GANCompanyMessagesVC class]] == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToViewController:vc animated:YES];
            });
            return;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Company" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_MESSAGES"];
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

@end
