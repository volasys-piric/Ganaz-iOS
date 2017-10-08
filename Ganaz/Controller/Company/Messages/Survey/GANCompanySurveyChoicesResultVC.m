//
//  GANCompanySurveyChoicesResultVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySurveyChoicesResultVC.h"
#import "GANSurveyManager.h"
#import "GANSurveyChoiceSingleResultLegendItemTVC.h"

#import <PNChart.h>
#import "UIColor+GANColor.h"

@interface GANCompanySurveyChoicesResultVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *viewEmptyPanel;

@property (weak, nonatomic) IBOutlet UIView *viewGraph;

@property (weak, nonatomic) IBOutlet UILabel *labelQuestionWithResults;
@property (weak, nonatomic) IBOutlet UILabel *labelQuestionWithNoResults;

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableviewHeight;

@property (strong, nonatomic) NSMutableArray <UIColor *> *arrayColors;
@property (strong, nonatomic) NSMutableArray <NSString *> *arrayChoiceTexts;
@property (strong, nonatomic) NSMutableArray <NSNumber *> *arrayValues;

@property (assign, atomic) BOOL isChartAdded;

@end

@implementation GANCompanySurveyChoicesResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 30;

    self.arrayColors = [[NSMutableArray alloc] init];
    self.arrayChoiceTexts = [[NSMutableArray alloc] init];
    self.arrayValues = [[NSMutableArray alloc] init];
    
    self.isChartAdded = NO;
    
    [self registerTableViewCellFromNib];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerTableViewCellFromNib{
    [self.tableview registerNib:[UINib nibWithNibName:@"SurveyChoiceSingleResultLegendItemTVC" bundle:nil] forCellReuseIdentifier:@"TVC_SURVEY_CHOICESINGLERESULTLEGENDITEM"];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshViews];
}

- (void) refreshViews {
    GANSurveyManager *managerSurvey = [GANSurveyManager sharedInstance];
    GANSurveyDataModel *survey = [managerSurvey.arraySurveys objectAtIndex:self.indexSurvey];
    
    self.labelQuestionWithResults.text = [survey.modelQuestion getTextEN];
    self.labelQuestionWithNoResults.text = [survey.modelQuestion getTextEN];
    
    if ([survey.arrayAnswers count] == 0) {
        self.scrollview.hidden = YES;
        self.viewEmptyPanel.hidden = NO;
    }
    else {
        self.scrollview.hidden = NO;
        self.viewEmptyPanel.hidden = YES;
        
        // Build Arrays
        NSArray *arrayAllColors = @[[UIColor GANSurveyColor1],
                                    [UIColor GANSurveyColor2],
                                    [UIColor GANSurveyColor3],
                                    [UIColor GANSurveyColor4],
                                    ];
        
        
        [self.arrayColors removeAllObjects];
        [self.arrayChoiceTexts removeAllObjects];
        [self.arrayValues removeAllObjects];
        
        for (int i = 0; i < 4; i++) {
            int count = [survey getCountForAnswersWithChoiceIndex:i];
            if (count > 0){
                [self.arrayColors addObject:[arrayAllColors objectAtIndex:i]];
                [self.arrayChoiceTexts addObject:[[survey.arrayChoices objectAtIndex:i] getTextEN]];
                [self.arrayValues addObject:@(count)];
            }
        }
        
        [self.tableview reloadData];
    }
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if (self.isChartAdded == NO && [self.arrayValues count] > 0){
        self.isChartAdded = YES;
        
        [self.viewGraph setNeedsLayout];
        [self.viewGraph layoutIfNeeded];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.arrayValues count]; i++){
            UIColor *color = [self.arrayColors objectAtIndex:i];
            NSString *desc = [self.arrayChoiceTexts objectAtIndex:i];
            [items addObject:[PNPieChartDataItem dataItemWithValue:[[self.arrayValues objectAtIndex:i] intValue] color:color description:desc]];
        }
        
        CGRect rect = self.viewGraph.frame;
        PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) items:items];
        pieChart.descriptionTextColor = [UIColor GANSurveyTextColor];
        pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        pieChart.showOnlyValues = YES;
        pieChart.showAbsoluteValues = YES;
//        pieChart.outlineColor = [UIColor GANSurveyBorderColor];
        pieChart.shouldHighlightSectorOnTouch = NO;
        
        // Override PNPieChart.m > recompute to set innerCircleRadius
        pieChart.innerCircleRadius = 0;
        
        [pieChart strokeChart];
        
        [self.viewGraph addSubview:pieChart];
    }
}

#pragma mark - UITableView Delegate

- (void) configureCell: (GANSurveyChoiceSingleResultLegendItemTVC *) cell AtIndex: (int) index{
    [cell refreshViewsWithFillColor:[self.arrayColors objectAtIndex:index] BorderColor:[UIColor GANSurveyBorderColor] Text:[self.arrayChoiceTexts objectAtIndex:index]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayValues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GANSurveyChoiceSingleResultLegendItemTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"TVC_SURVEY_CHOICESINGLERESULTLEGENDITEM"];
    [self configureCell:cell AtIndex:(int) indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

@end
