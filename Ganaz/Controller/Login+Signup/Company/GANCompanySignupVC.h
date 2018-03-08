//
//  GANCompanySignupVC.h
//  Ganaz
//
//  Created by Piric Djordje on 7/11/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANUtils.h"

@interface GANCompanySignupVC : UIViewController

@property (strong, nonatomic) GANPhoneDataModel *phone;
@property (atomic, assign) ENUM_COMPANY_SIGNUP_FROM_CUSTOMVC fromCustomVC;

@end
