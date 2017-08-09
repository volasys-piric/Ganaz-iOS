//
//  GANCompanySuggestWorkersItemTVC.m
//  Ganaz
//
//  Created by forever on 8/1/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanySuggestWorkersItemTVC.h"

@implementation GANCompanySuggestWorkersItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btnShare.layer.cornerRadius = 3.f;
    self.btnShare.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onShare:(id)sender {
    [self.delegate onWorkersShare:self.nIndex];
}

@end
