//
//  GANCompanyMapPopupVC.h
//  Ganaz
//
//  Created by forever on 9/6/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANLocationManager.h"
#import "GANLocationDataModel.h"

@protocol GANCompanyMapPopupVCDelegate <NSObject>

- (void) submitLocation:(GANLocationDataModel *)location;

@end

@interface GANCompanyMapPopupVC : UIViewController
@property (nonatomic, weak) id<GANCompanyMapPopupVCDelegate> delegate;

@end
