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
#import "GANJobManager.h"
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
    self.arrayCrews = [[NSMutableArray alloc] init];
    self.arrMyWorkers = [[NSMutableArray alloc] init];
    self.arrCompanyUsers = [[NSMutableArray alloc] init];
    self.arrayFacebookLeads = [[NSMutableArray alloc] init];
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

- (int) getIndexForCrewWithCrewId: (NSString *) crewId {
    for (int i = 0; i < (int) [self.arrayCrews count]; i++) {
        GANCrewDataModel *crew = [self.arrayCrews objectAtIndex:i];
        if ([crew.szId isEqualToString:crewId] == YES) {
            return i;
        }
    }
    return -1;
}

- (int) getIndexForMyWorkersWithMyWorkerId: (NSString *) myWorkerId{
    for (int i = 0; i < (int) [self.arrMyWorkers count]; i++){
        GANMyWorkerDataModel *myWorker = [self.arrMyWorkers objectAtIndex:i];
        if ([myWorker.szId isEqualToString:myWorkerId]){
            return i;
        }
    }
    return -1;
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

- (int) getIndexForMyWorkersWithPhone: (GANPhoneDataModel *) phone {
    for (int i = 0; i < (int) [self.arrMyWorkers count]; i++){
        GANMyWorkerDataModel *myWorker = [self.arrMyWorkers objectAtIndex:i];
        if ([myWorker.modelWorker.modelPhone isSamePhone:phone] == YES) {
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

- (int) addCrewIfNeeded: (GANCrewDataModel *) crewNew {
    for (int i = 0; i < (int) [self.arrayCrews count]; i++) {
        GANCrewDataModel *crew = [self.arrayCrews objectAtIndex:i];
        if ([crew.szId isEqualToString:crewNew.szId] == YES) {
            return i;
        }
    }
    [self.arrayCrews addObject:crewNew];
    return (int) [self.arrayCrews count] - 1;
}

- (int) addMyWorkerIfNeeded: (GANMyWorkerDataModel *) myWorkerNew{
    if (myWorkerNew == nil) return 0;
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

- (NSArray <GANMyWorkerDataModel *> *) getMembersListForCrew: (NSString *) crewId {
    NSMutableArray <GANMyWorkerDataModel *> *arrayMembers = [[NSMutableArray alloc] init];
    for (GANMyWorkerDataModel *myWorker in self.arrMyWorkers) {
        if ([myWorker isMemberWithCrewId:crewId] == YES) {
            [arrayMembers addObject:myWorker];
        }
    }
    return arrayMembers;
}

- (NSArray <GANMyWorkerDataModel *> *) getNonCrewMembersList {
    NSMutableArray <GANMyWorkerDataModel *> *arrayMembers = [[NSMutableArray alloc] init];
    for (GANMyWorkerDataModel *myWorker in self.arrMyWorkers) {
        if ([myWorker isNonCrewMember] == YES) {
            [arrayMembers addObject:myWorker];
        }
    }
    return arrayMembers;
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

- (NSArray <GANUserRefDataModel *> *) getFacebookLeadsByJobId: (NSString *) jobId {
    NSMutableArray <GANUserRefDataModel *> *arrayLeads = [[NSMutableArray alloc] init];
    for (GANUserWorkerDataModel *lead in self.arrayFacebookLeads) {
        if ([lead.szFacebookJobId isEqualToString:jobId] == YES) {
            GANUserRefDataModel *leadUserRef = [[GANUserRefDataModel alloc] init];
            leadUserRef.szCompanyId = @"";
            leadUserRef.szUserId = lead.szId;
            [arrayLeads addObject: leadUserRef];
        }
    }
    return arrayLeads;
}

#pragma mark - Request

- (void) requestCreateCompany: (GANCompanyDataModel *) company Callback: (void (^) (int status, GANCompanyDataModel *companyNew)) callback{
    NSString *szUrl = [GANUrlManager getEndpointForCreateCompany];
    NSDictionary *params = [company serializeToDictionary];
    GANLOG(@"Create Company. %@", params);
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            GANLOG(@"Company create succeeded");
            
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
        GANLOG(@"Company create failed");
        if (callback) callback(status, nil);
    }];
}

#pragma mark - Crews

- (void) requestGetCrewsListWithCallback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForGetCrewsList:companyId];
    
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:YES parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        GANLOG(@"Crews List ===> %@", responseObject);
        
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrayCrews = [dict objectForKey:@"crews"];
            [self.arrayCrews removeAllObjects];
            
            for (int i = 0; i < (int) [arrayCrews count]; i++){
                NSDictionary *dictCrew = [arrayCrews objectAtIndex:i];
                
                GANCrewDataModel *crewNew = [[GANCrewDataModel alloc] init];
                [crewNew setWithDictionary:dictCrew];
                [self addCrewIfNeeded:crewNew];
            }
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestAddCrewWithTitle: (NSString *) title Callback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForAddCrewWithCompanyId:companyId];
    NSDictionary *params = @{@"title": title,
                             };
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSDictionary *dictCrew = [dict objectForKey:@"crew"];
            GANCrewDataModel *crewNew = [[GANCrewDataModel alloc] init];
            [crewNew setWithDictionary:dictCrew];
            [self addCrewIfNeeded:crewNew];
            
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestUpdateCrewWithCrewId: (NSString *) crewId Title: (NSString *) title Callback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    int indexCrew = [self getIndexForCrewWithCrewId:crewId];
    if (indexCrew == -1) {
        if (callback) callback(ERROR_NOT_FOUND);
        return;
    }
    
    GANCrewDataModel *crew = [self.arrayCrews objectAtIndex:indexCrew];
    crew.szTitle = title;
    
    NSString *szUrl = [GANUrlManager getEndpointForUpdateCrewWithCompanyId:companyId CrewId:crewId];
    
    NSDictionary *params = @{@"title": title,
                             };
    [[GANNetworkRequestManager sharedInstance] PATCH:szUrl requireAuth:YES parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestDeleteCrewWithCrewid: (NSString *) crewId Callback: (void (^) (int status)) callback {
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    int indexCrew = [self getIndexForCrewWithCrewId:crewId];
    if (indexCrew == -1) {
        if (callback) callback(ERROR_NOT_FOUND);
        return;
    }
    
    NSString *szUrl = [GANUrlManager getEndpointForDeleteCrewWithCompanyId:companyId CrewId:crewId];
    [[GANNetworkRequestManager sharedInstance] DELETE:szUrl requireAuth:YES parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            // Reset my-worker's crew id
            for (GANMyWorkerDataModel *myWorker in self.arrMyWorkers) {
                if ([myWorker.szCrewId isEqualToString:crewId] == YES) {
                    myWorker.szCrewId = @"";
                }
            }
            
            [self.arrayCrews removeObjectAtIndex:indexCrew];
            if (callback) callback(SUCCESS_WITH_NO_ERROR);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATED object:nil];
        }
        else {
            NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
            if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATEFAILED object:nil];
        }
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CREWSLIST_UPDATEFAILED object:nil];
    }];
}

#pragma mark - My Workers

- (void) requestGetMyWorkersListWithCallback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForGetMyWorkersWithCompanyId:companyId];
    self.isMyWorkersLoading = YES;
    
    [[GANNetworkRequestManager sharedInstance] GET:szUrl requireAuth:YES parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        GANLOG(@"My Workers Response ===> %@", responseObject);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *dict = responseObject;
            BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
            if (success){
                NSArray *arrMyWorkers = [dict objectForKey:@"my_workers"];
                [self.arrMyWorkers removeAllObjects];
                
                for (int i = 0; i < (int) [arrMyWorkers count]; i++){
                    NSDictionary *dictMyWorker = [arrMyWorkers objectAtIndex:i];
                    
                    GANMyWorkerDataModel *myWorkerNew = [[GANMyWorkerDataModel alloc] init];
                    [myWorkerNew setWithDictionary:dictMyWorker];
                    
                    // Don't add facebook lead to my-workers list... They are managed in arrayFacebookLeadWorkers.
                    if (myWorkerNew.modelWorker.enumType == GANENUM_USER_TYPE_FACEBOOK_LEAD_WORKER) continue;
                    
                    [self addMyWorkerIfNeeded:myWorkerNew];
                    [[GANCacheManager sharedInstance] addUserIfNeeded:myWorkerNew.modelWorker];
                }
                self.isMyWorkersLoading = NO;
                if (callback) callback(SUCCESS_WITH_NO_ERROR);
                [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED object:nil];
            }
            else {
                self.isMyWorkersLoading = NO;
                NSString *szMessage = [GANGenericFunctionManager refineNSString:[dict objectForKey:@"msg"]];
                if (callback) callback([[GANErrorManager sharedInstance] analyzeErrorResponseWithMessage:szMessage]);
                [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED object:nil];
            }
        });
    } failure:^(int status, NSDictionary *error) {
        if (callback) callback(status);
        [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED object:nil];
    }];
}

- (void) requestAddMyWorkerWithUserIds: (NSArray *) arrUserIds CrewId: (NSString *) crewId Callback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForAddMyWorkersWithCompanyId:companyId];
    NSDictionary *params = @{@"worker_user_ids": arrUserIds,
                             @"crew_id": [GANGenericFunctionManager refineNSString:crewId],
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

- (void) requestUpdateMyWorkerCrewWithMyWorkerId: (NSString *) myWorkerId CrewId: (NSString *) crewId Callback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForUpdateMyWorkersNicknameWithCompanyId:companyId MyWorkerId:myWorkerId];
    
    NSDictionary *params = @{@"crew_id": crewId,
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

- (void) requestSearchNewWorkersByPhone: (GANPhoneDataModel *) phone Callback: (void (^) (int status, NSArray *arrWorkers)) callback{
    [[GANUserManager sharedInstance] requestSearchUserByPhone:phone Type:GANENUM_USER_TYPE_WORKER Callback:^(int status, NSArray *array) {
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

- (void) requestDeleteMyWorker: (NSString *) myWorkerId Callback: (void (^) (int status)) callback {
    int index = [self getIndexForMyWorkersWithMyWorkerId:myWorkerId];
    if (index == -1) {
        if (callback) callback(ERROR_NOT_FOUND);
        return;
    }
    
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForDeleteMyWorkerWithCompanyId:companyId MyWorkerId:myWorkerId];
    
    [[GANNetworkRequestManager sharedInstance] DELETE:szUrl requireAuth:YES parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            int index = [self getIndexForMyWorkersWithMyWorkerId:myWorkerId];
            [self.arrMyWorkers removeObjectAtIndex:index];
            
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

- (BOOL) checkUserInMyworkerList:(GANPhoneDataModel *) phone{
    for (int i = 0; i < self.arrMyWorkers.count; i ++) {
        GANMyWorkerDataModel *worker = [self.arrMyWorkers objectAtIndex:i];
        if([worker.modelWorker.modelPhone isSamePhone:phone] == YES) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Facebook Lead Candidates

- (void) requestGetFacebookLeadsListWithCallback: (void (^) (int status)) callback{
    NSString *companyId = [GANUserManager getCompanyDataModel].szId;
    NSString *szUrl = [GANUrlManager getEndpointForUserSearch];
    NSDictionary *params = @{@"type": [GANUtils getStringFromUserType:GANENUM_USER_TYPE_FACEBOOK_LEAD_WORKER],
                             @"facebook_lead": @{
                                     @"company_id": companyId
                                     }
                             };
    
    [[GANNetworkRequestManager sharedInstance] POST:szUrl requireAuth:NO parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        GANLOG(@"Get Facebook Leads Response ===> %@", responseObject);
        
        NSDictionary *dict = responseObject;
        BOOL success = [GANGenericFunctionManager refineBool:[dict objectForKey:@"success"] DefaultValue:NO];
        if (success){
            NSArray *arrayLeadsDict = [dict objectForKey:@"users"];
            NSMutableArray *arrayLeads = [[NSMutableArray alloc] init];
            for (int i = 0; i < (int) [arrayLeadsDict count]; i++){
                NSDictionary *dictLead = [arrayLeadsDict objectAtIndex:i];
                NSString *szUserType = [GANGenericFunctionManager refineNSString: [dictLead objectForKey:@"type"]];
                GANENUM_USER_TYPE enumUserType = [GANUtils getUserTypeFromString:szUserType];
                
                GANUserWorkerDataModel *user;
                if (enumUserType == GANENUM_USER_TYPE_WORKER || enumUserType == GANENUM_USER_TYPE_ONBOARDING_WORKER || enumUserType == GANENUM_USER_TYPE_FACEBOOK_LEAD_WORKER){
                    user = [[GANUserWorkerDataModel alloc] init];
                    [user setWithDictionary:dictLead];
                }
                else {
                    continue;
                }
                
                if (user.szFacebookJobId.length == 0 || user.szFacebookAdsId.length == 0) {
                    continue;
                }
                
                [arrayLeads addObject:user];
            }
            
            [arrayLeads sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                GANUserWorkerDataModel *worker1 = obj1;
                GANUserWorkerDataModel *worker2 = obj2;
                if (worker1.dateCreatedAt == nil) return NSOrderedAscending;
                if (worker2.dateCreatedAt == nil) return NSOrderedDescending;
                return [worker1.dateCreatedAt compare:worker2.dateCreatedAt];
            }];
            
            [self.arrayFacebookLeads removeAllObjects];
            
            GANJobManager *managerJob = [GANJobManager sharedInstance];
            GANCacheManager *managerCache = [GANCacheManager sharedInstance];
            
            for (int i = 0; i < (int) [arrayLeads count]; i++) {
                GANUserWorkerDataModel *lead = [arrayLeads objectAtIndex:i];
                lead.indexForCandidate = i + 1;
                [self.arrayFacebookLeads addObject:lead];
                [managerCache addUserIfNeeded:lead];
                [managerJob addJobCandidateIfNeeded:lead.szFacebookJobId Candidate:[lead toUserRefObject]];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GANLOCALNOTIFICATION_COMPANY_CANDIDATESLIST_UPDATED object:nil];
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
