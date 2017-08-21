//
//  GANCompanyLoginCodeVC.h
//  Ganaz
//
//  Created by Piric Djordje on 7/11/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@interface GANCompanyLoginCodeVC : UIViewController

@property (strong, nonatomic) NSString *szPhoneNumber;
@property (assign, atomic) BOOL isLogin;
@property (assign, atomic) BOOL isAutoLogin;
@property (atomic, assign) ENUM_COMPANY_SIGNUP_FROM_CUSTOMVC fromCustomVC;

@end
