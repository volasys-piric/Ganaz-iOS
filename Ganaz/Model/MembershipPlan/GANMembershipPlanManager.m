//
//  GANMembershipPlanManager.m
//  Ganaz
//
//  Created by Piric Djordje on 5/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMembershipPlanManager.h"
#import "GANUrlManager.h"
#import "GANNetworkRequestManager.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"
#import "GANErrorManager.h"

@implementation GANMembershipPlanManager

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initializeManager];
    }
    return self;
}

- (void) initializeManager{
    self.arrPlans = [[NSMutableArray alloc] init];
}

- (int) addMembershipPlanIfNeeded: (GANMembershipPlanDataModel *) planNew{
    for (int i = 0; i < (int) [self.arrPlans count]; i++){
        GANMembershipPlanDataModel *plan = [self.arrPlans objectAtIndex:i];
        if ([plan.szId isEqualToString:planNew.szId] == YES) return i;
    }
    [self.arrPlans addObject:planNew];
    return (int) [self.arrPlans count] - 1;
}

- (GANMembershipPlanDataModel *) getPlanByType: (GANENUM_MEMBERSHIPPLAN_TYPE) type{
    for (int i = 0; i < (int) [self.arrPlans count]; i++){
        GANMembershipPlanDataModel *plan = [self.arrPlans objectAtIndex:i];
        if (plan.type == type){
            return plan;
        }
    }
    
    // Temporary Plan if no plan found...
    GANMembershipPlanDataModel *temp = [[GANMembershipPlanDataModel alloc] init];
    temp.type = GANENUM_MEMBERSHIPPLAN_TYPE_FREE;
    temp.szTitle = @"Basic";
    temp.fFee = 0;
    temp.nJobs = 1;
    temp.nRecruits = -1;
    temp.nMessages = -1;
    return temp;
}

#pragma mark - Request

- (void) requestGetMembershipPlanListWithCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForMembershipPlans];
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:YES parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrPlans = [dict objectForKey:@"plans"];
            [self.arrPlans removeAllObjects];
            
            for (int i = 0; i < (int) [arrPlans count]; i++){
                NSDictionary *dictPlan = [arrPlans objectAtIndex:i];
                GANMembershipPlanDataModel *plan = [[GANMembershipPlanDataModel alloc] init];
                [plan setWithDictionary:dictPlan];
                [self.arrPlans addObject:plan];
            }
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MEMBERSHIPPLAN_LIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MEMBERSHIPPLAN_LIST_UPDATE_FAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_MEMBERSHIPPLAN_LIST_UPDATE_FAILED object:nil];
    }];
}

@end
