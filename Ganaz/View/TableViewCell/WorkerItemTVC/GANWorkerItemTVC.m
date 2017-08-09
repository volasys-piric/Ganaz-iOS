//
//  GANWorkerItemTVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerItemTVC.h"

#define UICOLOR_WORKERITEM_BACKGROUND_NOTSELECTED               [UIColor lightGrayColor]//[UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:1]
#define UICOLOR_WORKERITEM_TITLE_NOTSELECTED                    [UIColor lightGrayColor]//[UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:1]

#define UICOLOR_WORKERITEM_BACKGROUND_SELECTED                  [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:1]
#define UICOLOR_WORKERITEM_TITLE_SELECTED                       [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:1]


@implementation GANWorkerItemTVC

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
//        self.viewContainer.layer.backgroundColor = UICOLOR_WORKERITEM_BACKGROUND_SELECTED.CGColor;
        self.lblWorkerId.textColor = UICOLOR_WORKERITEM_TITLE_SELECTED;
        self.lblCircle.backgroundColor = UICOLOR_WORKERITEM_TITLE_SELECTED;
    }
    else {
//        self.viewContainer.layer.backgroundColor = UICOLOR_WORKERITEM_BACKGROUND_NOTSELECTED.CGColor;
        self.lblWorkerId.textColor = UICOLOR_WORKERITEM_TITLE_NOTSELECTED;
        self.lblCircle.backgroundColor = UICOLOR_WORKERITEM_TITLE_NOTSELECTED;
    }
    self.lblCircle.layer.cornerRadius = 3;
    self.lblCircle.clipsToBounds = YES;
}

@end
