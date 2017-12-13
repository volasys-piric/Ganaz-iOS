//
//  GANSharePostingWithContactsVC.h
//  Ganaz
//
//  Created by forever on 7/31/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANUtils.h"

@interface GANSharePostingWithContactsVC : UIViewController

@property (strong, nonatomic) NSString *szJobId;
@property (atomic, assign) ENUM_COMPANY_SHAREPOSTINGWITHCONTACT_FROM_CUSTOMVC fromVC;

@end
