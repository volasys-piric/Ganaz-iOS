//
//  GANCompanySurveyOpenTextPostVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/3/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySurveyOpenTextPostVC.h"
#import "GANFadeTransitionDelegate.h"
#import "GANConformMessagePopupVC.h"

#define GANCOMPANYSURVEYCHOICESPOSTVC_TEXTVIEW_PLACEHOLDER      @"Enter question here..."

@interface GANCompanySurveyOpenTextPostVC () <UITextViewDelegate, GANConformMessagePopupVCDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewQuestion;
@property (weak, nonatomic) IBOutlet UITextView *textviewMessage;

@property (weak, nonatomic) IBOutlet UIButton *buttonAutoTranslate;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubmit;

@property (weak, nonatomic) IBOutlet UILabel *labelReceivers;

@property (assign, atomic) BOOL isAutoTranslate;
@property (strong, nonatomic) GANFadeTransitionDelegate *transController;

@end

@implementation GANCompanySurveyOpenTextPostVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isAutoTranslate = NO;
    self.textviewMessage.text = GANCOMPANYSURVEYCHOICESPOSTVC_TEXTVIEW_PLACEHOLDER;
    self.textviewMessage.delegate = self;
    
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
    self.buttonSubmit.layer.cornerRadius = 3;
    
    self.viewQuestion.clipsToBounds = YES;
    self.buttonSubmit.clipsToBounds = YES;
    
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

#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.textviewMessage.text = @"";
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.textviewMessage.text.length == 0) {
        self.textviewMessage.text = GANCOMPANYSURVEYCHOICESPOSTVC_TEXTVIEW_PLACEHOLDER;
    }
}

@end
