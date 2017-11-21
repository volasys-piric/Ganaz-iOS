//
//  GANMessageItemYouTVC.m
//  Ganaz
//
//  Created by Chris Lin on 10/31/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMessageItemYouTVC.h"
#import "UIColor+GANColor.h"
#import "GANUtils.h"

@implementation GANMessageItemYouTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self refreshViews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) refreshViews{
    self.labelBackground.layer.cornerRadius = 5;
    self.labelBackground.clipsToBounds = YES;
    self.imageMap.layer.cornerRadius = 3;
    self.imageMap.layer.borderWidth = 1;
    self.imageMap.layer.borderColor = [UIColor GANThemeMainColor].CGColor;
    self.imageMap.clipsToBounds = YES;
}

- (void) showMapWithLatitude: (float) latitude Longitude: (float) longitude {
    self.constraintImageMapHeight.constant = self.imageMap.frame.size.width * 0.75;
    self.constraintImageMapBottomSpacing.constant = 8;
    
    [GANUtils syncImageWithUrl:self.imageMap latitude:latitude longitude:longitude];
    self.locationMap = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
}

- (void) hideMap {
    self.constraintImageMapHeight.constant = 0;
    self.constraintImageMapBottomSpacing.constant = 0;
    self.locationMap = nil;
}

- (IBAction)onButtonMapClick:(id)sender {
    if (self.locationMap == nil) return;
    
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps:"]]) {
        NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?q=%f,%f",self.locationMap.coordinate.latitude,self.locationMap.coordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    } else {
        NSString *string = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f",self.locationMap.coordinate.latitude,self.locationMap.coordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
    }
}

@end
