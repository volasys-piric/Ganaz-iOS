//
//  GANCompanyCrewItemTVC.m
//  Ganaz
//
//  Created by Chris Lin on 11/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyCrewItemTVC.h"
#import "UIColor+GANColor.h"

@implementation GANCompanyCrewItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.viewContainer.layer.cornerRadius = 4;
    self.viewContainer.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setItemGreenDot: (BOOL) greenDot {
    if (greenDot == YES) {
        self.labelDots.textColor = [UIColor GANThemeGreenColor];
    }
    else {
        self.labelDots.textColor = [UIColor grayColor];
    }
}

- (void) setItemSelected: (BOOL) selected {
    self.isSelected = selected;
    if (selected == YES) {
        self.labelName.textColor = [UIColor GANThemeMainColor];
    }
    else {
        self.labelName.textColor = [UIColor lightGrayColor];
    }
}

- (IBAction)onButtonDotClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(companyCrewItemCellDidDotClick:)] == YES) {
        [self.delegate companyCrewItemCellDidDotClick:self];
    }
}

@end
