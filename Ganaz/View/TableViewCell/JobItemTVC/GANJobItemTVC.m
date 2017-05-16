//
//  GANJobItemTVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/21/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobItemTVC.h"

#define UICOLOR_JOBITEM_BACKGROUND_NOTSELECTED                  [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:0.07]
#define UICOLOR_JOBITEM_TITLE_NOTSELECTED                       [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:1]
#define UICOLOR_JOBITEM_DATE_NOTSELECTED                        [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:0.6]

#define UICOLOR_JOBITEM_BACKGROUND_SELECTED                     [UIColor colorWithRed:(100 / 255.0) green:(179 / 255.0) blue:(31 / 255.0) alpha:1]
#define UICOLOR_JOBITEM_TITLE_SELECTED                          [UIColor colorWithRed:(255 / 255.0) green:(255 / 255.0) blue:(255 / 255.0) alpha:1]
#define UICOLOR_JOBITEM_DATE_SELECTED                           [UIColor colorWithRed:(255 / 255.0) green:(255 / 255.0) blue:(255 / 255.0) alpha:0.6]

@implementation GANJobItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) showPayRate: (BOOL) show{
    self.lblPrice.hidden = !show;
    self.lblUnit.hidden = !show;
    self.lblPriceNA.hidden = show;
}

- (void) setItemSelected: (BOOL) selected{
    if (selected == YES){
        self.viewContainer.layer.backgroundColor = UICOLOR_JOBITEM_BACKGROUND_SELECTED.CGColor;
        self.lblTitle.textColor = UICOLOR_JOBITEM_TITLE_SELECTED;
        self.lblPrice.textColor = UICOLOR_JOBITEM_TITLE_SELECTED;
        self.lblDate.textColor = UICOLOR_JOBITEM_DATE_SELECTED;
        self.lblUnit.textColor = UICOLOR_JOBITEM_DATE_SELECTED;
        self.lblPriceNA.textColor = UICOLOR_JOBITEM_TITLE_SELECTED;
    }
    else {
        self.viewContainer.layer.backgroundColor = UICOLOR_JOBITEM_BACKGROUND_NOTSELECTED.CGColor;
        self.lblTitle.textColor = UICOLOR_JOBITEM_TITLE_NOTSELECTED;
        self.lblPrice.textColor = UICOLOR_JOBITEM_TITLE_NOTSELECTED;
        self.lblDate.textColor = UICOLOR_JOBITEM_DATE_NOTSELECTED;
        self.lblUnit.textColor = UICOLOR_JOBITEM_DATE_NOTSELECTED;
        self.lblPriceNA.textColor = UICOLOR_JOBITEM_DATE_NOTSELECTED;
    }
}

@end
