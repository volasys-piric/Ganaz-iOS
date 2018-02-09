//
//  GANComposeMessageOnboardingVC.m
//  Ganaz
//
//  Created by forever on 8/19/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANComposeMessageOnboardingVC.h"
#import "GANCompanySignupVC.h"
#import "GANSharePostingWithContactsVC.h"
#import "GANCompanyMapPopupVC.h"

#import "GANPhonebookContactDataModel.h"
#import "GANGlobalVCManager.h"
#import "GANCompanyManager.h"
#import "GANAppManager.h"
#import "GANMessageManager.h"
#import "GANUtils.h"
#import "Global.h"
#import "GANFadeTransitionDelegate.h"

@interface GANComposeMessageOnboardingVC ()<UITextViewDelegate, GANCompanyMapPopupVCDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblSendMessageUsers;
@property (strong, nonatomic) IBOutlet UIView *viewMessage;
@property (strong, nonatomic) IBOutlet UITextView *txtMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnSubmit;
@property (strong, nonatomic) IBOutlet UIButton *btnAutoTranslate;

@property (strong, nonatomic) IBOutlet UIButton *btnMap;
@property (strong, nonatomic) IBOutlet UIImageView *imgMapIcon;

@property (assign, atomic) BOOL isAutoTranslate;

@property (strong, nonatomic) GANFadeTransitionDelegate *transController;
@property (strong, nonatomic) GANLocationDataModel *mapData;

@end

@implementation GANComposeMessageOnboardingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblSendMessageUsers.text = [NSString stringWithFormat:@"%@", [self getWorkerNames]];
    self.transController = [[GANFadeTransitionDelegate alloc] init];
    self.isAutoTranslate = NO;
    
    [self refreshView];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.isFromSignup)
        [self doSendMessage];
}

- (void) refreshView {
    self.viewMessage.layer.cornerRadius = 3;
    self.btnSubmit.layer.cornerRadius = 3;
    self.btnSubmit.clipsToBounds = YES;
    
    [self refreshAutoTranslateView];
}

- (void) refreshAutoTranslateView{
    if (self.isAutoTranslate == YES){
        [self.btnAutoTranslate setImage:[UIImage imageNamed:@"icon-checked"] forState:UIControlStateNormal];
    }
    else {
        [self.btnAutoTranslate setImage:[UIImage imageNamed:@"icon-unchecked"] forState:UIControlStateNormal];
    }
}

- (NSString *) getWorkerNames {
    
    NSString *szName = @"";
    if(self.aryCommunicateUsers.count > 0) {
        for(int i = 0; i < self.aryCommunicateUsers.count; i ++) {
            if (i != 0)
                szName = [NSString stringWithFormat:@"%@, ", szName];
            
            GANPhonebookContactDataModel *contact = [self.aryCommunicateUsers objectAtIndex:i];
            if([contact.szFirstName isEqualToString:@""] || contact.szFirstName == nil) {
                szName = [NSString stringWithFormat:@"%@%@", szName, contact.modelPhone.szLocalNumber];
            } else {
                szName = [NSString stringWithFormat:@"%@%@", szName, contact.szFirstName];
            }
        }
    }
    return szName;
}

- (void) doSendMessage{
    
    NSString *szMessage = self.txtMessage.text;
    if (szMessage.length == 0){
        [GANGlobalVCManager showHudErrorWithMessage:@"Please enter a message to send" DismissAfter:-1 Callback:nil];
        return;
    }
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    NSMutableArray <GANPhoneDataModel *> *arrayPhones = [[NSMutableArray alloc] init];
    
    for (int i =0; i < self.aryCommunicateUsers.count; i ++) {
        GANPhonebookContactDataModel *contact = [self.aryCommunicateUsers objectAtIndex:i];
        [arrayPhones addObject:contact.modelPhone];
    }
    
    NSDictionary *metaData;
    if(self.mapData) {
        metaData = @{@"map" : [self.mapData serializeToMetaDataDictionary]};
    }
    
    [[GANMessageManager sharedInstance] requestSendMessageWithJobId:@"NONE" Type:GANENUM_MESSAGE_TYPE_MESSAGE Receivers:nil ReceiverPhones: arrayPhones Message:szMessage MetaData:metaData AutoTranslate:self.isAutoTranslate FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            
            [GANGlobalVCManager showHudSuccessWithMessage:@"Message sent!" DismissAfter:-1 Callback:^{
                [self gotoMessageVC];
            }];
        } else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:^{
                [self gotoMessageVC];
            }];
            
        }
    }];
    GANACTIVITY_REPORT(@"Company - Send message");
}

- (void) gotoMessageVC {
    [[GANCompanyManager sharedInstance] requestGetMyWorkersListWithCallback:^(int status) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (IBAction)onAutoTranslate:(id)sender {
    [self.view endEditing:YES];
    self.isAutoTranslate = !self.isAutoTranslate;
    [self refreshAutoTranslateView];
}

- (IBAction)onSubmit:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login+Signup" bundle:nil];
    GANCompanySignupVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_COMPANY_SIGNUP"];
    vc.fromCustomVC = ENUM_COMMUNICATE_SIGNUP;
    [self.navigationController pushViewController:vc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
