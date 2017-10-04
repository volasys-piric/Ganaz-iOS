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

@interface GANCompanySurveyChoicesPostVC () <UITextFieldDelegate, GANConformMessagePopupVCDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewQuestion;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer1;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer2;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer3;
@property (weak, nonatomic) IBOutlet UIView *viewAnswer4;

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

#pragma mark - UIButton Event Listeners

- (IBAction)onButtonAutoTranslateClick:(id)sender {
    [self.view endEditing:YES];
    self.isAutoTranslate = !self.isAutoTranslate;
    [self refreshAutoTranslateView];
}

- (IBAction)onButtonSubmitClick:(id)sender {
    [self.view endEditing:YES];
}

@end
