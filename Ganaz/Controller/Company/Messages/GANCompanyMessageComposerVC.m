//
//  GANCompanyMessageComposerVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/4/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyMessageComposerVC.h"
#import "GANFadeTransitionDelegate.h"
#import "GANCompanyMapPopupVC.h"
#import "GANMessageWithChargeConfirmationPopupVC.h"
#import "GANSurveyTypeChoosePopupVC.h"
#import "GANCompanyMessagesVC.h"
#import "GANCompanySurveyChoicesPostVC.h"
#import "GANCompanySurveyOpenTextPostVC.h"

#import "GANMessageManager.h"

#import "UIColor+GANColor.h"
#import "GANGlobalVCManager.h"
#import "GANAppManager.h"
#import "Global.h"

@interface GANCompanyMessageComposerVC () <GANCompanyMapPopupVCDelegate, GANMessageWithChargeConfirmationPopupDelegate, GANSurveyTypeChoosePopupDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewMessage;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet UIButton *buttonMap;
@property (weak, nonatomic) IBOutlet UIButton *buttonAutoTranslate;
@property (weak, nonatomic) IBOutlet UIButton *buttonSurvey;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;

@property (weak, nonatomic) IBOutlet UILabel *labelReceivers;
@property (weak, nonatomic) IBOutlet UIImageView *imageMapIcon;

@property (assign, atomic) BOOL isAutoTranslate;
@property (strong, nonatomic) GANFadeTransitionDelegate *transController;
@property (strong, nonatomic) GANLocationDataModel *modelLocation;

@end

@implementation GANCompanyMessageComposerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isAutoTranslate = NO;
    [self refreshViews];
    [self refreshFields];
    
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    self.modelLocation = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.buttonSubmit.layer.cornerRadius = 3;
    self.buttonSurvey.layer.cornerRadius = 3;
    self.viewMessage.layer.cornerRadius = 3;
    
    self.buttonSubmit.clipsToBounds = YES;
    self.buttonSurvey.clipsToBounds = YES;
    self.viewMessage.clipsToBounds = YES;
    
    [self refreshAutoTranslateView];
    [self refreshMapIcon];
}

- (void) refreshMapIcon{
    if (self.modelLocation == nil){
        self.imageMapIcon.image = [UIImage imageNamed:@"map-pin"];
        [self.buttonMap setTitleColor:[UIColor GANThemeMainColor] forState:UIControlStateNormal];
    }
    else {
        self.imageMapIcon.image = [UIImage imageNamed:@"map_pin-green"];
        [self.buttonMap setTitleColor:[UIColor GANThemeGreenColor] forState:UIControlStateNormal];
    }
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
        szReceivers = [NSString stringWithFormat:@"%@,... (+%d)", szReceivers, (int)([self.arrayReceivers count] - count)];
    }
    
    self.labelReceivers.text = szReceivers;
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

- (void) checkOnboardingWorker {
    NSInteger countOnboardingWorker = 0;
    for (int i = 0; i < (int) [self.arrayReceivers count]; i++) {
        GANMyWorkerDataModel *myWorker = [self.arrayReceivers objectAtIndex:i];
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
    NSString *szMessage = self.textview.text;
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    NSMutableArray *arrReceivers = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int) [self.arrayReceivers count]; i++) {
        GANMyWorkerDataModel *myWorker = [self.arrayReceivers objectAtIndex:i];
        [arrReceivers addObject:@{@"user_id": myWorker.szWorkerUserId,
                                  @"company_id": @""}];
    }
    
    NSDictionary *dictMetaData = nil;
    if(self.modelLocation) {
        dictMetaData = @{@"map" : [self.modelLocation serializeToMetaDataDictionary]};
    }
    
    [[GANMessageManager sharedInstance] requestSendMessageWithJobId:@"NONE" Type:GANENUM_MESSAGE_TYPE_MESSAGE Receivers:arrReceivers ReceiversPhoneNumbers: nil Message:szMessage MetaData:dictMetaData AutoTranslate:self.isAutoTranslate FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            [GANGlobalVCManager showHudSuccessWithMessage:@"Message sent!" DismissAfter:-1 Callback:^{
                [self gotoMessagesVC];
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

// MARK: Survey

- (void) showSurveyTypeChooseDlg{
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
    GANCompanySurveyChoicesPostVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SURVEY_CHOICESPOST"];
    vc.arrayReceivers = self.arrayReceivers;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to Survey from Message");
}

- (void) gotoSurveyOpenTextPostVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CompanyMessage" bundle:nil];
    GANCompanySurveyOpenTextPostVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SURVEY_OPENTEXTPOST"];
    vc.arrayReceivers = self.arrayReceivers;
    
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    GANACTIVITY_REPORT(@"Company - Go to Survey from Message");
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonAutoTranslateClick:(id)sender {
    [self.view endEditing:YES];
    self.isAutoTranslate = !self.isAutoTranslate;
    [self refreshAutoTranslateView];
}

- (IBAction)onButtonMapClick:(id)sender {
    [self.view endEditing:YES];
    [self showMapDlg];
}

- (IBAction)onBtnSubmitClick:(id)sender {
    [self.view endEditing:YES];
    NSString *sz = self.textview.text;
    if (sz.length == 0){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please enter a message to send" DismissAfter:-1 Callback:nil];
        return;
    }
    
    [self checkOnboardingWorker];
}

- (IBAction)onButtonSurveyClick:(id)sender {
    [self.view endEditing:YES];
    [self showSurveyTypeChooseDlg];
}

#pragma mark - GANMessageWithChargeConfirmationPopupVC Delegate

- (void)messageWithChargeConfirmationPopupDidSendClick:(GANMessageWithChargeConfirmationPopupVC *)popup {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doSendMessage];
    });
}

- (void)messageWithChargeConfirmationPopupDidCancelClick:(GANMessageWithChargeConfirmationPopupVC *)popup {
    
}

#pragma mark - GANCompanyMapPopupVCDelegate

- (void) submitLocation:(GANLocationDataModel *)location {
    self.modelLocation = location;
    [self refreshMapIcon];
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
