//
//  GANWorkerLoginCodeVC.h
//  Ganaz
//
//  Created by Piric Djordje on 7/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANUserWorkerDataModel.h"

@interface GANWorkerLoginCodeVC : UIViewController

@property (strong, nonatomic) GANPhoneDataModel *phone;
@property (assign, atomic) BOOL isLogin;
@property (assign, atomic) BOOL isAutoLogin;
@property (assign, atomic) BOOL isOnboardingWorker;
@property (nonatomic, strong) NSString *szId;

@end
