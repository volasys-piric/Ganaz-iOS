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
    
    self.viewMap.layer.cornerRadius = 3.f;
    self.viewMap.clipsToBounds = YES;
    
    self.viewMap.layer.borderColor = GANUICOLOR_THEMECOLOR_MAIN.CGColor;
    self.viewMap.layer.borderWidth = 1.f;
    
    if(self.locationCenter != nil) {
        [self buildMapView];
        self.viewMap.hidden = NO;
    } else {
        self.viewMap.hidden = YES;
    }
}

#pragma mark - GoogleMaps

- (void) buildMapView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationCenter.coordinate.latitude
                                                                longitude:self.locationCenter.coordinate.longitude
                                                                     zoom:15];
        
        CGRect rcMapView = self.viewMap.frame;
        self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, rcMapView.size.width, rcMapView.size.height) camera:camera];
        self.mapView.myLocationEnabled = NO;
        
        UIImage *imgPin = [UIImage imageNamed:@"map_pin-green"];
        
        GMSMarker *marker = [GMSMarker markerWithPosition:self.locationCenter.coordinate];
        marker.infoWindowAnchor = CGPointMake(0.5, 0);
        marker.map = self.mapView;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = imgPin;
        marker.groundAnchor = CGPointMake(0.5, 1);
        
        self.mapView.delegate = self;
        [self.viewMap addSubview:self.mapView];
    });
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    self.locationCenter = [[CLLocation alloc]initWithLatitude:position.target.latitude longitude:position.target.longitude];
}

@end
