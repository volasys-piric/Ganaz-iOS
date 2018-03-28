//
//  GANWorkerSurveyOpenTextVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerSurveyOpenTextVC.h"
#import "GANCacheManager.h"
#import "GANMessageManager.h"
#import "GANGlobalVCManager.h"
#import "Global.h"
#import "GANAppManager.h"

@interface GANWorkerSurveyOpenTextVC ()

@property (weak, nonatomic) IBOutlet UIView *viewAnswer;
@property (weak, nonatomic) IBOutlet UITextView *textviewAnswer;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelQuestion;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;

@property (assign, atomic) BOOL isEditable;
@property (strong, nonatomic) GANSurveyDataModel *modelSurvey;
@property (strong, nonatomic) GANSurveyAnswerDataModel *modelAnswer;

@end

@implementation GANWorkerSurveyOpenTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    self.modelSurvey = [managerCache.arraySurvey objectAtIndex:self.indexSurvey];
    int indexAnswer = [managerCache getIndexForSurveyAnswerWithSurveyId:self.modelSurvey.szId ResponderUserId:[GANUserManager getUserWorkerDataModel].szId];
    if (indexAnswer != -1){
        self.modelAnswer = [managerCache.arraySurveyAnswers objectAtIndex:indexAnswer];
        self.isEditable = NO;
        self.textviewAnswer.text = [self.modelAnswer.modelAnswerText getTextES];
    }
    else {
        self.isEditable = YES;
        self.modelAnswer = nil;
        self.textviewAnswer.text = @"";
    }
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.labelTitle.text = @"Company quiere saber:";
    [[GANCacheManager sharedInstance] getCompanyBusinessNameESByCompanyId:self.modelSurvey.modelOwner.szCompanyId Callback:^(NSString *businessNameES) {
        self.labelTitle.text = [NSString stringWithFormat:@"%@ quiere saber:", businessNameES];
    }];
    
    self.labelQuestion.text = [self.modelSurvey.modelQuestion getTextES];
    
    if (self.isEditable == YES) {
        self.buttonSubmit.hidden = NO;
        self.textviewAnswer.userInteractionEnabled = YES;
        self.textviewAnswer.editable = YES;
    }
    else {
        self.buttonSubmit.hidden = YES;
        self.textviewAnswer.userInteractionEnabled = NO;
        self.textviewAnswer.editable = NO;
    }
    
    self.viewAnswer.layer.cornerRadius = 3;
    self.buttonSubmit.layer.cornerRadius = 3;
}

#pragma mark - Logic

- (void) doSubmitAnswer {
    NSString *szText = self.textviewAnswer.text;
    if (szText.length == 0) {
        // Please enter your answer
        [GANGlobalVCManager showHudErrorWithMessage:@"Por favor, escribe su respuesta" DismissAfter:-1 Callback:nil];
        return;
    }
    
    // Please wait...
    [GANGlobalVCManager showHudProgressWithMessage:@"Por favor, espere..."];
    [[GANSurveyManager sharedInstance] requestSubmitSurveyOpenTextAnswerBySurveyId:self.modelSurvey.szId Text:szText AutoTranslate:self.modelSurvey.isAutoTranslate Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Gracias por responder a esta encuesta." DismissAfter:-1 Callback:^{
                [self refreshMessagesList];
            }];
            GANACTIVITY_REPORT(@"Worker - survey answered");
        }
        else {
            // Sorry, we've encountered an error.
            [GANGlobalVCManager showHudErrorWithMessage:@"Perdón. Hemos encontrado un error" DismissAfter:-1 Callback:nil];
        }
    }];
}

- (void) refreshMessagesList{
    GANMessageManager *managerMessage = [GANMessageManager sharedInstance];
    // Loading messages...
    [GANGlobalVCManager showHudProgressWithMessage:@"Cargando mensajes..."];
    [managerMessage requestGetMessageListWithCallback:^(int status) {
        [GANGlobalVCManager hideHudProgressWithCallback:^{
            [self gotoMessagesVC];
        }];
    }];
}

- (void) gotoMessagesVC{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onButtonSubmitClick:(id)sender {
    [self.view endEditing:YES];
    [self doSubmitAnswer];
}

@end
