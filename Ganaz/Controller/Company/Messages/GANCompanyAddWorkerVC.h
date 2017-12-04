//
//  GANCompanyAddWorkerVC.h
//  Ganaz
//
//  Created by Piric Djordje on 2/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@interface GANCompanyAddWorkerVC : UIViewController

@property (atomic, assign) ENUM_COMPANY_ADDWORKERS_FROM_CUSTOMVC fromCustomVC;
@property (strong, nonatomic) NSString *szDescription;
@property (strong, nonatomic) NSString *szCrewId;

@end
