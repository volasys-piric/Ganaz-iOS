//
//  GANMessageListItemTVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/29/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMessageListItemTVC.h"
#import "GANUserManager.h"
#import "Global.h"

#import "GANGenericFunctionManager.h"
#import "GANUrlManager.h"
#import "GANUtils.h"

#define UICOLOR_MESSAGEITEM_BLACK                           [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:1]
#define UICOLOR_MESSAGEITEM_WHITE                           [UIColor colorWithRed:(255 / 255.0) green:(255 / 255.0) blue:(255 / 255.0) alpha:1]
#define UICOLOR_MESSAGEITEM_YELLOW                          [UIColor colorWithRed:(250 / 255.0) green:(235 / 255.0) blue:(214 / 255.0) alpha:1]
#define UICOLOR_MESSAGEITEM_GREEN                           [UIColor colorWithRed:(100 / 255.0) green:(179 / 255.0) blue:(31 / 255.0) alpha:1]

@implementation GANMessageListItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) refreshViewsWithType: (GANENUM_MESSAGE_TYPE) type DidRead: (BOOL) didRead DidSend: (BOOL) didSend{
    self.labelAvatar.layer.cornerRadius = 18;
    UIColor *colorMain = (didRead == YES || didSend == YES) ? UICOLOR_MESSAGEITEM_BLACK : UICOLOR_MESSAGEITEM_GREEN;
    BOOL isES = ![[GANUserManager sharedInstance] isCompanyUser];
    
    if (type == GANENUM_MESSAGE_TYPE_MESSAGE ||
        type == GANENUM_MESSAGE_TYPE_APPLICATION ||
        type == GANENUM_MESSAGE_TYPE_SUGGEST){
        if (isES == YES) {
            self.labelAvatar.text = @"MSJ";
        }
        else {
            self.labelAvatar.text = @"MSG";
        }
        self.labelAvatar.backgroundColor = [UIColor clearColor];
        self.labelAvatar.textColor = colorMain;
        self.labelAvatar.layer.borderWidth = 1;
        self.labelAvatar.layer.borderColor = colorMain.CGColor;
    }
    else if (type == GANENUM_MESSAGE_TYPE_RECRUIT) {
        if (isES == YES) {
            self.labelAvatar.text = @"TRA";
        }
        else {
            self.labelAvatar.text = @"JOB";
        }
        self.labelAvatar.backgroundColor = colorMain;
        self.labelAvatar.textColor = UICOLOR_MESSAGEITEM_WHITE;
        self.labelAvatar.layer.borderWidth = 0;
    }
    else if (type == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE ||
             type == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT ||
             type == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) {
        
        if (isES == YES) {
            self.labelAvatar.text = @"ENC";
        }
        else {
            self.labelAvatar.text = @"SUR";
        }
        self.labelAvatar.backgroundColor = colorMain;
        self.labelAvatar.textColor = UICOLOR_MESSAGEITEM_WHITE;
        self.labelAvatar.layer.borderWidth = 0;
    }
}

@end
