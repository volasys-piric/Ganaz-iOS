//
//  GANMessageItemTVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMessageItemTVC.h"
#import "Global.h"

#define UICOLOR_MESSAGEITEM_BLACK                           [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:1]
#define UICOLOR_MESSAGEITEM_WHITE                           [UIColor colorWithRed:(255 / 255.0) green:(255 / 255.0) blue:(255 / 255.0) alpha:1]
#define UICOLOR_MESSAGEITEM_YELLOW                          [UIColor colorWithRed:(250 / 255.0) green:(235 / 255.0) blue:(214 / 255.0) alpha:1]
#define UICOLOR_MESSAGEITEM_GREEN                           [UIColor colorWithRed:(100 / 255.0) green:(179 / 255.0) blue:(31 / 255.0) alpha:1]

@implementation GANMessageItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) refreshViewsWithType: (GANENUM_MESSAGE_TYPE) type DidRead: (BOOL) didRead DidSend: (BOOL) didSend{
    self.lblAvatar.layer.cornerRadius = 18;
    if (type == GANENUM_MESSAGE_TYPE_MESSAGE){
        self.lblAvatar.text = @"MSG";
        self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_BLACK;
        self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_WHITE;
    }
    else if (type == GANENUM_MESSAGE_TYPE_RECRUIT) {
        self.lblAvatar.text = @"JOB";
        self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_YELLOW;
        self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_BLACK;
    }
    
    else if (type == GANENUM_MESSAGE_TYPE_APPLICATION) {
        self.lblAvatar.text = @"APP";
        self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_YELLOW;
        self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_BLACK;
    }
    
    if (didRead == NO){
        self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_GREEN;
        self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_WHITE;
    }
    
    if (didSend == YES){
        [self.imgIndicator setImage:[UIImage imageNamed:@"icon-message-sent"]];
    }
    else {
        [self.imgIndicator setImage:[UIImage imageNamed:@"icon-message-received"]];
    }
}

@end
