//
//  GANCompanyUserItemTVC.m
//  Ganaz
//
//  Created by Chris Lin on 6/2/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyUserItemTVC.h"

#define UICOLOR_WORKERITEM_TITLE_NOTSELECTED                    [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:0.3]
#define UICOLOR_WORKERITEM_TITLE_SELECTED                       [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:1]


@implementation GANCompanyUserItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void) setItemSelected: (BOOL) selected{
    if (selected == YES){
        self.lblName.textColor = UICOLOR_WORKERITEM_TITLE_SELECTED;
        self.lblCircle.backgroundColor = UICOLOR_WORKERITEM_TITLE_SELECTED;
    }
    else {
        self.lblName.textColor = UICOLOR_WORKERITEM_TITLE_NOTSELECTED;
        self.lblCircle.backgroundColor = UICOLOR_WORKERITEM_TITLE_NOTSELECTED;
    }
    self.lblCircle.layer.cornerRadius = 3;
    self.lblCircle.clipsToBounds = YES;
}

@end
