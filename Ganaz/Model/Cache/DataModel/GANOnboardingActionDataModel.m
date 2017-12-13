//
//  GANOnboardingActionDataModel.m
//  Ganaz
//
//  Created by Chris Lin on 12/13/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANOnboardingActionDataModel.h"
#import "Global.h"

@implementation GANOnboardingActionDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.enumLoginFrom = GANENUM_ONBOARDINGACTION_LOGINFROM_DEFAULT;
    self.szJobId = @"";
    self.szCompanyId = @"";
    self.szSugestPhoneNumber = @"";
}

- (BOOL) hasOnboardingActionBeforeLogin {
    return !(self.enumLoginFrom == GANENUM_ONBOARDINGACTION_LOGINFROM_DEFAULT);
}

- (BOOL) isOnboardingActionForWorker {
    if (self.enumLoginFrom == GANENUM_ONBOARDINGACTION_LOGINFROM_WORKER_JOBAPPLY ||
        self.enumLoginFrom == GANENUM_ONBOARDINGACTION_LOGINFROM_WORKER_SUGGESTFRIEND) {
        return YES;
    }
    
    return NO;
}

- (void) postNotificationToContinueOnboardingAction {
    if (self.enumLoginFrom == GANENUM_ONBOARDINGACTION_LOGINFROM_WORKER_JOBAPPLY) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_ONBOARDINGACTION_WORKER_JOBAPPLY object:nil];
    }
    else if (self.enumLoginFrom == GANENUM_ONBOARDINGACTION_LOGINFROM_WORKER_SUGGESTFRIEND) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_ONBOARDINGACTION_WORKER_SUGGESTFRIEND object:nil];
    }
}

@end
