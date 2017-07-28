//
//  GANMembershipPlanDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 5/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMembershipPlanDataModel.h"
#import "GANGenericFunctionManager.h"

@implementation GANMembershipPlanDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.type = GANENUM_MEMBERSHIPPLAN_TYPE_FREE;
    self.szTitle = @"";
    self.nJobs = -1;
    self.nMessages = -1;
    self.nRecruits = -1;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [self initialize];
    
    self.szId = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"_id"]];
    self.type = [GANUtils getMembershipPlayTypeFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"type"]]];
    self.szTitle = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"title"]];
    self.fFee = [GANGenericFunctionManager refineFloat:[dict objectForKey:@"fee"] DefaultValue:0];
    self.nJobs = [GANGenericFunctionManager refineInt:[dict objectForKey:@"jobs"] DefaultValue:-1];
    self.nRecruits = [GANGenericFunctionManager refineInt:[dict objectForKey:@"recruits"] DefaultValue:-1];
    self.nMessages = [GANGenericFunctionManager refineInt:[dict objectForKey:@"messages"] DefaultValue:-1];
}

@end
