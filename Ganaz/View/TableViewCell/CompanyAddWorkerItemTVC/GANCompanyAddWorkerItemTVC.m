//
//  GANCompanyAddWorkerItemTVC.m
//  Ganaz
//
//  Created by forever on 8/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyAddWorkerItemTVC.h"

@implementation GANCompanyAddWorkerItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.containerView.layer.cornerRadius = 4;
    self.buttonAdd.layer.cornerRadius = 3;
    self.buttonAdd.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onButtonAddClick:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(companyAddWorkerTableViewCellDidAddClick:)]) {
        [self.delegate companyAddWorkerTableViewCellDidAddClick:self];
    }
}

@end
