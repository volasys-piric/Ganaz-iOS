//
//  GANMessageItemTVC.m
//  Ganaz
//
//  Created by Piric Djordje on 2/22/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMessageItemTVC.h"
#import "Global.h"

@implementation GANMessageItemTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) refreshViewsWithType: (GANENUM_MESSAGE_TYPE) type DidRead: (BOOL) didRead{
    self.lblAvatar.layer.cornerRadius = 18;
    if (type == GANENUM_MESSAGE_TYPE_MESSAGE) self.lblAvatar.text = @"MSG";
    if (type == GANENUM_MESSAGE_TYPE_RECRUIT) self.lblAvatar.text = @"JOB";
    if (type == GANENUM_MESSAGE_TYPE_APPLICATION) self.lblAvatar.text = @"APP";
    
    if (didRead == NO){
        self.lblAvatar.backgroundColor = GANUICOLOR_THEMECOLOR_GREEN;
    }
    else {
        self.lblAvatar.backgroundColor = GANUICOLOR_THEMECOLOR_MAIN;
    }
}

@end
