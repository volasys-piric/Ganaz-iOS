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

#import "GANPhonebookContactDataModel.h"
#import "GANGlobalVCManager.h"
#import "GANCompanyManager.h"
#import "GANAppManager.h"
#import "GANMessageManager.h"
#import "GANUtils.h"
#import "Global.h"

@interface GANComposeMessageOnboardingVC ()<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblSendMessageUsers;
@property (strong, nonatomic) IBOutlet UIView *viewMessage;
@property (strong, nonatomic) IBOutlet UITextView *txtMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnSubmit;
@property (strong, nonatomic) IBOutlet UIButton *btnAutoTranslate;

@property (assign, atomic) BOOL isAutoTranslate;

@end

@implementation GANComposeMessageOnboardingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblSendMessageUsers.text = [NSString stringWithFormat:@"To: %@", [self getWorkersName]];
    
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

- (NSString *) getWorkersName {
    
    NSString *szName = @"";
    if(self.aryCommunicateUsers.count > 0) {
        for(int i = 0; i < self.aryCommunicateUsers.count; i ++) {
            if(i > 2) {
                szName = [NSString stringWithFormat:@"%@...", szName];
                break;
            } else if (i != 0){
                szName = [NSString stringWithFormat:@"%@, ", szName];
            }
            
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
        [GANGlobalVCManager showHudErrorWithMessage:@"Please input message to send." DismissAfter:-1 Callback:nil];
        return;
    }
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    
    NSMutableArray *arrPhoneNumber = [[NSMutableArray alloc] init];
    
    for (int i =0; i < self.aryCommunicateUsers.count; i ++) {
        GANPhonebookContactDataModel *contact = [self.aryCommunicateUsers objectAtIndex:i];
        [arrPhoneNumber addObject:contact.modelPhone.szLocalNumber];
    }
    
    [[GANMessageManager sharedInstance] requestSendMessageWithJobId:@"NONE" Type:GANENUM_MESSAGE_TYPE_MESSAGE Receivers:nil ReceiversPhoneNumbers: arrPhoneNumber Message:szMessage AutoTranslate:self.isAutoTranslate FromLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_EN ToLanguage:GANCONSTANTS_TRANSLATE_LANGUAGE_ES Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR){
            
            [GANGlobalVCManager showHudSuccessWithMessage:@"Message is sent!" DismissAfter:-1 Callback:^{
                [self gotoMessageVC];
            }];
        }
        else {
            [GANGlobalVCManager showHudErrorWithMessage:@"Sorry, we've encountered an issue" DismissAfter:-1 Callback:^{
                [self gotoMessageVC];
            }];
            
        }
    }];
    GANACTIVITY_REPORT(@"Company - Send message");
}

- (void) gotoMessageVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
