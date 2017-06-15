//
//  GANWorkerJobsListFilterVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/24/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerJobsListFilterVC.h"
#import "GANGenericFunctionManager.h"
#import "GANUserManager.h"
#import "Global.h"
#import "GANAppManager.h"

@interface GANWorkerJobsListFilterVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPopupWrapper;
@property (weak, nonatomic) IBOutlet UIView *viewDistance;
@property (weak, nonatomic) IBOutlet UIView *viewDate;
@property (weak, nonatomic) IBOutlet UITextField *txtDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;

@property (weak, nonatomic) IBOutlet UIButton *btnFilter;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPopupPanelBottomSpace;

@property (assign, atomic) BOOL isPopupShowing;

@end

@implementation GANWorkerJobsListFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isPopupShowing = NO;
    
    [self refreshViews];
    [self refreshDateFields];
    
    if (self.fDistance > 0){
        self.txtDistance.text = [NSString stringWithFormat:@"%d", (int) self.fDistance];
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews{
    self.viewDistance.layer.cornerRadius = 3;
    self.viewDate.layer.cornerRadius = 3;
    self.btnFilter.layer.cornerRadius = 3;
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES){
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self refreshPopupView];
}

- (void) refreshPopupView{
    self.viewPopupWrapper.hidden = !self.isPopupShowing;
}

- (void) refreshDateFields{
    if (self.dateFrom == nil){
        self.lblDate.text = @"";
    }
    else {
        self.lblDate.text = [GANGenericFunctionManager getBeautifiedSpanishDate:self.dateFrom];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UI Stuff

- (void) animateToShowPopup{
    if (self.isPopupShowing == YES) return;
    self.isPopupShowing = YES;
    
    // Animate to show
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewPopupWrapper.hidden = NO;
        self.viewPopupWrapper.alpha = 0;
        self.constraintPopupPanelBottomSpace.constant = -220;
        [self.viewPopupWrapper layoutIfNeeded];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.constraintPopupPanelBottomSpace.constant = 0;
            self.viewPopupWrapper.alpha = 1;
            [self.viewPopupWrapper layoutIfNeeded];
        }];
    });
}

- (void) animateToHidePopup{
    if (self.isPopupShowing == NO) return;
    
    self.isPopupShowing = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.constraintPopupPanelBottomSpace.constant = 0;
        self.viewPopupWrapper.alpha = 1;
        [self.viewPopupWrapper layoutIfNeeded];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.constraintPopupPanelBottomSpace.constant = -220;
           self.viewPopupWrapper.alpha = 0;
            [self.viewPopupWrapper layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (finished == YES){
                self.viewPopupWrapper.hidden = YES;
            }
        }];
    });
}

#pragma mark - UIButton Delegate

- (IBAction)onBtnDateClick:(id)sender {
    [self.view endEditing:YES];
    [self animateToShowPopup];
}

- (IBAction)onBtnFilterClick:(id)sender {
    [self.view endEditing:YES];
    
    if (self.dateFrom == nil){
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_WORKER_JOBSEARCH_FILTER_UPDATED object:nil userInfo:@{@"distance": self.txtDistance.text}];

    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_WORKER_JOBSEARCH_FILTER_UPDATED object:nil userInfo:@{@"distance": self.txtDistance.text,
                                                                                                                                              @"date_from": self.dateFrom}];
    }
    [self.navigationController popViewControllerAnimated:YES];
    GANACTIVITY_REPORT(@"Worker - Filter job");
}

- (IBAction)onBtnClearDateClick:(id)sender {
    self.dateFrom = nil;
    [self refreshDateFields];
}

- (IBAction)onBtnPopupWrapperClick:(id)sender {
    [self.view endEditing:YES];
    [self animateToHidePopup];
}

- (IBAction)onDatePickerChanged:(id)sender {
    self.dateFrom = self.datePicker.date;
    [self refreshDateFields];
}

- (IBAction)onBtnLoginClick:(id)sender {
    [self.view endEditing:YES];
    
    if ([[GANUserManager sharedInstance] isUserLoggedIn] == NO){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"STORYBOARD_LOGIN"];
        [self.navigationController pushViewController:vc animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        return;
    }
}

@end
