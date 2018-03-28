//
//  GANCountrySelectorPopupVC.h
//  Ganaz
//
//  Created by Chris Lin on 2/8/18.
//  Copyright © 2018 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANUtils.h"

@protocol GANCountrySelectorPopupDelegate <NSObject>

@optional

- (void) didCountrySelect: (GANENUM_PHONE_COUNTRY) country;

@end

@interface GANCountrySelectorPopupVC : UIViewController

@property (assign, atomic) GANENUM_PHONE_COUNTRY enumCountry;
@property (weak, nonatomic) id<GANCountrySelectorPopupDelegate> delegate;

- (void) refreshFields;

@end
