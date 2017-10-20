//
//  GANSurveyTypeChoosePopupVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/5/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANSurveyTypeChoosePopupVC.h"
#import "UIColor+GANColor.h"
#import "Global.h"

@interface GANSurveyTypeChoosePopupVC ()

@property (weak, nonatomic) IBOutlet UIView *viewContents;
@property (weak, nonatomic) IBOutlet UIButton *buttonChoiceSingle;
@property (weak, nonatomic) IBOutlet UIButton *buttonOpenText;


@end

@implementation GANSurveyTypeChoosePopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshViews {
    self.viewContents.clipsToBounds = YES;
    self.viewContents.layer.cornerRadius = 3;
    self.viewContents.layer.borderWidth = 1;
    self.viewContents.layer.borderColor = [UIColor GANThemeMainColor].CGColor;
    
    self.buttonChoiceSingle.layer.cornerRadius       = 3;
    self.buttonChoiceSingle.clipsToBounds            = YES;
    
    self.buttonOpenText.layer.cornerRadius = 3;
    self.buttonOpenText.clipsToBounds = YES;
}

- (void) closeDialog{
    [UIView animateWithDuration:TRANSITION_FADEOUT_DURATION animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - UIButton Event Listeners

- (IBAction)onBtnWrapperClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(surveyTypeChoosePopupDidCancelClick:)] == YES) {
        [self.delegate surveyTypeChoosePopupDidCancelClick:self];
    }
    
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onButtonChoiceSingleClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(surveyTypeChoosePopupDidChoiceSingleClick:)] == YES) {
        [self.delegate surveyTypeChoosePopupDidChoiceSingleClick:self];
    }
    
    [self.view endEditing:YES];
    [self closeDialog];
}

- (IBAction)onButtonOpenTextClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(surveyTypeChoosePopupDidOpenTextClick:)] == YES) {
        [self.delegate surveyTypeChoosePopupDidOpenTextClick:self];
    }
    
    [self.view endEditing:YES];
    [self closeDialog];
}

@end
