//
//  GANCompanySurveyChoicesResultVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySurveyChoicesResultVC.h"
#import <PNChart.h>
#import "UIColor+GANColor.h"

@interface GANCompanySurveyChoicesResultVC ()

@property (weak, nonatomic) IBOutlet UIView *viewGraph;

@property (weak, nonatomic) IBOutlet UILabel *labelDot1;
@property (weak, nonatomic) IBOutlet UILabel *labelDot2;
@property (weak, nonatomic) IBOutlet UILabel *labelDot3;
@property (weak, nonatomic) IBOutlet UILabel *labelDot4;

@property (weak, nonatomic) IBOutlet UILabel *labelChoice1;
@property (weak, nonatomic) IBOutlet UILabel *labelChoice2;
@property (weak, nonatomic) IBOutlet UILabel *labelChoice3;
@property (weak, nonatomic) IBOutlet UILabel *labelChoice4;

@property (weak, nonatomic) IBOutlet UILabel *labelQuestion;

@property (strong, nonatomic) NSArray <UIColor *> *arrayColors;
@property (strong, nonatomic) NSArray <NSString *> *arrayChoices;
@property (strong, nonatomic) NSArray <NSNumber *> *arrayValues;

@property (assign, atomic) BOOL isChartAdded;

@end

@implementation GANCompanySurveyChoicesResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arrayColors = @[[UIColor GANSurveyColor1],
                         [UIColor GANSurveyColor2],
                         [UIColor GANSurveyColor3],
                         [UIColor GANSurveyColor4],
                         ];
    self.arrayChoices = @[@"Very likely",
                          @"Somewhat likely",
                          @"Neutral",
                          @"Not likely",
                          ];
    self.arrayValues = @[@(10),
                         @(12),
                         @(3),
                         @(23)
                         ];
    
    self.isChartAdded = NO;
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews {
    self.labelDot1.layer.borderWidth = 1;
    self.labelDot1.layer.borderColor = [UIColor GANSurveyBorderColor].CGColor;
    self.labelDot1.backgroundColor = [UIColor GANSurveyColor1];
    
    self.labelDot2.layer.borderWidth = 1;
    self.labelDot2.layer.borderColor = [UIColor GANSurveyBorderColor].CGColor;
    self.labelDot2.backgroundColor = [UIColor GANSurveyColor2];
    
    self.labelDot3.layer.borderWidth = 1;
    self.labelDot3.layer.borderColor = [UIColor GANSurveyBorderColor].CGColor;
    self.labelDot3.backgroundColor = [UIColor GANSurveyColor3];
    
    self.labelDot4.layer.borderWidth = 1;
    self.labelDot4.layer.borderColor = [UIColor GANSurveyBorderColor].CGColor;
    self.labelDot4.backgroundColor = [UIColor GANSurveyColor4];
    
    
}

- (void) viewDidLayoutSubviews{
    if (self.isChartAdded == NO){
        self.isChartAdded = YES;
        
        [self.viewGraph setNeedsLayout];
        [self.viewGraph layoutIfNeeded];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i++){
            UIColor *color = [self.arrayColors objectAtIndex:i];
            NSString *desc = [self.arrayChoices objectAtIndex:i];
            [items addObject:[PNPieChartDataItem dataItemWithValue:[[self.arrayValues objectAtIndex:i] intValue] color:color description:desc]];
        }
        
        CGRect rect = self.viewGraph.frame;
        PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height) items:items];
        pieChart.descriptionTextColor = [UIColor GANSurveyTextColor];
        pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        pieChart.showOnlyValues = YES;
        pieChart.showAbsoluteValues = YES;
        pieChart.outlineColor = [UIColor GANSurveyBorderColor];
        pieChart.shouldHighlightSectorOnTouch = NO;
        
        // Override PNPieChart.m > recompute to set innerCircleRadius
        pieChart.innerCircleRadius = 0;
        
        [pieChart strokeChart];
        
        [self.viewGraph addSubview:pieChart];
    }
}

@end
