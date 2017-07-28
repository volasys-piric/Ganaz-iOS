//
//  GANMembershipPlanManager.h
//  Ganaz
//
//  Created by Piric Djordje on 5/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANMembershipPlanDataModel.h"

@interface GANMembershipPlanManager : NSObject

@property (strong, nonatomic) NSMutableArray<GANMembershipPlanDataModel *> *arrPlans;

+ (instancetype) sharedInstance;
- (void) initializeManager;

- (GANMembershipPlanDataModel *) getPlanByType: (GANENUM_MEMBERSHIPPLAN_TYPE) type;

#pragma mark - Request

- (void) requestGetMembershipPlanListWithCallback: (void (^) (int status)) callback;

@end
