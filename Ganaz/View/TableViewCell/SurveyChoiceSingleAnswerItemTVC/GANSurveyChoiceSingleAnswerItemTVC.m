//
//  GANSurveyChoiceSingleAnswerItemTVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANSurveyChoiceSingleAnswerItemTVC.h"
#import "UIColor+GANColor.h"

@implementation GANSurveyChoiceSingleAnswerItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) refreshViews{
    self.viewContent.backgroundColor = [UIColor clearColor];
    self.viewContent.layer.borderColor = [UIColor GANThemeMainColor].CGColor;
    self.viewContent.layer.borderWidth = 1;
    self.viewContent.layer.cornerRadius = 3;

    if (self.isSelected == YES){
        [self.imageCheck setImage:[UIImage imageNamed:@"icon-checked"]];
    }
    else {
        [self.imageCheck setImage:[UIImage imageNamed:@"icon-unchecked"]];
    }
}

@end
