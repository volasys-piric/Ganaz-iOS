//
//  GANWorkerLoginCodeVC.h
//  Ganaz
//
//  Created by Piric Djordje on 7/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GANWorkerLoginCodeVC : UIViewController

@property (strong, nonatomic) NSString *szPhoneNumber;
@property (assign, atomic) BOOL isLogin;
@property (assign, atomic) BOOL isAutoLogin;

@end
