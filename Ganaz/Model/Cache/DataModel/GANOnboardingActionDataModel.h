//
//  GANOnboardingActionDataModel.h
//  Ganaz
//
//  Created by Chris Lin on 12/13/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANUtils.h"

@interface GANOnboardingActionDataModel : NSObject

@property (assign, atomic) GANENUM_ONBOARDINGACTION_LOGINFROM enumLoginFrom;
@property (strong, nonatomic) NSString *szJobId;
@property (strong, nonatomic) NSString *szCompanyId;
@property (strong, nonatomic) NSString *szSugestPhoneNumber;

- (instancetype) init;

- (BOOL) isOnboardingActionForWorker;
- (void) postNotificationToContinueOnboardingAction;

@end
