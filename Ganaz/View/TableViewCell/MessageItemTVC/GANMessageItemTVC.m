//
//  GANMessageItemTVC.m
//  Ganaz
//
//  Created by forever on 9/8/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMessageItemTVC.h"
#import "Global.h"

#import "GANGenericFunctionManager.h"
#import "GANUrlManager.h"
#import "GANUtils.h"

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
        self.lblAvatar.text = @"";  // MSG
        self.lblAvatar.backgroundColor = [UIColor clearColor];
        self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_WHITE;
        self.imgAvatar.hidden = NO;
        if (didRead == YES){
            if (didSend == YES){
                [self.imgAvatar setImage:[UIImage imageNamed:@"icon-message-black-sent"]];
            }
            else {
                [self.imgAvatar setImage:[UIImage imageNamed:@"icon-message-black-received"]];
            }
        }
        else {
            if (didSend == YES){
                [self.imgAvatar setImage:[UIImage imageNamed:@"icon-message-green-sent"]];
            }
            else {
                [self.imgAvatar setImage:[UIImage imageNamed:@"icon-message-green-received"]];
            }
        }
    }
    else if (type == GANENUM_MESSAGE_TYPE_RECRUIT) {
        self.lblAvatar.text = @"JOB";
        self.imgAvatar.hidden = YES;
        if (didRead == YES){
            self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_YELLOW;
            self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_BLACK;
        }
        else {
            self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_GREEN;
            self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_WHITE;
        }
    }
    else if (type == GANENUM_MESSAGE_TYPE_APPLICATION) {
        self.lblAvatar.text = @"APP";
        self.imgAvatar.hidden = YES;
        if (didRead == YES){
            self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_YELLOW;
            self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_BLACK;
        }
        else {
            self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_GREEN;
            self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_WHITE;
        }
    }
    else if (type == GANENUM_MESSAGE_TYPE_SUGGEST) {
        self.lblAvatar.text = @"SGG";
        self.imgAvatar.hidden = YES;
        if (didRead == YES){
            self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_YELLOW;
            self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_BLACK;
        }
        else {
            self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_GREEN;
            self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_WHITE;
        }
    }
    else if (type == GANENUM_MESSAGE_TYPE_SURVEY_CHOICESINGLE ||
             type == GANENUM_MESSAGE_TYPE_SURVEY_OPENTEXT ||
             type == GANENUM_MESSAGE_TYPE_SURVEY_ANSWER) {
        self.lblAvatar.text = @"SUR";
        self.imgAvatar.hidden = YES;
        if (didRead == YES){
            self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_YELLOW;
            self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_BLACK;
        }
        else {
            self.lblAvatar.backgroundColor = UICOLOR_MESSAGEITEM_GREEN;
            self.lblAvatar.textColor = UICOLOR_MESSAGEITEM_WHITE;
        }
    }
    
    self.imgMap.layer.cornerRadius = 3.f;
    self.imgMap.clipsToBounds = YES;
    
    self.imgMap.layer.borderColor = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    self.imgMap.layer.borderWidth = 1.f;
    
    if(self.locationCenter != nil) {
        [self buildMapView];
        self.imgMap.hidden = NO;
        self.constraintMapHeight.constant = 200;
        [self.contentView layoutIfNeeded];
    }
    else {
        self.imgMap.hidden = YES;
        self.constraintMapHeight.constant = 0;
        [self.contentView layoutIfNeeded];
    }
    
    self.lblMessage.enabledTextCheckingTypes = NSTextCheckingTypePhoneNumber;
}

#pragma mark - GoogleMaps

- (void) buildMapView {

    [GANUtils syncImageWithUrl:self.imgMap latitude:self.locationCenter.coordinate.latitude longitude:self.locationCenter.coordinate.longitude];
    
}

- (IBAction)gotoMapApplication:(id)sender {
    
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps:"]]) {
        NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?q=%f,%f",self.locationCenter.coordinate.latitude,self.locationCenter.coordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    } else {
        NSString *string = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f",self.locationCenter.coordinate.latitude,self.locationCenter.coordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
    }
    /*NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",self.locationCenter.coordinate.latitude, self.locationCenter.coordinate.longitude, self.locationCenter.coordinate.latitude, self.locationCenter.coordinate.longitude];*/

}

@end
