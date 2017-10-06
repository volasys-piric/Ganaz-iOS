//
//  GANSurveyChoiceSingleResultLegendItemTVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/7/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANSurveyChoiceSingleResultLegendItemTVC.h"

@implementation GANSurveyChoiceSingleResultLegendItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) refreshViewsWithFillColor: (UIColor *) colorFill BorderColor: (UIColor *) colorBorder Text: (NSString *) text{
    self.labelDot.backgroundColor = colorFill;
    self.labelDot.layer.borderColor = colorBorder.CGColor;
    self.labelDot.layer.borderWidth = 1;
    self.labelAnswer.text = text;
}

@end
