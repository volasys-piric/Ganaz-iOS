//
//  GANCompanySurveyOpenTextResultVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySurveyOpenTextResultVC.h"
#import "GANSurveyOpenTextResultItemTVC.h"
#import "GANSurveyManager.h"

@interface GANCompanySurveyOpenTextResultVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *viewNoResult;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *labelQuestion;

@property (strong, nonatomic) GANSurveyDataModel *modelSurvey;

@end

@implementation GANCompanySurveyOpenTextResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 75;
    
    self.modelSurvey = [[GANSurveyManager sharedInstance].arraySurveys objectAtIndex:self.indexSurvey];
    
    [self registerTableViewCellFromNib];
    
    self.labelQuestion.text = [self.modelSurvey.modelQuestion getTextEN];
    if ([self.modelSurvey.arrayAnswers count] == 0) {
        self.tableview.hidden = YES;
        self.viewNoResult.hidden = NO;
    }
    else {
        self.tableview.hidden = NO;
        self.viewNoResult.hidden = YES;
    }
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"SurveyOpenTextResultItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_SURVEY_OPENTEXTRESULTITEM"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewCell Delegate

- (void) configureCell: (GANSurveyOpenTextResultItemTVC *) cell AtIndex: (int) index{
    GANSurveyAnswerDataModel *answer = [self.modelSurvey.arrayAnswers objectAtIndex:index];
    cell.labelAnswer.text = [answer.modelAnswerText getTextEN];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.modelSurvey.arrayAnswers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANSurveyOpenTextResultItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_SURVEY_OPENTEXTRESULTITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

@end
