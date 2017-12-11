//
//  GANCompanyCrewPopupVC.h
//  Ganaz
//
//  Created by Chris Lin on 11/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GANCompanyCrewPopupDelegate <NSObject>

@optional

- (void) companyCrewPopupDidCrewCreate: (int) indexCrew;
- (void) companyCrewPopupCanceled;

@end

@interface GANCompanyCrewPopupVC : UIViewController

@property (weak, nonatomic) id<GANCompanyCrewPopupDelegate> delegate;

@end
