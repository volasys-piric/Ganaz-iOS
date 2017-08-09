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
    
    self.btnAdd.layer.cornerRadius = 3.f;
    self.btnAdd.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onAdd:(id)sender {
    [self.delegate onAddWorker:self.nIndex];
}

@end
