//
//  GANUserWorkerDataModel.m
//  Ganaz
//
//  Created by Piric Djordje on 3/9/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANUserWorkerDataModel.h"
#import "GANLocationManager.h"
#import "GANGenericFunctionManager.h"

@implementation GANUserWorkerDataModel

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
    self.enumType = GANENUM_USER_TYPE_WORKER;
    self.modelPhone = [[GANPhoneDataModel alloc] init];
    self.enumAuthType = GANENUM_USER_AUTHTYPE_PHONE;
    self.szExternalId = @"";
    self.arrPlayerIds = [[NSMutableArray alloc] init];
    
    self.isNewJobLock = NO;
    self.isJobSearchLock = NO;
    self.arrayJobSearchAllowedCompanyIds = [[NSMutableArray alloc] init];
    self.modelLocation = [[GANLocationDataModel alloc] init];
    
    self.indexForCandidate = 1;
    self.szFacebookPSID = @"";
    self.szFacebookPageId = @"";
    self.szFacebookAdsId = @"";
    self.szFacebookCompanyId = @"";
    self.szFacebookJobId = @"";
    
    GANLocationManager *managerLocation = [GANLocationManager sharedInstance];
    if (managerLocation.location != nil){
        self.modelLocation.fLatitude = managerLocation.location.coordinate.latitude;
        self.modelLocation.fLongitude = managerLocation.location.coordinate.longitude;
        self.modelLocation.szAddress = managerLocation.szAddress;
    }
}

- (void) setWithDictionary:(NSDictionary *)dict{
    [super setWithDictionary:dict];
    
    NSDictionary *dictWorker = [dict objectForKey:@"worker"];
    self.isNewJobLock = [GANGenericFunctionManager refineBool:[dictWorker objectForKey:@"is_newjob_lock"] DefaultValue:NO];

    NSDictionary *dictLocation = [dictWorker objectForKey:@"location"];
    [self.modelLocation setWithDictionary:dictLocation];
    
    NSDictionary *dictJobSearchLock = [dictWorker objectForKey:@"job_search_lock"];
    if (dictJobSearchLock != nil && [dictJobSearchLock isKindOfClass:[NSDictionary class]] == YES) {
        self.isJobSearchLock = [GANGenericFunctionManager refineBool:[dictJobSearchLock objectForKey:@"lock"] DefaultValue:NO];
        self.arrayJobSearchAllowedCompanyIds = [[NSMutableArray alloc] init];
        
        NSArray *arrayCompanyIds = [dictJobSearchLock objectForKey:@"allowed_company_ids"];
        if (arrayCompanyIds != nil && [arrayCompanyIds isKindOfClass:[NSArray class]] == YES) {
            for (int i = 0; i < (int) [arrayCompanyIds count]; i++) {
                [self.arrayJobSearchAllowedCompanyIds addObject:[GANGenericFunctionManager refineNSString:[arrayCompanyIds objectAtIndex:i]]];
            }
        }
    }
    
    NSDictionary *dictFacebookLead = [dictWorker objectForKey:@"facebook_lead"];
    if (dictFacebookLead != nil && [dictFacebookLead isKindOfClass:[NSDictionary class]] == YES) {
        self.szFacebookPSID = [GANGenericFunctionManager refineNSString:[dictFacebookLead objectForKey:@"psid"]];
        self.szFacebookPageId = [GANGenericFunctionManager refineNSString:[dictFacebookLead objectForKey:@"page_id"]];
        self.szFacebookAdsId = [GANGenericFunctionManager refineNSString:[dictFacebookLead objectForKey:@"ad_id"]];
        self.szFacebookCompanyId = [GANGenericFunctionManager refineNSString:[dictFacebookLead objectForKey:@"company_id"]];
        self.szFacebookJobId = [GANGenericFunctionManager refineNSString:[dictFacebookLead objectForKey:@"job_id"]];
    }
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serializeToDictionary]];

    [dict setObject:@{@"location": [self.modelLocation serializeToDictionary],
                      @"is_newjob_lock": (self.isNewJobLock == YES) ? @"true" : @"false",
                      @"job_search_lock": @{
                              @"lock": (self.isJobSearchLock == YES) ? @"true" : @"false",
                              @"allowed_company_ids": self.arrayJobSearchAllowedCompanyIds,
                              },
                      @"facebook_lead": @{
                              @"psid": self.szFacebookPSID,
                              @"page_id": self.szFacebookPageId,
                              @"ad_id": self.szFacebookAdsId,
                              @"company_id": self.szFacebookCompanyId,
                              @"job_id": self.szFacebookJobId,
                              },
                      } forKey:@"worker"];
    
    return dict;
}

@end
