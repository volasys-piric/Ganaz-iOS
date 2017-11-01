//
//  GANMessageItemYouTVC.h
//  Ganaz
//
//  Created by Chris Lin on 10/31/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GANMessageItemYouTVC : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTimestamp;
@property (weak, nonatomic) IBOutlet UILabel *labelBackground;
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imageMap;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageMapHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageMapBottomSpacing;

/*
 This "index" is mainly used in Worker > MessageThreadVC, where cell contents are updated by async call to server (to get company details, job details, etc).
 When updating in the return of async call, the celll might have been already initiated for another message item, which means, it might overwrite with old data.
 
 Please check GANWorkerMessageThreadVC.m > configureCell methods...
 */
@property (assign, atomic) int index;
@property (strong, nonatomic) CLLocation *locationMap;

- (void) showMapWithLatitude: (float) latitude Longitude: (float) longitude;
- (void) hideMap;

@end
