//
//  GANUserCompanyDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserCompanyDataModel.h"
#import "GANGenericFunctionManager.h"
#import "GANJobManager.h"
#import "Global.h"

@implementation GANUserCompanyDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.szId = @"";
    self.szAccessToken = @"";
    self.szFirstName = @"";
    self.szLastName = @"";
    self.szUserName = @"";
    self.szPassword = @"";
    self.szEmail = @"";
    self.modelPhone = [[GANPhoneDataModel alloc] init];
    self.enumAuthType = GANENUM_USER_AUTHTYPE_EMAIL;
    self.szExternalId = @"";
    self.szPlayerId = @"";
    
    self.szBusinessName = @"";
    self.szBusinessNameTranslated = @"";
    self.szDescription = @"";
    self.szDescriptionTranslated = @"";
    self.isAutoTranslate = NO;
    
    self.enumType = GANENUM_USER_TYPE_COMPANY;
    self.modelAddress = [[GANAddressDataModel alloc] init];
    
    self.arrJobs = [[NSMutableArray alloc] init];
    self.isJobListLoaded = NO;
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [super setWithDictionary:dict];
    
    NSDictionary *dictCompany = [dict objectForKey:@"company"];
    NSDictionary *dictAddress = [dictCompany objectForKey:@"address"];
    [self.modelAddress setWithDictionary:dictAddress];
    
    self.szBusinessName = [GANGenericFunctionManager refineNSString:[dictCompany objectForKey:@"name"]];
    self.szBusinessNameTranslated = [GANGenericFunctionManager refineNSString:[dictCompany objectForKey:@"name_translated"]];
    if (self.szBusinessNameTranslated.length == 0) self.szBusinessNameTranslated = self.szBusinessName;
    
    self.szDescription = [GANGenericFunctionManager refineNSString:[dictCompany objectForKey:@"description"]];
    self.szDescriptionTranslated = [GANGenericFunctionManager refineNSString:[dictCompany objectForKey:@"description_translated"]];
    if (self.szDescriptionTranslated.length == 0) self.szDescriptionTranslated = self.szDescription;
    
    self.nTotalReviews = [GANGenericFunctionManager refineInt:[dictCompany objectForKey:@"total_review"] DefaultValue:0];
    self.fTotalAvgRating = [GANGenericFunctionManager refineFloat:[dictCompany objectForKey:@"total_score"] DefaultValue:0];
    self.isAutoTranslate = [GANGenericFunctionManager refineBool:[dictCompany objectForKey:@"auto_translate"] DefaultValue:NO];
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serializeToDictionary]];
    [dict setObject:@{@"name": self.szBusinessName,
                      @"name_translated": self.szBusinessNameTranslated,
                      @"description": self.szDescription,
                      @"description_translated": self.szDescriptionTranslated,
                      @"auto_translate": (self.isAutoTranslate == YES) ? @"true": @"false",
                      @"address": [self.modelAddress serializeToDictionary]
                      }
             forKey:@"company"];
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

- (NSString *) getTranslatedBusinessName{
    if (self.isAutoTranslate == NO) return self.szBusinessName;
    if (self.szBusinessNameTranslated.length == 0) return self.szBusinessName;
    return self.szBusinessNameTranslated;
}

- (NSString *) getTranslatedDescription{
    if (self.isAutoTranslate == NO) return self.szDescription;
    if (self.szDescriptionTranslated.length == 0) return self.szDescription;
    return self.szDescriptionTranslated;
}

@end
