//
//  GANCompanyDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 5/23/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyDataModel.h"
#import "GANJobDataModel.h"
#import "GANJobManager.h"
#import "Global.h"
#import "GANGenericFunctionManager.h"

@implementation GANCompanyPlanDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.type = GANENUM_MEMBERSHIPPLAN_TYPE_FREE;
    self.szTitle = @"Basic";
    self.fFee = 0;
    self.nJobs = 1;
    self.nRecruits = 0;
    self.nMessages = 0;
    self.dateStart = nil;
    self.dateEnd = nil;
    self.isAutoRenewal = NO;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    self.type = [GANUtils getMembershipPlayTypeFromString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"type"]]];
    self.szTitle = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"title"]];
    self.fFee = [GANGenericFunctionManager refineFloat:[dict objectForKey:@"fee"] DefaultValue:0];
    self.nJobs = [GANGenericFunctionManager refineInt:[dict objectForKey:@"jobs"] DefaultValue:-1];
    self.nRecruits = [GANGenericFunctionManager refineInt:[dict objectForKey:@"recruits"] DefaultValue:-1];
    self.nMessages = [GANGenericFunctionManager refineInt:[dict objectForKey:@"messages"] DefaultValue:-1];
    self.dateStart = [GANGenericFunctionManager getDateFromNormalizedString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"start_date"]]];
    self.dateEnd = [GANGenericFunctionManager getDateFromNormalizedString:[GANGenericFunctionManager refineNSString:[dict objectForKey:@"end_date"]]];
    self.isAutoRenewal = [GANGenericFunctionManager refineBool:[dict objectForKey:@"auto_renewal"] DefaultValue:NO];
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[GANUtils getStringFromMembershipPlanType:self.type] forKey:@"type"];
    [dict setObject:self.szTitle forKey:@"title"];
    [dict setObject:[NSString stringWithFormat:@"%d", (int) self.fFee] forKey:@"fee"];
    [dict setObject:[NSString stringWithFormat:@"%d", self.nJobs] forKey:@"jobs"];
    [dict setObject:[NSString stringWithFormat:@"%d", self.nRecruits] forKey:@"recruits"];
    [dict setObject:[NSString stringWithFormat:@"%d", self.nMessages] forKey:@"messages"];
    [dict setObject:[GANGenericFunctionManager getNormalizedStringFromDate:self.dateStart] forKey:@"start_date"];
    [dict setObject:[GANGenericFunctionManager getNormalizedStringFromDate:self.dateEnd] forKey:@"end_date"];
    [dict setObject:(self.isAutoRenewal == YES)? @"true" : @"false" forKey:@"auto_renewal"];
    
    return dict;
}

@end

@implementation GANCompanyDataModel


- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.modelName = [[GANTransContentsDataModel alloc] init];
    self.modelDescription = [[GANTransContentsDataModel alloc] init];
    self.isAutoTranslate = NO;
    self.szCode = @"";
    self.modelAddress = [[GANAddressDataModel alloc] init];
    self.modelPlan = [[GANCompanyPlanDataModel alloc] init];
    self.nTotalReviews = 0;
    self.fTotalAvgRating = 0;
    self.nTotalJobs = 0;
    self.nTotalRecruits = 0;
    self.nTotalMessages = 0;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    NSDictionary *dictName = [dict objectForKey:@"name"];
    NSDictionary *dictDescription = [dict objectForKey:@"description"];
    NSDictionary *dictPlan = [dict objectForKey:@"plan"];
    NSDictionary *dictAddress = [dict objectForKey:@"address"];
    NSDictionary *dictReviewStats = [dict objectForKey:@"review_stats"];
    NSDictionary *dictActivityStats = [dict objectForKey:@"activity_stats"];
    
    [self.modelName setWithDictionary:dictName];
    [self.modelDescription setWithDictionary:dictDescription];
    [self.modelAddress setWithDictionary:dictAddress];
    [self.modelPlan setWithDictionary:dictPlan];
    
    self.isAutoTranslate = [GANGenericFunctionManager refineBool:[dict objectForKey:@"auto_translate"] DefaultValue:NO];
    self.szCode = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"code"]];
    
    self.nTotalReviews = [GANGenericFunctionManager refineInt:[dictReviewStats objectForKey:@"total_review"] DefaultValue:0];
    self.fTotalAvgRating = [GANGenericFunctionManager refineFloat:[dictReviewStats objectForKey:@"total_score"] DefaultValue:0];
    self.nTotalJobs = [GANGenericFunctionManager refineInt:[dictActivityStats objectForKey:@"total_jobs"] DefaultValue:0];
    self.nTotalRecruits = [GANGenericFunctionManager refineInt:[dictActivityStats objectForKey:@"total_recruits"] DefaultValue:0];
    self.nTotalMessages = [GANGenericFunctionManager refineInt:[dictActivityStats objectForKey:@"total_messages"] DefaultValue:0];
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[self.modelName serializeToDictionary] forKey:@"name"];
    [dict setObject:[self.modelDescription serializeToDictionary] forKey:@"name"];
    [dict setObject:(self.isAutoTranslate == YES) ? @"true": @"false" forKey:@"auto_translate"];
    [dict setObject:self.szCode forKey:@"code"];
    [dict setObject:[self.modelAddress serializeToDictionary] forKey:@"address"];
    [dict setObject:[self.modelPlan serializeToDictionary] forKey:@"plan"];
    
    return dict;
}

- (int) getIndexForJob: (NSString *) jobId{
    for (int i = 0; i < (int) [self.arrJobs count]; i++){
        GANJobDataModel *job = [self.arrJobs objectAtIndex:i];
        if ([job.szId isEqualToString:jobId] == YES){
            return i;
        }
    }
    return -1;
}

- (void) requestJobsListWithCallback: (void (^) (int status)) callback{
    if (self.isJobListLoaded == YES){
        if (callback) callback(SUCCESS_WITH_NO_ERROR);
        return;
    }
    
    [[GANJobManager sharedInstance] requestSearchJobsByCompanyId:self.szId Callback:^(int status, NSArray *arrJobs) {
        if (status == SUCCESS_WITH_NO_ERROR){
            if (arrJobs != nil){
                [self.arrJobs removeAllObjects];
                [self.arrJobs addObjectsFromArray:arrJobs];
            }
            self.isJobListLoaded = YES;
        }
        if (callback) callback(status);
    }];
}

- (GANENUM_COMPANY_BADGE_TYPE) getBadgeType{
    if (self.nTotalReviews < 5) return GANENUM_COMPANY_BADGE_TYPE_NONE;
    float fAvg = self.fTotalAvgRating / self.nTotalReviews;
    if (fAvg >= 4.0) return GANENUM_COMPANY_BADGE_TYPE_GOLD;
    if (fAvg >= 3.0) return GANENUM_COMPANY_BADGE_TYPE_SILVER;
    return GANENUM_COMPANY_BADGE_TYPE_NONE;
}

- (NSString *) getBusinessNameEN{
    return [self.modelName getTextEN];
}

- (NSString *) getBussinessNameES{
    return [self.modelName getTextES];
}

- (NSString *) getDescriptionEN{
    return [self.modelDescription getTextEN];
}

- (NSString *) getDescriptionES{
    return [self.modelDescription getTextES];
}

@end
