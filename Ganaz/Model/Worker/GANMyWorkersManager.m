//
//  GANMyWorkersManager.m
//  Ganaz
//
//  Created by Piric Djordje on 3/15/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANMyWorkersManager.h"
#import "GANMyWorkerDataModel.h"
#import "GANUserManager.h"
#import "GANNetworkRequestManager.h"
#import "GANUrlManager.h"

#import "Global.h"
#import "GANGenericFunctionManager.h"
#import "GANErrorManager.h"

@implementation GANMyWorkersManager

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
    self.arrMyWorkers = [[NSMutableArray alloc] init];
    self.arrWorkersFound = [[NSMutableArray alloc] init];
    self.isMyWorkersLoading = NO;
}

- (int) getIndexForMyWorkersWithUserId: (NSString *) userId{
    for (int i = 0; i < (int) [self.arrMyWorkers count]; i++){
        GANMyWorkerDataModel *myWorker = [self.arrMyWorkers objectAtIndex:i];
        if ([myWorker.szWorkerUserId isEqualToString:userId]){
            return i;
        }
    }
    return -1;
}

- (int) getIndexForWorkersFoundWithUserId: (NSString *) userId{
    for (int i = 0; i < (int) [self.arrWorkersFound count]; i++){
        GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:i];
        if ([worker.szId isEqualToString:userId]){
            return i;
        }
    }
    return -1;
}

- (int) addWorkerFoundIfNeeded: (GANUserWorkerDataModel *) workerNew{
    for (int i = 0; i < (int) [self.arrWorkersFound count]; i++){
        GANUserWorkerDataModel *worker = [self.arrWorkersFound objectAtIndex:i];
        if ([worker.szId isEqualToString:workerNew.szId] == YES) return i;
    }
    [self.arrWorkersFound addObject:workerNew];
    return (int) [self.arrWorkersFound count] - 1;
}

- (int) addMyWorkerIfNeeded: (GANMyWorkerDataModel *) myWorkerNew{
    for (int i = 0; i < (int) [self.arrMyWorkers count]; i++){
        GANMyWorkerDataModel *myWorker = [self.arrMyWorkers objectAtIndex:i];
        if ([myWorker.szId isEqualToString:myWorkerNew.szId]){
            return i;
        }
    }
    [self.arrMyWorkers addObject:myWorkerNew];
    return (int) [self.arrMyWorkers count] - 1;
}

#pragma mark - Requests

- (void) requestGetMyWorkersListWithCallback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForGetMyWorkersWithCompanyId:companyId];
    self.isMyWorkersLoading = YES;
    
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:YES parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        GANLOG(@"My Workers Response ===> %@", responseObject);
        self.isMyWorkersLoading = NO;
        
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrMyWorkers = [dict objectForKey:@"workers"];
            [self.arrMyWorkers removeAllObjects];
            
            for (int i = 0; i < (int) [arrMyWorkers count]; i++){
                NSDictionary *dictMyWorker = [arrMyWorkers objectAtIndex:i];
                
                GANMyWorkerDataModel *myWorkerNew = [[GANMyWorkerDataModel alloc] init];
                [myWorkerNew setWithDictionary:dictMyWorker];
                [self addMyWorkerIfNeeded:myWorkerNew];
                [self addWorkerFoundIfNeeded:myWorkerNew.modelWorker];
            }
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestAddMyWorkerWithUserIds: (NSArray *) arrUserIds Callback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForAddMyWorkersWithCompanyId:companyId];
    NSDictionary *params = @{@"user_ids": arrUserIds};
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arr = [dict objectForKey:@"added_workers"];
            for (int i = 0; i < (int) [arr count]; i++){
                NSDictionary *dictMyWorker = [arr objectAtIndex:i];
                GANMyWorkerDataModel *myWorkerNew = [[GANMyWorkerDataModel alloc] init];
                [myWorkerNew setWithDictionary:dictMyWorker];
                [self addMyWorkerIfNeeded:myWorkerNew];
                [self addWorkerFoundIfNeeded:myWorkerNew.modelWorker];
            }
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestSearchNewWorkersByPhoneNumber: (NSString *) phoneNumber Callback: (void (^) (int status, NSArray *arrWorkers)) callback{
    [[GANUserManager sharedInstance] requestSearchUserByPhoneNumber:phoneNumber Type:GANENUM_USER_TYPE_WORKER Callback:^(int status, NSArray *array) {
        if (status == SUCCESS_WITH_NO_ERROR && array != nil){
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for (int i = 0; i < (int) [array count]; i++){
                NSDictionary *dictUser = [array objectAtIndex:i];
                GANUserWorkerDataModel *worker = [[GANUserWorkerDataModel alloc] init];
                [worker setWithDictionary:dictUser];
                if ([self getIndexForMyWorkersWithUserId:worker.szId] == -1){
                    [arr addObject:worker];
                }
            }
            if ([array count] > 0){
                if (callback) callback(SUCCESS_WITH_NO_ERROR, arr);
            }
            else {
                if (callback) callback(ERROR_NOT_FOUND, nil);
            }
        }
        else {
            if (callback) callback(status, array);
        }
    }];
}

- (void) requestGetWorkerDetailsByWorkerUserId: (NSString *) workerUserId Callback: (void (^) (int index)) callback{
    int index = [self getIndexForWorkersFoundWithUserId:workerUserId];
    if (index != -1){
        if (callback) callback(index);
        return;
    }
    
    [[GANUserManager sharedInstance] requestUserDetailsByUserId:workerUserId Callback:^(int status, GANUserBaseDataModel *user) {
        if (status == SUCCESS_WITH_NO_ERROR){
            int index = [self addWorkerFoundIfNeeded:(GANUserWorkerDataModel *) user];
            if (callback) callback(index);
        }
        else {
            if (callback) callback(-1);
        }
    }];
}

- (void) requestSendInvite: (GANPhoneDataModel *) phone CompanyUserId: (NSString *) companyUserId Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForInvite];
    NSDictionary *params = @{@"company_user_id": companyUserId,
                             @"phone_number": [phone serializeToDictionary]
                             };
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
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

@end
