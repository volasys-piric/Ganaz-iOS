//
//  GANCompanyChooseWorkerGroupHeaderTVC.m
//  Ganaz
//
//  Created by Chris Lin on 4/20/18.
//  Copyright © 2018 Ganaz. All rights reserved.
//

#import "GANCompanyChooseWorkerGroupHeaderTVC.h"

@interface GANCompanyChooseWorkerGroupHeaderTVC ()

@property (weak, nonatomic) IBOutlet UIButton *buttonAddCrew;

@end

@implementation GANCompanyChooseWorkerGroupHeaderTVC

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
    self.buttonAddCrew.layer.cornerRadius = 3;
    self.buttonAddCrew.clipsToBounds = YES;
}

- (IBAction)onButtonAddCrewClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didAddGroupClick)] == YES) {
        [self.delegate didAddGroupClick];
    }
}

- (float) getPreferredHeight {
    return 80;
}

@end
