//
//  GANWorkerItemTVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANWorkerItemTVC.h"
#import "Global.h"

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
        self.lblWorkerId.textColor = UICOLOR_WORKERITEM_TITLE_SELECTED;
//        self.btnEdit.titleLabel.textColor = UICOLOR_WORKERITEM_TITLE_SELECTED;
    }
    else {
        self.lblWorkerId.textColor = UICOLOR_WORKERITEM_TITLE_NOTSELECTED;
//        self.btnEdit.titleLabel.textColor = UICOLOR_WORKERITEM_TITLE_NOTSELECTED;
    }

}

- (void) setButtonColor:(BOOL) isWorker {
    if(isWorker == YES)
    {
        self.lblPoint.textColor = GANUICOLOR_THEMECOLOR_GREEN;
    } else {
        self.lblPoint.textColor = UICOLOR_WORKERITEM_TITLE_NOTSELECTED;
    }
}

- (IBAction)onEdit:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(workerItemTableViewCellDidDotsClick:)]) {
        [self.delegate workerItemTableViewCellDidDotsClick:self];
    }
}

@end
