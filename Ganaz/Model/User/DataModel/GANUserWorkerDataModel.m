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
}

- (NSDictionary *) serializeToDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serializeToDictionary]];
    [dict setObject:@{@"location": [self.modelLocation serializeToDictionary],
                      @"is_newjob_lock": (self.isNewJobLock == YES) ? @"true" : @"false",
                      @"job_search_lock": @{
                              @"lock": (self.isJobSearchLock == YES) ? @"true" : @"false",
                              @"allowed_company_ids": self.arrayJobSearchAllowedCompanyIds,
                              }
                      } forKey:@"worker"];
    return dict;
}

@end
