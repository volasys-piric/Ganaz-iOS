//
//  GANWorkerSurveyChoicesVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerSurveyChoicesVC.h"
#import "GANCacheManager.h"
#import "GANMessageManager.h"
#import "GANWorkerMessagesVC.h"
#import "GANSurveyChoiceSingleAnswerItemTVC.h"
#import "GANGlobalVCManager.h"
#import "Global.h"

@interface GANWorkerSurveyChoicesVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelQuestion;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;

@property (assign, atomic) BOOL isEditable;
@property (strong, nonatomic) GANSurveyDataModel *modelSurvey;
@property (strong, nonatomic) GANSurveyAnswerDataModel *modelAnswer;
@property (strong, nonatomic) NSMutableArray *arraySelected;

@end

@implementation GANWorkerSurveyChoicesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arraySelected = [[NSMutableArray alloc] init];

    GANCacheManager *managerCache = [GANCacheManager sharedInstance];
    self.modelSurvey = [managerCache.arraySurvey objectAtIndex:self.indexSurvey];
    int indexAnswer = [managerCache getIndexForSurveyAnswerWithSurveyId:self.modelSurvey.szId ResponderUserId:[GANUserManager getUserWorkerDataModel].szId];
    if (indexAnswer != -1){
        self.modelAnswer = [managerCache.arraySurveyAnswers objectAtIndex:indexAnswer];
        self.isEditable = NO;
        for (int i = 0; i < (int) [self.modelSurvey.arrayChoices count]; i++){
            if (self.modelAnswer.indexChoice == i) {
                [self.arraySelected addObject:@(YES)];
            }
            else {
                [self.arraySelected addObject:@(NO)];
            }
        }
    }
    else {
        self.isEditable = YES;
        self.modelAnswer = nil;
        for (int i = 0; i < (int) [self.modelSurvey.arrayChoices count]; i++){
            [self.arraySelected addObject:@(NO)];
        }
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 30;
    
    
    [self registerTableViewCellFromNib];
    [self refreshViews];
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"SurveyChoiceSingleAnswerItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_SURVEY_CHOICESINGLEANSWERITEM"];
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
    }
    else {
        self.buttonSubmit.hidden = YES;
    }
    
    self.buttonSubmit.layer.cornerRadius = 3;
}

#pragma mark - Logic

- (void) doSubmitAnswer {
    int indexSelected = -1;
    for (int i = 0; i < (int) [self.arraySelected count]; i++) {
        BOOL selected = [[self.arraySelected objectAtIndex:i] boolValue];
        if (selected == YES) {
            indexSelected = i;
            break;
        }
    }
    
    if (indexSelected == -1) {
        [GANGlobalVCManager showHudErrorWithMessage:@"Please select answer" DismissAfter:-1 Callback:nil];
        return;
    }
    
    [GANGlobalVCManager showHudProgressWithMessage:@"Please wait..."];
    [[GANSurveyManager sharedInstance] requestSubmitSurveyChoiceAnswerBySurveyId:self.modelSurvey.szId ChoiceIndex:indexSelected Callback:^(int status) {
        if (status == SUCCESS_WITH_NO_ERROR) {
            [GANGlobalVCManager showHudSuccessWithMessage:@"Your answer is posted successfully." DismissAfter:-1 Callback:^{
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
        if ([vc isKindOfClass:[GANWorkerMessagesVC class]] == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToViewController:vc animated:YES];
            });
            return;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Worker" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_WORKER_MESSAGES"];
    [self.navigationController setViewControllers:@[vc] animated:YES];
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANSurveyChoiceSingleAnswerItemTVC *) cell AtIndex: (int) index{
    GANTransContentsDataModel *choice = [self.modelSurvey.arrayChoices objectAtIndex:index];
    cell.labelAnswer.text = [choice getTextES];
    cell.isSelected = [[self.arraySelected objectAtIndex:index] boolValue];
    [cell refreshViews];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.modelSurvey.arrayChoices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANSurveyChoiceSingleAnswerItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_SURVEY_CHOICESINGLEANSWERITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditable == NO) return;
    for (int i = 0; i < (int) [self.arraySelected count]; i++) {
        if ((int) indexPath.row == i) {
            [self.arraySelected replaceObjectAtIndex:i withObject:@(YES)];
        }
        else {
            [self.arraySelected replaceObjectAtIndex:i withObject:@(NO)];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonSubmitClick:(id)sender {
    [self doSubmitAnswer];
}

@end
