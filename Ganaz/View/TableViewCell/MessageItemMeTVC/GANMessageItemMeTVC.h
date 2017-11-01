//
//  GANMessageItemMeTVC.h
//  Ganaz
//
//  Created by Chris Lin on 10/31/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GANMessageItemMeTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTimestamp;
@property (weak, nonatomic) IBOutlet UILabel *labelBackground;
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imageMap;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageMapHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageMapBottomSpacing;

@property (strong, nonatomic) CLLocation *locationMap;

- (void) showMapWithLatitude: (float) latitude Longitude: (float) longitude;
- (void) hideMap;

@end
