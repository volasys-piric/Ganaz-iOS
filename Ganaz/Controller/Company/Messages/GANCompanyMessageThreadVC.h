//
//  GANCompanyMessageThreadVC.h
//  Ganaz
//
//  Created by Chris Lin on 10/31/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANMessageDataModel.h"

@interface GANCompanyMessageThreadVC : UIViewController

@property (assign, atomic) int indexThread;     // indexThread = -1 if it's new
@property (strong, nonatomic) NSMutableArray <GANUserRefDataModel *> *arrayReceivers;       // referenced from outside only when indexThread = -1
@property (assign, atomic) BOOL isFacebookLeadWorker;

@end
