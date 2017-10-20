//
//  GANCompanyManager.m
//  Ganaz
//
//  Created by Piric Djordje on 5/24/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#import "GANCompanyManager.h"
#import "GANCacheManager.h"
#import "GANUrlManager.h"
#import "GANNetworkRequestManager.h"
#import "GANErrorManager.h"
#import "GANGenericFunctionManager.h"
#import "Global.h"

@implementation GANCompanyManager

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
    self.arrCompanyUsers = [[NSMutableArray alloc] init];
    self.isMyWorkersLoading = NO;
}

+ (NSString *) generateCompanyCodeFromName: (NSString *) companyName{
    NSString *sz = [companyName lowercaseString];
    sz = [sz stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    sz = [sz stringByReplacingOccurrencesOfString:@"--" withString:@"-"];
    sz = [GANGenericFunctionManager stripNonAlphanumericsFromNSString:sz];
    sz = [NSString stringWithFormat:@"%@-%@", sz, [GANGenericFunctionManager generateRandomString:4]];
    sz = [sz lowercaseString];
    return sz;
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

- (int) getIndexForCompanyUserWithUserId: (NSString *) userId{
    for (int i = 0; i < (int) [self.arrCompanyUsers count]; i++){
        GANUserCompanyDataModel *user = [self.arrCompanyUsers objectAtIndex:i];
        if ([user.szId isEqualToString:userId]){
            return i;
        }
    }
    return -1;
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

- (int) addCompanyUserIfNeeded: (GANUserCompanyDataModel *) userNew{
    for (int i = 0; i < (int) [self.arrCompanyUsers count]; i++){
        GANUserCompanyDataModel *user = [self.arrCompanyUsers objectAtIndex:i];
        if ([user.szId isEqualToString:userNew.szId] == YES) return i;
    }
    [self.arrCompanyUsers addObject:userNew];
    return (int) [self.arrCompanyUsers count] - 1;
}

- (void) getBestUserDisplayNameWithUserId: (NSString *) userId Callback: (void (^) (NSString *displayName)) callback{
    int indexMyWorker = [self getIndexForMyWorkersWithUserId:userId];
    if (indexMyWorker == -1){
        GANCacheManager *managerCache = [GANCacheManager sharedInstance];
        [managerCache requestGetIndexForUserByUserId:userId Callback:^(int index) {
            if (index != -1) {
                GANUserBaseDataModel *user = [managerCache.arrayUsers objectAtIndex:index];
                if (callback) callback([user getValidUsername]);
            }
            else {
                if (callback) callback(@"");
            }
        }];
        return;
    }
    
    // If added in my-workers list... return nickname if possible.
    GANMyWorkerDataModel *myWorker = [self.arrMyWorkers objectAtIndex:indexMyWorker];
    if (callback) callback([myWorker getDisplayName]);
}

#pragma mark - Request

- (void) requestCreateCompany: (GANCompanyDataModel *) company Callback: (void (^) (int status, GANCompanyDataModel *companyNew)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForCreateCompany];
    NSDictionary *params = [company serializeToDictionary];
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            GANCompanyDataModel *companyNew = [[GANCompanyDataModel alloc] init];
            NSDictionary *dictCompany = [dict objectForKey:@"company"];
            [companyNew setWithDictionary:dictCompany];
            [[GANCacheManager sharedInstance] addCompanyIfNeeded:companyNew];
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR, companyNew);
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage], nil);
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status, nil);
    }];
}

#pragma mark - My Workers

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
            NSArray *arrMyWorkers = [dict objectForKey:@"my_workers"];
            [self.arrMyWorkers removeAllObjects];
            
            for (int i = 0; i < (int) [arrMyWorkers count]; i++){
                NSDictionary *dictMyWorker = [arrMyWorkers objectAtIndex:i];
                
                GANMyWorkerDataModel *myWorkerNew = [[GANMyWorkerDataModel alloc] init];
                [myWorkerNew setWithDictionary:dictMyWorker];
                [self addMyWorkerIfNeeded:myWorkerNew];
                [[GANCacheManager sharedInstance] addUserIfNeeded:myWorkerNew.modelWorker];
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
    NSDictionary *params = @{@"worker_user_ids": arrUserIds,
                             @"crew_id": @""
                             };
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
                [[GANCacheManager sharedInstance] addUserIfNeeded:myWorkerNew.modelWorker];
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

- (void) requestUpdateMyWorkerNicknameWithMyWorkerId: (NSString *) myWorkerId Nickname: (NSString *) nickname Callback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForUpdateMyWorkersNicknameWithCompanyId:companyId MyWorkerId:myWorkerId];
    
    NSDictionary *params = @{@"nickname": nickname,
                             };
    [[GANNetworkRequestManager sharedInstance] PATCH:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
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
                GANUserWorkerDataModel *worker = [array objectAtIndex:i];
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

- (void) requestSendInvite: (GANPhoneDataModel *) phone CompanyId: (NSString *) companyId inviteOnly:(BOOL)bInviteOnly Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForInvite];
    NSDictionary *params = @{@"company_id": companyId,
                             @"phone_number": [phone serializeToDictionary],
                             @"invite_only": @(bInviteOnly)
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

#pragma mark - Company Users

- (void) requestGetCompanyUsersWithCallback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForUserSearch];
    NSDictionary *param = @{@"company_id": companyId};
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrUsers = [dict objectForKey:@"users"];
            [self.arrCompanyUsers removeAllObjects];
            
            GANUserCompanyDataModel *me = [GANUserManager getUserCompanyDataModel];
            for (int i = 0; i < (int) [arrUsers count]; i++){
                NSDictionary *dictUser = [arrUsers objectAtIndex:i];
                
                GANUserCompanyDataModel *userNew = [[GANUserCompanyDataModel alloc] init];
                [userNew setWithDictionary:dictUser];
                if ([userNew.szId isEqualToString:me.szId] == NO){
                    [self addCompanyUserIfNeeded:userNew];
                    [[GANCacheManager sharedInstance] addUserIfNeeded:userNew];
                }
            }
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_COMPANYUSERSLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_COMPANYUSERSLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_COMPANYUSERSLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestUpdateCompanyUserType: (NSString *) userId Type: (GANENUM_USER_TYPE) type Callback: (void (^) (int status)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForUserUpdateTypeWithUserId:userId];
    NSDictionary *param = @{@"type": [GANUtils getStringFromUserType:type]};
    
    [[GANNetworkRequestManager sharedInstance] PATCH:szUrl requireAuth:YES parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            int index = [self getIndexForCompanyUserWithUserId:userId];
            GANUserCompanyDataModel *user = [self.arrCompanyUsers objectAtIndex:index];
            user.enumType = type;
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

- (BOOL) checkUserInMyworkerList:(NSString *) szPhoneNumber {
    for (int i = 0; i < self.arrMyWorkers.count; i ++) {
        GANMyWorkerDataModel *worker = [self.arrMyWorkers objectAtIndex:i];
        if([szPhoneNumber caseInsensitiveCompare:worker.modelWorker.modelPhone.szLocalNumber] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

@end
