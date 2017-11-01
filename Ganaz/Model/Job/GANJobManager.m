//
//  GANJobManager.m
//  Ganaz
//
//  Created by Piric Djordje on 3/10/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANJobManager.h"
#import "GANJobApplicationDataModel.h"
#import "GANLocationManager.h"

#import "GANUserManager.h"
#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"
#import "GANGenericFunctionManager.h"
#import "GANErrorManager.h"
#import "Global.h"

@implementation GANJobManager

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
    self.arrMyJobs = [[NSMutableArray alloc] init];
    self.arrJobsSearchResult = [[NSMutableArray alloc] init];
    self.arrMyApplications = [[NSMutableArray alloc] init];
    
    self.isMyJobsLoading = NO;
    [self initializeOnboardingJobAtIndex:-1];
}

- (void) initializeOnboardingJobAtIndex: (int) index{
    self.modelOnboardingJob = [[GANJobDataModel alloc] init];
    if (index != -1){
        GANJobDataModel *job = [self.arrMyJobs objectAtIndex:index];
        [self.modelOnboardingJob initializeWithJob:job];
    }
}

- (int) addMyJobIfNeeded: (GANJobDataModel *) jobNew{
    for (int i = 0; i < (int) [self.arrMyJobs count]; i++){
        GANJobDataModel *job = [self.arrMyJobs objectAtIndex:i];
        if ([job.szId isEqualToString:jobNew.szId] == YES) return i;
    }
    [self.arrMyJobs addObject:jobNew];
    return (int) [self.arrMyJobs count] - 1;
}

- (int) addMyApplicationIfNeeded: (GANJobApplicationDataModel *) applicationNew{
    for (int i = 0; i < (int) [self.arrMyApplications count]; i++){
        GANJobApplicationDataModel *application = [self.arrMyApplications objectAtIndex:i];
        if ([application.szId isEqualToString:applicationNew.szId] == YES) return i;
    }
    [self.arrMyApplications addObject:applicationNew];
    return (int) [self.arrMyApplications count] - 1;
}

- (int) getIndexForMyApplicationsByJobId: (NSString *) jobId{
    for (int i = 0; i < (int) [self.arrMyApplications count]; i++){
        GANJobApplicationDataModel *application = [self.arrMyApplications objectAtIndex:i];
        if ([application.szJobId isEqualToString:jobId] == YES) return i;
    }
    return -1;
}

- (int) getIndexForMyJobsByJobId: (NSString *) jobId{
    for (int i = 0; i < (int) [self.arrMyJobs count]; i++){
        GANJobDataModel *job = [self.arrMyJobs objectAtIndex:i];
        if ([job.szId isEqualToString:jobId] == YES) return i;
    }
    return -1;
}

+ (BOOL) isValidJobId: (NSString *) jobId{
    return (([jobId caseInsensitiveCompare:@"NONE"] != NSOrderedSame) && (jobId.length > 0));
}

#pragma mark - Request for <Company> Users

- (void) requestMyJobListWithCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForSearchJobs];
    NSDictionary *params = @{@"company_id": [GANUserManager getCompanyDataModel].szId,
                            @"status": @"all"
                            };
    
    self.isMyJobsLoading = YES;
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        GANLOG(@"My Jobs Response ===> %@", responseObject);
        self.isMyJobsLoading = NO;
        
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrJobs = [dict objectForKey:@"jobs"];
            for (int i = 0; i < (int) [arrJobs count]; i++){
                NSDictionary *dictJob = [arrJobs objectAtIndex:i];
                GANJobDataModel *job = [[GANJobDataModel alloc] init];
                [job setWithDictionary:dictJob];
                [self.arrMyJobs addObject:job];
            }
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestAddJob: (GANJobDataModel *) job Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForAddJob];
    NSDictionary *params = [job serializeToDictionary];
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSDictionary *dictJob = [dict objectForKey:@"job"];
            GANJobDataModel *jobNew = [[GANJobDataModel alloc] init];
            [jobNew setWithDictionary:dictJob];
            [self.arrMyJobs addObject:jobNew];
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestUpdateJobAtIndex: (int) index Job: (GANJobDataModel *) job Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForUpdateJobWithJobId:job.szId];
    NSDictionary *params = [job serializeToDictionary];
    [[GANNetworkRequestManager sharedInstance] PATCH:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSDictionary *dictJob = [dict objectForKey:@"job"];
            GANJobDataModel *jobUpdated = [[GANJobDataModel alloc] init];
            [jobUpdated setWithDictionary:dictJob];
            [self.arrMyJobs replaceObjectAtIndex:index withObject:jobUpdated];
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestDeleteJobAtIndex: (int) index Callback: (void (^) (int status)) callback{
    GANJobDataModel *job = [self.arrMyJobs objectAtIndex:index];
    NSString *szUrl = [GANUrlManager getEndpointForUpdateJobWithJobId:job.szId];
    [[GANNetworkRequestManager sharedInstance] DELETE:szUrl requireAuth:YES parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            [self.arrMyJobs removeObjectAtIndex:index];
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED object:nil];
    }];
}

#pragma mark - Request for <Worker> User

- (void) requestSearchJobsNearbyWithDistance: (float) distance Date: (NSDate *) date Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForSearchJobs];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (distance > 0){
        if ([[GANUserManager sharedInstance] isUserLoggedIn] == YES && [[GANUserManager sharedInstance] isWorker] == YES){
            [params setObject:[[GANUserManager getUserWorkerDataModel].modelLocation serializeToDictionary] forKey:@"location"];
        }
        else {
            CLLocation *location = [GANLocationManager sharedInstance].location;
            [params setObject:@{@"lat": [NSString stringWithFormat:@"%.6f", location.coordinate.latitude],
                                @"lng": [NSString stringWithFormat:@"%.6f", location.coordinate.longitude]}
                       forKey:@"location"];
        }
        [params setObject:@(distance) forKey:@"distance"];
    }
    if (date != nil){
        [params setObject:[GANGenericFunctionManager getNormalizedStringFromDate:date] forKey:@"date"];
    }
    if ([[GANUserManager sharedInstance] isCompanyUser] == NO) {
        GANUserWorkerDataModel *user = [GANUserManager getUserWorkerDataModel];
        if (user.isJobSearchLock == YES) {
            [params setObject:@{@"allowed_company_ids": user.arrayJobSearchAllowedCompanyIds} forKey:@"job_search_lock"];
        }
    }

    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrJobs = [dict objectForKey:@"jobs"];
            [self.arrJobsSearchResult removeAllObjects];
            
            for (int i = 0; i < (int) [arrJobs count]; i++){
                NSDictionary *dictJob = [arrJobs objectAtIndex:i];
                GANJobDataModel *job = [[GANJobDataModel alloc] init];
                [job setWithDictionary:dictJob];
                [self.arrJobsSearchResult addObject:job];
            }
            
            // Sort by distance
            
            [self.arrJobsSearchResult sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                GANJobDataModel *job1 = obj1;
                GANJobDataModel *job2 = obj2;
                float distance1 = [job1 getNearestDistance];
                float distance2 = [job2 getNearestDistance];
                
                if (distance1 > distance2) return NSOrderedDescending;
                if (distance1 < distance2) return NSOrderedAscending;
                return NSOrderedSame;
            }];
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_WORKER_JOBSEARCH_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_WORKER_JOBSEARCH_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_WORKER_JOBSEARCH_UPDATEFAILED object:nil];
    }];
}

- (void) requestSearchJobsByCompanyId: (NSString *) companyUserId Callback: (void (^) (int status, NSArray *arrJobs)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForSearchJobs];
    NSDictionary *params = @{@"company_id": companyUserId};
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrJobs = [dict objectForKey:@"jobs"];
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < (int) [arrJobs count]; i++){
                NSDictionary *dictJob = [arrJobs objectAtIndex:i];
                GANJobDataModel *job = [[GANJobDataModel alloc] init];
                [job setWithDictionary:dictJob];
                [arr addObject:job];
            }
            if (callback) callback(SUCCESS_WITH_NO_ERROR, arr);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage], nil);
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status, nil);
    }];
}

#pragma mark - Worker > Application

- (void) requestApplyForJob: (NSString *) jobId Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForApplyForJob];
    NSDictionary *param = @{@"job_id": jobId};
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSDictionary *dictApplication = [dict objectForKey:@"application"];
            GANJobApplicationDataModel *application = [[GANJobApplicationDataModel alloc] init];
            [application setWithDictionary:dictApplication];
            [self addMyApplicationIfNeeded:application];
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
        }
        
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
    }];
    
}

- (void) requestSuggestFriendForJob: (NSString *) jobId PhoneNumber: (NSString *) phoneNumber Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForSuggestFriendForJob];
    NSDictionary *param = @{@"job_id": jobId,
                            @"worker_user_id": [GANUserManager sharedInstance].modelUser.szId,
                            @"suggested_worker": @{@"phone_number": @{
                                    @"country": @"US",
                                    @"country_code": @"1",
                                    @"local_number": phoneNumber
                                    },
                            },
                            };
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
        }
        
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
    }];
    
}

- (void) requestGetMyApplicationsWithCallback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForGetApplications];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if ([[GANUserManager sharedInstance] isCompanyUser] == NO){
        NSString *szWorkerUserId = [GANUserManager sharedInstance].modelUser.szId;
        [param setObject:szWorkerUserId forKey:@"worker_user_id"];
    }
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrApplications = [dict objectForKey:@"applications"];
            [self.arrMyApplications removeAllObjects];
            
            for (int i = 0; i < (int) [arrApplications count]; i++){
                NSDictionary *dictApplication = [arrApplications objectAtIndex:i];
                GANJobApplicationDataModel *application = [[GANJobApplicationDataModel alloc] init];
                [application setWithDictionary:dictApplication];
                [self addMyApplicationIfNeeded:application];
            }
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
        }
        
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
    }];
}

/*
#pragma mark - Worker > MyJobs (jobs for which the worker is recruited)

- (void) requestIndexForMyJobWithJobId: (NSString *) jobId Callback: (void (^) (int index)) callback{
    int index = [self getIndexForMyJobsByJobId:jobId];
    if (index != -1){
        if (callback) callback(index);
        return;
    }
    
    NSString *szUrl = [GANUrlManager getEndpointForGetJobDetailsWithJobId:jobId];
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:NO parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSDictionary *dictJob = [dict objectForKey:@"job"];
            GANJobDataModel *job = [[GANJobDataModel alloc] init];
            [job setWithDictionary:dictJob];
            int index = [self addMyJobIfNeeded:job];
            
            if (callback) callback(index);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_WORKER_JOBSEARCH_UPDATED object:nil];
        }
        else {
            if (callback) callback(-1);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_WORKER_JOBSEARCH_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(-1);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_WORKER_JOBSEARCH_UPDATEFAILED object:nil];
    }];

}
*/

@end
