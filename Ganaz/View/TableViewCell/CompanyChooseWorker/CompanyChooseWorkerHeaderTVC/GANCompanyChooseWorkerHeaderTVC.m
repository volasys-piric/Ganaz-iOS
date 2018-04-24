//
//  GANCompanyChooseWorkerHeaderTVC.m
//  Ganaz
//
//  Created by Chris Lin on 4/20/18.
//  Copyright © 2018 Ganaz. All rights reserved.
//

#import "GANCompanyChooseWorkerHeaderTVC.h"
#import "UIColor+GANColor.h"

@interface GANCompanyChooseWorkerHeaderTVC ()

@property (weak, nonatomic) IBOutlet UIView *viewSearch;

@property (weak, nonatomic) IBOutlet UIButton *buttonAddWorker;
@property (weak, nonatomic) IBOutlet UIButton *buttonSelectAll;
@property (weak, nonatomic) IBOutlet UITextField *textfieldSearch;

@end

@implementation GANCompanyChooseWorkerHeaderTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self refreshViews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) refreshViews {
    self.viewSearch.layer.borderColor = [UIColor GANThemeGreenColor].CGColor;
    self.viewSearch.layer.borderWidth = 1;
    self.viewSearch.layer.cornerRadius = 10;
    self.viewSearch.clipsToBounds = YES;
    
    self.buttonAddWorker.layer.cornerRadius = 3;
    self.buttonAddWorker.clipsToBounds = YES;
    self.buttonSelectAll.layer.cornerRadius = 3;
    self.buttonSelectAll.clipsToBounds = YES;
    
    self.buttonAddWorker.backgroundColor = [UIColor GANThemeGreenColor];
}

- (void) refreshSelectAllButton: (BOOL) show SelectedAll: (BOOL) selectedAll {
    self.buttonSelectAll.hidden = !show;
    if (selectedAll == YES) {
        [self.buttonSelectAll setTitle:@"Deselect\rworkers" forState:UIControlStateNormal];
        self.buttonSelectAll.backgroundColor = [UIColor GANThemeMainColor];
    }
    else {
        [self.buttonSelectAll setTitle:@"Select all\rworkers" forState:UIControlStateNormal];
        self.buttonSelectAll.backgroundColor = [UIColor GANThemeGreenColor];
    }
}

- (IBAction)onButtonAddWorkerClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didAddWorkerClick)] == YES) {
        [self.delegate didAddWorkerClick];
    }
}

- (IBAction)onButtonSelectAllClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectAllClick)] == YES) {
        [self.delegate didSelectAllClick];
    }
}

- (IBAction)onTextfieldSearchChanged:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTextfieldSearchChange:)] == YES) {
        [self.delegate didTextfieldSearchChange:self.textfieldSearch.text];
    }
}

- (float) getPreferredHeight {
    return 132;
}

@end
